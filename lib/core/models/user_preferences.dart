class UserPreferences {
  const UserPreferences({
    this.isDarkMode = false,
    this.locale = 'en',
    this.textScale = 1,
    this.dailyReminderTime = '07:00',
    this.dailyReminderEnabled = false,
    this.lastReminderDate,
    this.favoriteVerses = const [],
    this.preferredBibleVersion = 'engwebp',
    this.aiAuthToken,
    this.hasCompletedOnboarding = false,
    this.translationStyle,
    this.denomination,
  });

  final bool isDarkMode;
  final String locale;
  final double textScale;
  final String dailyReminderTime;
  final bool dailyReminderEnabled;
  final String? lastReminderDate;
  final List<String> favoriteVerses;
  final String preferredBibleVersion;
  final String? aiAuthToken;
  final bool hasCompletedOnboarding;
  final String? translationStyle;
  final String? denomination;

  factory UserPreferences.fromJson(Map<dynamic, dynamic> json) {
    return UserPreferences(
      isDarkMode: json['isDarkMode'] == true,
      locale: json['locale'] as String? ?? 'en',
      textScale: (json['textScale'] as num?)?.toDouble() ?? 1,
      dailyReminderTime: json['dailyReminderTime'] as String? ?? '07:00',
      dailyReminderEnabled: json['dailyReminderEnabled'] == true,
      lastReminderDate: json['lastReminderDate'] as String?,
      favoriteVerses: List<String>.from(
        json['favoriteVerses'] as List? ?? const [],
      ),
      preferredBibleVersion:
          json['preferredBibleVersion'] as String? ?? 'engwebp',
      aiAuthToken: json['aiAuthToken'] as String?,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] == true,
      translationStyle: json['translationStyle'] as String?,
      denomination: json['denomination'] as String?,
    );
  }

  Map<String, dynamic> toJson({bool includeSecrets = true}) => {
    'isDarkMode': isDarkMode,
    'locale': locale,
    'textScale': textScale,
    'dailyReminderTime': dailyReminderTime,
    'dailyReminderEnabled': dailyReminderEnabled,
    'lastReminderDate': lastReminderDate,
    'favoriteVerses': favoriteVerses,
    'preferredBibleVersion': preferredBibleVersion,
    'hasCompletedOnboarding': hasCompletedOnboarding,
    'translationStyle': translationStyle,
    'denomination': denomination,
    if (includeSecrets) 'aiAuthToken': aiAuthToken,
  };

  UserPreferences copyWith({
    bool? isDarkMode,
    String? locale,
    double? textScale,
    String? dailyReminderTime,
    bool? dailyReminderEnabled,
    String? lastReminderDate,
    List<String>? favoriteVerses,
    String? preferredBibleVersion,
    String? aiAuthToken,
    bool? hasCompletedOnboarding,
    String? translationStyle,
    String? denomination,
    bool clearAiAuthToken = false,
  }) {
    return UserPreferences(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      locale: locale ?? this.locale,
      textScale: textScale ?? this.textScale,
      dailyReminderTime: dailyReminderTime ?? this.dailyReminderTime,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      lastReminderDate: lastReminderDate ?? this.lastReminderDate,
      favoriteVerses: favoriteVerses ?? this.favoriteVerses,
      preferredBibleVersion:
          preferredBibleVersion ?? this.preferredBibleVersion,
      aiAuthToken: clearAiAuthToken ? null : aiAuthToken ?? this.aiAuthToken,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      translationStyle: translationStyle ?? this.translationStyle,
      denomination: denomination ?? this.denomination,
    );
  }
}
