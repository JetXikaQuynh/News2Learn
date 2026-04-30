// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'vocab_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VocabModelAdapter extends TypeAdapter<VocabModel> {
  @override
  final int typeId = 0;

  @override
  VocabModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VocabModel(
      word: fields[0] as String,
      meaning: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VocabModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.meaning);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
