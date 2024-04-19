// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Settings _$SettingsFromJson(Map<String, dynamic> json) => Settings(
      isDarkTheme: json['theme'] as bool,
      serverUrl: json['serverUrl'] as String,
    );

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'theme': instance.isDarkTheme,
      'serverUrl': instance.serverUrl,
    };
