// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizResultModelAdapter extends TypeAdapter<QuizResultModel> {
  @override
  final int typeId = 4;

  @override
  QuizResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizResultModel(
      qrId: fields[0] as String,
      userId: fields[1] as String,
      score: fields[2] as int,
      totalQuestions: fields[3] as int,
      correctCount: fields[4] as int,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizResultModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.qrId)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.totalQuestions)
      ..writeByte(4)
      ..write(obj.correctCount)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
