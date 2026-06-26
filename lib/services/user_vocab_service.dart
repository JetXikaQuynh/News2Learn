import '../models/user_vocab_model.dart';
import 'hive_service.dart';
import 'sync_service.dart';

class UserVocabService {
  get box => HiveService.instance.userVocabBox;

  /// Lấy progress của một từ
  UserVocabModel? getProgress(String vocabId) {
    try {
      return box.values.firstWhere((e) => e.vocabId == vocabId);
    } catch (_) {
      return null;
    }
  }

  /// Đánh dấu từ đã học
  Future<void> markAsLearned(String vocabId) async {
    final progress = getProgress(vocabId);
    if (progress != null) {
      progress.isLearned = true;
      await progress.save();
      await SyncService.instance.syncToCloud();
    }
  }

  /// Cập nhật lần review cuối
  Future<void> updateReviewDate(String vocabId) async {
    final progress = getProgress(vocabId);
    if (progress != null) {
      progress.lastReviewed = DateTime.now();
      progress.reviewCount = (progress.reviewCount ?? 0) + 1;
      await progress.save();
      await SyncService.instance.syncToCloud();
    }
  }

  /// Lên lịch review tiếp theo (Spaced Repetition)
  Future<void> scheduleNextReview(String vocabId, int daysLater) async {
    final progress = getProgress(vocabId);
    if (progress != null) {
      progress.nextReview = DateTime.now().add(Duration(days: daysLater));
      await progress.save();
      await SyncService.instance.syncToCloud();
    }
  }

  /// Lấy danh sách từ cần review
  List<UserVocabModel> getWordsNeedReview() {
    final now = DateTime.now();
    return box.values
        .where(
          (e) =>
              e.nextReview != null &&
              e.nextReview!.isBefore(now) &&
              !e.isLearned,
        )
        .toList();
  }

  /// Lấy thống kê học tập
  Map<String, dynamic> getStatistics() {
    final allVocabs = box.values.toList();
    return {
      'total': allVocabs.length,
      'learned': allVocabs.where((e) => e.isLearned).length,
      'needReview': getWordsNeedReview().length,
      'totalReviews': allVocabs.fold<int>(
        0,
        (sum, e) => sum + (e.reviewCount ?? 0),
      ),
    };
  }
}
