// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'letter_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LetterSettingsAdapter extends TypeAdapter<LetterSettings> {
  @override
  final int typeId = 3;

  @override
  LetterSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return LetterSettings(
      notificationHour: fields[0] as int,
      notificationMinute: fields[1] as int,
      lastShownDate: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, LetterSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.notificationHour)
      ..writeByte(1)
      ..write(obj.notificationMinute)
      ..writeByte(2)
      ..write(obj.lastShownDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LetterSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
