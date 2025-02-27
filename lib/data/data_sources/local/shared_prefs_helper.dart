import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/error/exceptions.dart';

class SharedPrefsHelper {
  static final SharedPrefsHelper _instance = SharedPrefsHelper._internal();
  static SharedPreferences? _prefs;

  // Keys
  static const String _keyUserFirstTime = 'user_first_time';
  static const String _keyThemeMode = 'theme_mode';
  static const String _keyCurrency = 'currency';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyLastBudgetAlert = 'last_budget_alert';
  static const String _keyLastBackup = 'last_backup';

  factory SharedPrefsHelper() {
    return _instance;
  }

  SharedPrefsHelper._internal();

  Future<SharedPreferences> get prefs async {
    if (_prefs != null) return _prefs!;
    _prefs = await SharedPreferences.getInstance();
    return _prefs!;
  }

  // Generic methods to store different types of data
  Future<bool> setString(String key, String value) async {
    try {
      final preferences = await prefs;
      return await preferences.setString(key, value);
    } catch (e) {
      throw LocalStorageException('Failed to save string: ${e.toString()}');
    }
  }

  Future<String?> getString(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getString(key);
    } catch (e) {
      throw LocalStorageException('Failed to get string: ${e.toString()}');
    }
  }

  Future<bool> setBool(String key, bool value) async {
    try {
      final preferences = await prefs;
      return await preferences.setBool(key, value);
    } catch (e) {
      throw LocalStorageException('Failed to save boolean: ${e.toString()}');
    }
  }

  Future<bool?> getBool(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getBool(key);
    } catch (e) {
      throw LocalStorageException('Failed to get boolean: ${e.toString()}');
    }
  }

  Future<bool> setInt(String key, int value) async {
    try {
      final preferences = await prefs;
      return await preferences.setInt(key, value);
    } catch (e) {
      throw LocalStorageException('Failed to save integer: ${e.toString()}');
    }
  }

  Future<int?> getInt(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getInt(key);
    } catch (e) {
      throw LocalStorageException('Failed to get integer: ${e.toString()}');
    }
  }

  Future<bool> setDouble(String key, double value) async {
    try {
      final preferences = await prefs;
      return await preferences.setDouble(key, value);
    } catch (e) {
      throw LocalStorageException('Failed to save double: ${e.toString()}');
    }
  }

  Future<double?> getDouble(String key) async {
    try {
      final preferences = await prefs;
      return preferences.getDouble(key);
    } catch (e) {
      throw LocalStorageException('Failed to get double: ${e.toString()}');
    }
  }

  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final preferences = await prefs;
      return await preferences.setString(key, json.encode(value));
    } catch (e) {
      throw LocalStorageException('Failed to save object: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>?> getObject(String key) async {
    try {
      final preferences = await prefs;
      String? jsonString = preferences.getString(key);
      if (jsonString == null) return null;
      return json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw LocalStorageException('Failed to get object: ${e.toString()}');
    }
  }

  Future<bool> remove(String key) async {
    try {
      final preferences = await prefs;
      return await preferences.remove(key);
    } catch (e) {
      throw LocalStorageException('Failed to remove key: ${e.toString()}');
    }
  }

  Future<bool> clear() async {
    try {
      final preferences = await prefs;
      return await preferences.clear();
    } catch (e) {
      throw LocalStorageException('Failed to clear preferences: ${e.toString()}');
    }
  }

  // App specific methods
  Future<bool> isUserFirstTime() async {
    bool? isFirstTime = await getBool(_keyUserFirstTime);
    return isFirstTime ?? true;
  }

  Future<bool> setUserFirstTime(bool isFirstTime) async {
    return await setBool(_keyUserFirstTime, isFirstTime);
  }

  Future<String> getThemeMode() async {
    return await getString(_keyThemeMode) ?? 'system';
  }

  Future<bool> setThemeMode(String themeMode) async {
    return await setString(_keyThemeMode, themeMode);
  }

  Future<String> getCurrency() async {
    return await getString(_keyCurrency) ?? 'USD';
  }

  Future<bool> setCurrency(String currency) async {
    return await setString(_keyCurrency, currency);
  }

  Future<bool> areNotificationsEnabled() async {
    bool? enabled = await getBool(_keyNotificationsEnabled);
    return enabled ?? true;
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    return await setBool(_keyNotificationsEnabled, enabled);
  }

  Future<DateTime?> getLastBudgetAlert() async {
    int? timestamp = await getInt(_keyLastBudgetAlert);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> setLastBudgetAlert(DateTime dateTime) async {
    return await setInt(_keyLastBudgetAlert, dateTime.millisecondsSinceEpoch);
  }

  Future<DateTime?> getLastBackup() async {
    int? timestamp = await getInt(_keyLastBackup);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  Future<bool> setLastBackup(DateTime dateTime) async {
    return await setInt(_keyLastBackup, dateTime.millisecondsSinceEpoch);
  }
}