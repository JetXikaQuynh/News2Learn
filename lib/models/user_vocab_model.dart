import 'package:hive/hive.dart';

part 'user_vocab_model.g.dart';

@HiveType(typeId: 3)
class UserVocabModel extends HiveObject {
  @HiveField(0)
  String uvId;

  @HiveField(1)
  String userId;

  @HiveField(2)
  String vocabId;

  @HiveField(3)
  bool isSaved;

  @HiveField(4)
  bool isLearned;

  @HiveField(5)
  int reviewCount;

  @HiveField(6)
  DateTime? lastReviewed;

  @HiveField(7)
  DateTime? nextReview;

  @HiveField(8)
  DateTime createdAt;

  UserVocabModel({
    required this.uvId,
    required this.userId,
    required this.vocabId,
    this.isSaved = true,
    this.isLearned = false,
    this.reviewCount = 0,
    this.lastReviewed,
    this.nextReview,
    required this.createdAt,
  });
}
