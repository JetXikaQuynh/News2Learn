import '../models/quiz_result_model.dart';
import 'hive_service.dart';
import 'sync_service.dart';

class QuizService {
  get box => HiveService.instance.quizResultBox;

  /// Lưu kết quả quiz
  Future<void> saveQuizResult(QuizResultModel result) async {
    await box.add(result);
    // Đồng bộ lên cloud nếu có kết nối
    await SyncService.instance.syncToCloud();
  }

  /// Lấy tất cả kết quả quiz
  List<QuizResultModel> getAllResults() {
    return box.values.toList();
  }

  /// Lấy kết quả theo ngày
  List<QuizResultModel> getResultsByDate(DateTime date) {
    return box.values
        .where(
          (e) =>
              e.createdAt.year == date.year &&
              e.createdAt.month == date.month &&
              e.createdAt.day == date.day,
        )
        .toList();
  }

  /// Tính điểm trung bình
  double getAverageScore() {
    if (box.isEmpty) return 0;
    final scores = box.values.map((e) => e.score).toList();
    return scores.reduce((a, b) => a + b) / scores.length;
  }

  /// Lấy thống kê
  Map<String, dynamic> getStatistics() {
    final results = box.values.toList();
    if (results.isEmpty) {
      return {
        'totalAttempts': 0,
        'averageScore': 0,
        'bestScore': 0,
        'totalQuestions': 0,
        'correctAnswers': 0,
      };
    }

    final scores = results.map((e) => e.score).toList();
    final correctAnswers = results.fold<int>(
      0,
      (sum, e) => sum + e.correctCount,
    );
    final totalQuestions = results.fold<int>(
      0,
      (sum, e) => sum + e.totalQuestions,
    );

    return {
      'totalAttempts': results.length,
      'averageScore': scores.reduce((a, b) => a + b) / scores.length,
      'bestScore': scores.reduce((a, b) => a > b ? a : b),
      'totalQuestions': totalQuestions,
      'correctAnswers': correctAnswers,
    };
  }
}
