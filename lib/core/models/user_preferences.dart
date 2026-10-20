import 'package:hive/hive.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_preferences.freezed.dart';
part 'user_preferences.g.dart';

@freezed
@HiveType(typeId: 0)
class UserPreferences with _$UserPreferences {
  const factory UserPreferences({
    @HiveField(0) @Default(false) bool isDarkMode,
    @HiveField(1) @Default('en') String locale,
    @HiveField(2) @Default(1.0) double textScale,
    @HiveField(3) @Default('NotoSerif') String fontFamily,
    @HiveField(4) @Default(true) bool notificationsEnabled,
    @HiveField(5) @Default('07:00') String dailyReminderTime,
    @HiveField(6) @Default(true) bool dailyReminderEnabled,
    @HiveField(7) @Default([]) List<String> favoriteVerses,
    @HiveField(8) @Default([]) List<String> completedPlans,
    @HiveField(9) @Default(0) int currentStreak,
    @HiveField(10) @Default(0) int longestStreak,
    @HiveField(11) @Default({}) Map<String, dynamic> planProgress,
    @HiveField(12) @Default('ASV') String preferredBibleVersion,
    @HiveField(13) @Default(true) bool autoPlayAudio,
    @HiveField(14) @Default(1.0) double audioPlaybackSpeed,
    @HiveField(15) @Default(false) bool isProUser, // Always true in this version - no license checks!
  }) = _UserPreferences;

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
}

@HiveType(typeId: 1)
class UserPreferencesAdapter extends TypeAdapter<UserPreferences> {
  @override
  final int typeId = 1;

  @override
  UserPreferences read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numFields; i++)
        reader.readByte(): reader.read(),
    };
    return UserPreferences(
      isDarkMode: fields[0] as bool? ?? false,
      locale: fields[1] as String? ?? 'en',
      textScale: fields[2] as double? ?? 1.0,
      fontFamily: fields[3] as String? ?? 'NotoSerif',
      notificationsEnabled: fields[4] as bool? ?? true,
      dailyReminderTime: fields[5] as String? ?? '07:00',
      dailyReminderEnabled: fields[6] as bool? ?? true,
      favoriteVerses: (fields[7] as List?)?.cast<String>() ?? [],
      completedPlans: (fields[8] as List?)?.cast<String>() ?? [],
      currentStreak: fields[9] as int? ?? 0,
      longestStreak: fields[10] as int? ?? 0,
      planProgress: (fields[11] as Map?)?.cast<String, dynamic>() ?? {},
      preferredBibleVersion: fields[12] as String? ?? 'ASV',
      autoPlayAudio: fields[13] as bool? ?? true,
      audioPlaybackSpeed: fields[14] as double? ?? 1.0,
      isProUser: fields[15] as bool? ?? true,
    );
  }

  @override
  void write(BinaryWriter writer, UserPreferences obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.isDarkMode)
      ..writeByte(1)
      ..write(obj.locale)
      ..writeByte(2)
      ..write(obj.textScale)
      ..writeByte(3)
      ..write(obj.fontFamily)
      ..writeByte(4)
      ..write(obj.notificationsEnabled)
      ..writeByte(5)
      ..write(obj.dailyReminderTime)
      ..writeByte(6)
      ..write(obj.dailyReminderEnabled)
      ..writeByte(7)
      ..write(obj.favoriteVerses)
      ..writeByte(8)
      ..write(obj.completedPlans)
      ..writeByte(9)
      ..write(obj.currentStreak)
      ..writeByte(10)
      ..write(obj.longestStreak)
      ..writeByte(11)
      ..write(obj.planProgress)
      ..writeByte(12)
      ..write(obj.preferredBibleVersion)
      ..writeByte(13)
      ..write(obj.autoPlayAudio)
      ..writeByte(14)
      ..write(obj.audioPlaybackSpeed)
      ..writeByte(15)
      ..write(obj.isProUser);
  }
}