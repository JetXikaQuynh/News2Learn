import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/bookmark_model.dart';
import '../models/quiz_result_model.dart';
import '../models/user_vocab_model.dart';
import '../models/vocab_model.dart';
import 'hive_service.dart';

class FirestoreService {
  FirestoreService._();

  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  CollectionReference get users => firestore.collection("users");

  CollectionReference get vocabularies => firestore.collection("vocabularies");

  CollectionReference get bookmarks => firestore.collection("bookmarks");

  CollectionReference get quizResults => firestore.collection("quiz_results");

  Future<void> createUser({
    required String email,
    required String name,
    String avatar = "",
  }) async {
    await users.doc(uid).set({
      "uid": uid,
      "email": email,
      "name": name,
      "avatar": avatar,
      "created_at": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> uploadVocabulary(
    VocabModel vocab,
    UserVocabModel progress,
  ) async {
    await vocabularies.doc("${uid}_${vocab.vocabId}").set({
      "uid": uid,

      "vocabId": vocab.vocabId,

      "word": vocab.word,

      "meaning_vi": vocab.meaningVi,

      "phonetic": vocab.phonetic,

      "example": vocab.example,

      "pronunciation": vocab.pronunciation,

      "partOfSpeech": vocab.partOfSpeech,

      "isSaved": progress.isSaved,

      "isLearned": progress.isLearned,

      "reviewCount": progress.reviewCount,

      "lastReviewed": progress.lastReviewed,

      "nextReview": progress.nextReview,

      "created_at": progress.createdAt,
    });
  }

  Future<void> uploadBookmark(BookmarkModel bookmark) async {
    await bookmarks.doc(bookmark.bmId).set({
      "uid": uid,

      "bmId": bookmark.bmId,

      "articleId": bookmark.articleId,
    });
  }

  Future<void> uploadQuizResult(QuizResultModel quiz) async {
    await quizResults.doc(quiz.qrId).set({
      "uid": uid,

      "qrId": quiz.qrId,

      "score": quiz.score,

      "totalQuestions": quiz.totalQuestions,

      "correctCount": quiz.correctCount,

      "created_at": quiz.createdAt,
    });
  }

  Future<void> uploadAllVocabulary() async {
    final vocabBox = HiveService.instance.vocabBox;
    final progressBox = HiveService.instance.userVocabBox;

    for (final vocab in vocabBox.values) {
      UserVocabModel? progress;

      try {
        progress = progressBox.values.firstWhere(
          (e) => e.vocabId == vocab.vocabId,
        );
      } catch (_) {
        progress = UserVocabModel(
          uvId: "",
          userId: uid,
          vocabId: vocab.vocabId,
          isSaved: true,
          isLearned: false,
          reviewCount: 0,
          createdAt: DateTime.now(),
        );
      }

      await uploadVocabulary(vocab, progress);
    }
  }

  Future<void> uploadAllBookmarks() async {
    final box = HiveService.instance.bookmarkBox;

    for (final bookmark in box.values) {
      await uploadBookmark(bookmark);
    }
  }

  Future<void> uploadAllQuizResults() async {
    final box = HiveService.instance.quizResultBox;

    for (final quiz in box.values) {
      await uploadQuizResult(quiz);
    }
  }

  Future<void> uploadAll() async {
    await uploadAllVocabulary();

    await uploadAllBookmarks();

    await uploadAllQuizResults();
  }

  Future<void> downloadVocabulary() async {
    final snapshot = await vocabularies.where("uid", isEqualTo: uid).get();

    final vocabBox = HiveService.instance.vocabBox;
    final progressBox = HiveService.instance.userVocabBox;

    await vocabBox.clear();
    await progressBox.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      final vocab = VocabModel(
        vocabId: data["vocabId"],
        word: data["word"],
        meaningVi: data["meaning_vi"],
        phonetic: data["phonetic"] ?? "",
        example: data["example"] ?? "",
        pronunciation: data["pronunciation"],
        partOfSpeech: data["partOfSpeech"] ?? "",
      );

      await vocabBox.add(vocab);

      final progress = UserVocabModel(
        uvId: "${uid}_${vocab.vocabId}",
        userId: uid,
        vocabId: vocab.vocabId,
        isSaved: data["isSaved"] ?? true,
        isLearned: data["isLearned"] ?? false,
        reviewCount: data["reviewCount"] ?? 0,
        lastReviewed: (data["lastReviewed"] as Timestamp?)?.toDate(),
        nextReview: (data["nextReview"] as Timestamp?)?.toDate(),
        createdAt:
            (data["created_at"] as Timestamp?)?.toDate() ?? DateTime.now(),
      );

      await progressBox.add(progress);
    }
  }

  Future<void> downloadBookmarks() async {
    final snapshot = await bookmarks.where("uid", isEqualTo: uid).get();

    final box = HiveService.instance.bookmarkBox;

    await box.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      await box.add(
        BookmarkModel(
          bmId: data["bmId"],
          userId: uid,
          articleId: data["articleId"],
        ),
      );
    }
  }

  Future<void> downloadQuizResults() async {
    final snapshot = await quizResults.where("uid", isEqualTo: uid).get();

    final box = HiveService.instance.quizResultBox;

    await box.clear();

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      await box.add(
        QuizResultModel(
          qrId: data["qrId"],
          userId: uid,
          score: data["score"],
          totalQuestions: data["totalQuestions"],
          correctCount: data["correctCount"],
          createdAt: (data["created_at"] as Timestamp).toDate(),
        ),
      );
    }
  }

  Future<void> downloadAll() async {
    await downloadVocabulary();

    await downloadBookmarks();

    await downloadQuizResults();
  }
}
