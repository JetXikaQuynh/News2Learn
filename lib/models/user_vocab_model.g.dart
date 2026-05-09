// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_vocab_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserVocabModelAdapter extends TypeAdapter<UserVocabModel> {
  @override
  final int typeId = 3;

  @override
  UserVocabModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserVocabModel(
      uvId: fields[0] as String,
      userId: fields[1] as String,
      vocabId: fields[2] as String,
      isSaved: fields[3] as bool,
      isLearned: fields[4] as bool,
      reviewCount: fields[5] as int,
      lastReviewed: fields[6] as DateTime?,
      nextReview: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, UserVocabModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.uvId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.vocabId)
      ..writeByte(3)
      ..write(obj.isSaved)
      ..writeByte(4)
      ..write(obj.isLearned)
      ..writeByte(5)
      ..write(obj.reviewCount)
      ..writeByte(6)
      ..write(obj.lastReviewed)
      ..writeByte(7)
      ..write(obj.nextReview)
      ..writeByte(8)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserVocabModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
