import '../models/vocab_model.dart';
import 'hive_service.dart';
import 'sync_service.dart';

class VocabService {
  get box => HiveService.instance.vocabBox;

  bool isSaved(String word) {
    return box.values.any((e) => e.word == word);
  }

  /// Lưu từ vựng và sync
  Future<void> saveWord(VocabModel vocab) async {
    if (!isSaved(vocab.word)) {
      box.add(vocab);
      // Đồng bộ lên cloud nếu có kết nối
      await SyncService.instance.syncToCloud();
    }
  }

  /// Xóa từ vựng và sync
  Future<void> deleteWord(int index) async {
    await box.deleteAt(index);
    await SyncService.instance.syncToCloud();
  }
}
