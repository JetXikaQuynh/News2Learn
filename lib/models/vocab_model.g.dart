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
      vocabId: fields[0] as String,
      word: fields[1] as String,
      meaningVi: fields[2] as String,
      phonetic: fields[3] as String,
      example: fields[4] as String,
      pronunciation: fields[5] as String?,
      partOfSpeech: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VocabModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.vocabId)
      ..writeByte(1)
      ..write(obj.word)
      ..writeByte(2)
      ..write(obj.meaningVi)
      ..writeByte(3)
      ..write(obj.phonetic)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.pronunciation)
      ..writeByte(6)
      ..write(obj.partOfSpeech);
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
