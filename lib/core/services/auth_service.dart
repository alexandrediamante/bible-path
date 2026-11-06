import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bible_path/core/services/storage_service.dart';

/// Service for handling Google Sign-In and cloud authentication
class AuthService extends ChangeNotifier {
  static const _prefsUserIdKey = 'auth_user_id';
  static const _prefsAppAuthTokenKey = 'auth_app_auth_token';
  static const _prefsGoogleIdTokenKey = 'auth_google_id_token';

  final StorageService _storage;
  final String _apiBaseUrl;
  final String _googleClientId;

  GoogleSignIn? _googleSignIn;
  String? _userId;
  String? _appAuthToken;
  String? _googleIdToken;
  bool _isLoading = false;
  String? _error;

  AuthService({
    required StorageService storage,
    required String apiBaseUrl,
    required String googleClientId,
  })  : _storage = storage,
        _apiBaseUrl = apiBaseUrl.replaceFirst(RegExp(r'/+$'), ''),
        _googleClientId = googleClientId {
    _initGoogleSignIn();
    _loadPersistedAuth();
  }

  /// Current authenticated user ID (Google sub)
  String? get userId => _userId;

  /// App auth token for API calls
  String? get appAuthToken => _appAuthToken;

  /// Google ID token
  String? get googleIdToken => _googleIdToken;

  /// Whether user is signed in
  bool get isSignedIn => _userId != null && _appAuthToken != null;

  /// Whether an auth operation is in progress
  bool get isLoading => _isLoading;

  /// Last error message
  String? get error => _error;

  /// User email (from Google profile)
  String? get userEmail => _storage.userPreferences.aiAuthToken != null ? null : null; // TODO: store email

  /// User display name
  String? get userName => _storage.userPreferences.denomination; // TODO: store name

  /// User profile picture URL
  String? get userPicture => null; // TODO: store picture

  void _initGoogleSignIn() {
    if (kIsWeb) {
      _googleSignIn = GoogleSignIn(
        clientId: _googleClientId,
        scopes: ['email', 'profile', 'openid'],
      );
    }
  }

  Future<void> _loadPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    _userId = prefs.getString(_prefsUserIdKey);
    _appAuthToken = prefs.getString(_prefsAppAuthTokenKey);
    _googleIdToken = prefs.getString(_prefsGoogleIdTokenKey);
    notifyListeners();
  }

  Future<void> _persistAuth({
    String? userId,
    String? appAuthToken,
    String? googleIdToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (userId != null) {
      await prefs.setString(_prefsUserIdKey, userId);
      _userId = userId;
    }
    if (appAuthToken != null) {
      await prefs.setString(_prefsAppAuthTokenKey, appAuthToken);
      _appAuthToken = appAuthToken;
    }
    if (googleIdToken != null) {
      await prefs.setString(_prefsGoogleIdTokenKey, googleIdToken);
      _googleIdToken = googleIdToken;
    }
  }

  Future<void> _clearPersistedAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsUserIdKey);
    await prefs.remove(_prefsAppAuthTokenKey);
    await prefs.remove(_prefsGoogleIdTokenKey);
    _userId = null;
    _appAuthToken = null;
    _googleIdToken = null;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    if (_googleSignIn == null) {
      _setError('Google Sign-In not initialized');
      return false;
    }

    _setLoading(true);
    _setError(null);

    try {
      final GoogleSignInAccount? account = await _googleSignIn!.signIn();
      if (account == null) {
        _setError('Sign in cancelled');
        _setLoading(false);
        return false;
      }

      final GoogleSignInAuthentication auth = await account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        _setError('Failed to get ID token');
        _setLoading(false);
        return false;
      }

      // Exchange Google ID token for app auth token
      final success = await _exchangeToken(idToken, account.email, account.displayName ?? '', account.photoUrl ?? '');

      _setLoading(false);
      return success;
    } catch (e) {
      _setError('Sign in failed: $e');
      _setLoading(false);
      return false;
    }
  }

  /// Exchange Google ID token for app auth token
  Future<bool> _exchangeToken(
    String idToken,
    String email,
    String name,
    String picture,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_apiBaseUrl/v1/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'idToken': idToken, 'clientId': _googleClientId}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) {
        final body = jsonDecode(response.body);
        _setError(body['error']?['message'] ?? 'Authentication failed');
        return false;
      }

      final data = jsonDecode(response.body);
      final user = data['user'] as Map<String, dynamic>;
      final appAuthToken = data['appAuthToken'] as String;

      await _persistAuth(
        userId: user['id'] as String,
        appAuthToken: appAuthToken,
        googleIdToken: idToken,
      );

      // Update local preferences with user info
      await _storage.updatePreferences(
        _storage.userPreferences.copyWith(
          locale: user['locale'] as String? ?? _storage.userPreferences.locale,
        ),
      );

      return true;
    } on TimeoutException {
      _setError('Connection timeout');
      return false;
    } catch (e) {
      _setError('Token exchange failed: $e');
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setLoading(true);
    try {
      await _googleSignIn?.signOut();
    } catch (_) {
      // Ignore sign out errors
    }
    await _clearPersistedAuth();
    _setLoading(false);
  }

  /// Get current user profile from cloud
  Future<Map<String, dynamic>?> getCurrentUser() async {
    if (!isSignedIn) return null;

    try {
      final response = await http
          .get(
            Uri.parse('$_apiBaseUrl/v1/users/me'),
            headers: {'Authorization': 'Bearer $_appAuthToken'},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) return null;
      return jsonDecode(response.body)['user'] as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Check if token is valid
  Future<bool> validateToken() async {
    if (!isSignedIn) return false;

    try {
      final response = await http
          .get(
            Uri.parse('$_apiBaseUrl/v1/users/me'),
            headers: {'Authorization': 'Bearer $_appAuthToken'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 401) {
        await signOut();
        return false;
      }
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}