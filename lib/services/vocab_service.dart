import 'package:hive_flutter/hive_flutter.dart';
import '../models/vocab_model.dart';

class VocabService {
  final box = Hive.box<VocabModel>('vocabBox');

  bool isSaved(String word) {
    return box.values.any((e) => e.word == word);
  }

  void saveWord(VocabModel vocab) {
    if (!isSaved(vocab.word)) {
      box.add(vocab);
    }
  }
}
