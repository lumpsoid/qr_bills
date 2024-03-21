import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager {
  static const String keyServerUrl = '192.168.1.19:5001';
  static const String keyDarkMode = 'darkMode';

  // Getters and setters for individual settings
  static Future<String> getServerUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? url = prefs.getString(keyServerUrl);
    url ??= '';
    return url;
  }

  static Future<void> setServerUrl(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyServerUrl, url);
  }

  static Future<bool?> getDarkMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(keyDarkMode);
  }

  static Future<void> setDarkMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(keyDarkMode, isDarkMode);
  }
}
