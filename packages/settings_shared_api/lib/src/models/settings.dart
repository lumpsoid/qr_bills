import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

part 'settings.g.dart';

@immutable
@JsonSerializable()
class Settings extends Equatable {
  const Settings({
    required this.isDarkTheme,
    required this.serverUrl,
  });

  /// Connect the generated [_$PersonFromJson] function to the `fromJson`
  /// factory.
  factory Settings.fromJson(Map<String, dynamic> json) =>
      _$SettingsFromJson(json);

  final bool isDarkTheme;
  final String serverUrl;

  Settings copyWith({
    bool? isDarkTheme,
    String? serverUrl,
  }) {
    return Settings(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      serverUrl: serverUrl ?? this.serverUrl,
    );
  }

  /// Connect the generated [_$SettingsToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  @override
  List<Object> get props => [
        isDarkTheme,
        serverUrl,
      ];
}
