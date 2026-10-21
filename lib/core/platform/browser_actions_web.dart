// ignore_for_file: deprecated_member_use, avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<void> downloadJson(String json, String filename) async {
  final blob = html.Blob([json], 'application/json;charset=utf-8');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.AnchorElement(href: url)
    ..download = filename
    ..click();
  html.Url.revokeObjectUrl(url);
}

Future<bool> requestPersistentStorage() async {
  final storage = html.window.navigator.storage;
  if (storage == null) return false;
  return storage.persist();
}

void reloadApp() => html.window.location.reload();
