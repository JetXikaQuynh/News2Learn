import 'package:hive/hive.dart';

part 'quiz_result_model.g.dart';

@HiveType(typeId: 4)
class QuizResultModel extends HiveObject {
  @HiveField(0)
  String qrId;

  @HiveField(1)
  String userId;

  @HiveField(2)
  int score;

  @HiveField(3)
  int totalQuestions;

  @HiveField(4)
  int correctCount;

  @HiveField(5)
  DateTime createdAt;

  QuizResultModel({
    required this.qrId,
    required this.userId,
    required this.score,
    required this.totalQuestions,
    required this.correctCount,
    required this.createdAt,
  });
}
