import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Auth token management
  Future<void> saveAuthToken(String token) async {
    await _prefs?.setString('auth_token', token);
  }

  String? getAuthToken() {
    return _prefs?.getString('auth_token');
  }

  Future<void> removeAuthToken() async {
    await _prefs?.remove('auth_token');
  }

  // User data management
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    await _prefs?.setString('user_data', jsonEncode(userData));
  }

  Map<String, dynamic>? getUserData() {
    final userDataString = _prefs?.getString('user_data');
    if (userDataString != null) {
      return jsonDecode(userDataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeUserData() async {
    await _prefs?.remove('user_data');
  }

  // App settings
  Future<void> saveThemeMode(String themeMode) async {
    await _prefs?.setString('theme_mode', themeMode);
  }

  String getThemeMode() {
    return _prefs?.getString('theme_mode') ?? 'system';
  }

  Future<void> saveLanguage(String language) async {
    await _prefs?.setString('language', language);
  }

  String getLanguage() {
    return _prefs?.getString('language') ?? 'en';
  }

  // Notification settings
  Future<void> saveNotificationSettings(Map<String, bool> settings) async {
    await _prefs?.setString('notification_settings', jsonEncode(settings));
  }

  Map<String, bool> getNotificationSettings() {
    final settingsString = _prefs?.getString('notification_settings');
    if (settingsString != null) {
      final Map<String, dynamic> decoded = jsonDecode(settingsString);
      return decoded.map((key, value) => MapEntry(key, value as bool));
    }
    return {
      'push_notifications': true,
      'email_notifications': true,
      'sms_notifications': false,
    };
  }

  // Cache management
  Future<void> saveCacheData(String key, Map<String, dynamic> data) async {
    await _prefs?.setString('cache_$key', jsonEncode(data));
  }

  Map<String, dynamic>? getCacheData(String key) {
    final dataString = _prefs?.getString('cache_$key');
    if (dataString != null) {
      return jsonDecode(dataString) as Map<String, dynamic>;
    }
    return null;
  }

  Future<void> removeCacheData(String key) async {
    await _prefs?.remove('cache_$key');
  }

  Future<void> clearAllCache() async {
    final keys = _prefs?.getKeys().where((key) => key.startsWith('cache_')).toList() ?? [];
    for (final key in keys) {
      await _prefs?.remove(key);
    }
  }

  // Clear all data (logout)
  Future<void> clearAllData() async {
    await _prefs?.clear();
  }

  // Check if user is logged in
  bool isLoggedIn() {
    return getAuthToken() != null;
  }
} 