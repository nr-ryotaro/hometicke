import 'package:hive/hive.dart';
import 'package:flutter/material.dart';

part 'letter_settings.g.dart';

@HiveType(typeId: 3)
class LetterSettings extends HiveObject {
  @HiveField(0)
  final int notificationHour;

  @HiveField(1)
  final int notificationMinute;

  @HiveField(2)
  final DateTime? lastShownDate;

  LetterSettings({
    this.notificationHour = 22,
    this.notificationMinute = 0,
    this.lastShownDate,
  });

  TimeOfDay get notificationTime {
    return TimeOfDay(hour: notificationHour, minute: notificationMinute);
  }

  LetterSettings copyWith({
    int? notificationHour,
    int? notificationMinute,
    DateTime? lastShownDate,
  }) {
    return LetterSettings(
      notificationHour: notificationHour ?? this.notificationHour,
      notificationMinute: notificationMinute ?? this.notificationMinute,
      lastShownDate: lastShownDate ?? this.lastShownDate,
    );
  }
}
