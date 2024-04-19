import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:settings_shared_api/settings_shared_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template settings_shared_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class SettingsSharedApi {
  /// {@macro settings_shared_api}
  SettingsSharedApi({
    required SharedPreferences plugin,
  }) : _plugin = plugin {
    _settings = _init();
  }

  final SharedPreferences _plugin;
  late Settings? _settings;

  Settings get settings => _settings!;

  @visibleForTesting
  static const kSettingsCollectionKey = '__settings_collection_key__';

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  Settings _init() {
    final settingsJson = _getValue(kSettingsCollectionKey);
    if (settingsJson != null) {
      final decodedSettings = jsonDecode(settingsJson) as Map<String, dynamic>;
      final settings = Settings.fromJson(decodedSettings);
      return settings;
    } else {
      return const Settings(isDarkTheme: false, serverUrl: '192.168.1.19:5001');
    }
  }

  Future<void> setSettings(Settings settings) async {
    await _setValue(kSettingsCollectionKey, jsonEncode(settings.toJson()));
    _settings = settings;
  }

  Future<void> updateServerUrl(String serverUrl) async {
    final settings = _settings!.copyWith(serverUrl: serverUrl);
    await setSettings(settings);
  }
}
