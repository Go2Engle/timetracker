import 'package:shared_preferences/shared_preferences.dart';

/// Service for managing user preferences and app settings
class PreferencesService {
  static const String _keyGroupByCategory = 'groupByCategory';

  static final PreferencesService _instance = PreferencesService._internal();
  SharedPreferences? _prefs;

  factory PreferencesService() {
    return _instance;
  }

  PreferencesService._internal();

  /// Initialize the preferences service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Get the SharedPreferences instance
  SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('PreferencesService not initialized. Call initialize() first.');
    }
    return _prefs!;
  }

  // Task List Preferences

  /// Get whether tasks should be grouped by category
  bool getGroupByCategory() {
    return prefs.getBool(_keyGroupByCategory) ?? false;
  }

  /// Set whether tasks should be grouped by category
  Future<bool> setGroupByCategory(bool value) {
    return prefs.setBool(_keyGroupByCategory, value);
  }
}
