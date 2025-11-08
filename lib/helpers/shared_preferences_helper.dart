import 'package:shared_preferences/shared_preferences.dart';

/// Helper for reading/writing user preferences in SharedPreferences.
class SharedPreferencesHelper {
  // Keys used across the app. Keep these in sync with `main.dart` which
  // reads these keys directly on startup.
  static const String keyUsername = 'username';
  static const String keyToLang = 'tolang';
  static const String keyFromLang = 'fromlang';
  static const String keyLevel = 'level';

  /// Save languages. Values will be normalized to lowercase for consistency.
  static Future<void> saveUserLanguages({
    required String fromLanguage,
    required String toLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyFromLang, fromLanguage.toLowerCase());
    await prefs.setString(keyToLang, toLanguage.toLowerCase());
  }

  /// Read languages and return a map with friendly keys used by UI code.
  /// Returns empty strings if keys are absent.
  static Future<Map<String, String>> getUserLanguages() async {
    final prefs = await SharedPreferences.getInstance();
    final fromLanguage = prefs.getString(keyFromLang) ?? '';
    final toLanguage = prefs.getString(keyToLang) ?? '';
    return {
      // keep the returned keys camelCase for compatibility with existing callers
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
    };
  }

  /// Save all user info (username, level and languages). Values are normalized
  /// so the rest of the app can rely on lower-case storage.
  static Future<void> saveUserInfo({
    required String username,
    required String level,
    required String fromLanguage,
    required String toLanguage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyUsername, username.toLowerCase());
    await prefs.setString(keyLevel, level.toLowerCase());
    await prefs.setString(keyFromLang, fromLanguage.toLowerCase());
    await prefs.setString(keyToLang, toLanguage.toLowerCase());
  }

  /// Read user info. Returns a map with keys 'username','level','fromLanguage','toLanguage'.
  /// Values are empty strings when not present.
  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString(keyUsername) ?? '';
    final level = prefs.getString(keyLevel) ?? '';
    final fromLanguage = prefs.getString(keyFromLang) ?? '';
    final toLanguage = prefs.getString(keyToLang) ?? '';
    return {
      'username': username,
      'level': level,
      'fromLanguage': fromLanguage,
      'toLanguage': toLanguage,
    };
  }
}