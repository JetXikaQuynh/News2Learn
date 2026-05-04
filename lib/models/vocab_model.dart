import 'package:hive/hive.dart';

part 'vocab_model.g.dart';

@HiveType(typeId: 0)
class VocabModel extends HiveObject {
  @HiveField(0)
  String vocabId;

  @HiveField(1)
  String word;

  @HiveField(2)
  String meaningVi;

  @HiveField(3)
  String phonetic;

  @HiveField(4)
  String example;

  @HiveField(5)
  String? pronunciation;

  @HiveField(6)
  String partOfSpeech;

  VocabModel({
    required this.vocabId,
    required this.word,
    required this.meaningVi,
    required this.phonetic,
    required this.example,
    this.pronunciation,
    required this.partOfSpeech,
  });
}
