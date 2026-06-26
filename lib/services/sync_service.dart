import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive/hive.dart';

import '../models/bookmark_model.dart';
import '../models/quiz_result_model.dart';
import '../models/user_vocab_model.dart';
import '../models/vocab_model.dart';

import 'firestore_service.dart';
import 'hive_service.dart';

class SyncService {
  SyncService._();

  static final SyncService instance = SyncService._();

  final Connectivity connectivity = Connectivity();

  /// Kiểm tra kết nối mạng
  Future<bool> isConnected() async {
    final result = await connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  /// Đồng bộ lên Cloud khi có thay đổi (Upload)
  Future<void> syncToCloud() async {
    if (!await isConnected()) {
      print("⚠️ Không có kết nối mạng, dữ liệu sẽ được lưu cục bộ");
      return;
    }

    try {
      await syncVocabulary();
      await syncBookmarks();
      await syncQuizResults();
      print("✅ Đồng bộ lên Cloud thành công");
    } catch (e) {
      print("❌ Lỗi khi đồng bộ lên Cloud: $e");
    }
  }

  /// Tải dữ liệu từ Cloud xuống (Download) - dùng khi đăng nhập
  Future<void> syncFromCloud() async {
    if (!await isConnected()) {
      print("⚠️ Không có kết nối mạng, không thể tải dữ liệu từ Cloud");
      return;
    }

    try {
      await FirestoreService.instance.downloadAll();
      print("✅ Tải dữ liệu từ Cloud thành công");
    } catch (e) {
      print("❌ Lỗi khi tải dữ liệu từ Cloud: $e");
    }
  }

  Future<void> syncVocabulary() async {
    final vocabBox = HiveService.instance.vocabBox;

    final progressBox = HiveService.instance.userVocabBox;

    for (VocabModel vocab in vocabBox.values) {
      final progress = progressBox.values.firstWhere(
        (e) => e.vocabId == vocab.vocabId,

        orElse: () => UserVocabModel(
          uvId: vocab.vocabId,

          userId: HiveService.instance.uid,

          vocabId: vocab.vocabId,

          createdAt: DateTime.now(),
        ),
      );

      await FirestoreService.instance.uploadVocabulary(vocab, progress);
    }

    print("Vocabulary Sync Completed");
  }

  Future<void> syncBookmarks() async {
    final bookmarkBox = HiveService.instance.bookmarkBox;

    for (BookmarkModel bookmark in bookmarkBox.values) {
      await FirestoreService.instance.uploadBookmark(bookmark);
    }

    print("Bookmark Sync Completed");
  }

  Future<void> syncQuizResults() async {
    final quizBox = HiveService.instance.quizResultBox;

    for (QuizResultModel quiz in quizBox.values) {
      await FirestoreService.instance.uploadQuizResult(quiz);
    }

    print("Quiz Sync Completed");
  }

  /// Lắng nghe thay đổi kết nối mạng
  Stream<ConnectivityResult> get connectivityStream =>
      connectivity.onConnectivityChanged;
}
