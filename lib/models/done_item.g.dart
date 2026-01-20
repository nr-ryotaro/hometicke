// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'done_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DoneItemAdapter extends TypeAdapter<DoneItem> {
  @override
  final int typeId = 0;

  @override
  DoneItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DoneItem(
      id: fields[0] as String,
      text: fields[1] as String,
      createdAt: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DoneItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoneItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
