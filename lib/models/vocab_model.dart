import 'package:hive/hive.dart';

part 'vocab_model.g.dart';

@HiveType(typeId: 0)
class VocabModel extends HiveObject {
  @HiveField(0)
  String word;

  @HiveField(1)
  String meaning;

  VocabModel({required this.word, required this.meaning});
  @override
  String toString() {
    return 'VocabModel(word: $word, meaning: $meaning)';
  }
}
