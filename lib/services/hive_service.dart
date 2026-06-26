import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/bookmark_model.dart';
import '../models/vocab_model.dart';
import '../models/user_model.dart';
import '../models/user_vocab_model.dart';
import '../models/quiz_result_model.dart';

class HiveService {
  static final HiveService instance = HiveService._();

  HiveService._();

  String get uid {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception("User chưa đăng nhập.");
    }

    return user.uid;
  }

  Future<void> openUserBoxes() async {
    if (!Hive.isBoxOpen("userBox_$uid")) {
      await Hive.openBox<UserModel>("userBox_$uid");
    }

    if (!Hive.isBoxOpen("vocabBox_$uid")) {
      await Hive.openBox<VocabModel>("vocabBox_$uid");
    }

    if (!Hive.isBoxOpen("bookmarkBox_$uid")) {
      await Hive.openBox<BookmarkModel>("bookmarkBox_$uid");
    }

    if (!Hive.isBoxOpen("userVocabBox_$uid")) {
      await Hive.openBox<UserVocabModel>("userVocabBox_$uid");
    }

    if (!Hive.isBoxOpen("quizResultBox_$uid")) {
      await Hive.openBox<QuizResultModel>("quizResultBox_$uid");
    }
  }

  Future<void> closeUserBoxes() async {
    if (Hive.isBoxOpen("userBox_$uid")) {
      await Hive.box<UserModel>("userBox_$uid").close();
    }

    if (Hive.isBoxOpen("vocabBox_$uid")) {
      await Hive.box<VocabModel>("vocabBox_$uid").close();
    }

    if (Hive.isBoxOpen("bookmarkBox_$uid")) {
      await Hive.box<BookmarkModel>("bookmarkBox_$uid").close();
    }

    if (Hive.isBoxOpen("userVocabBox_$uid")) {
      await Hive.box<UserVocabModel>("userVocabBox_$uid").close();
    }

    if (Hive.isBoxOpen("quizResultBox_$uid")) {
      await Hive.box<QuizResultModel>("quizResultBox_$uid").close();
    }
  }

  Box<UserModel> get userBox => Hive.box<UserModel>("userBox_$uid");

  Box<VocabModel> get vocabBox => Hive.box<VocabModel>("vocabBox_$uid");

  Box<BookmarkModel> get bookmarkBox =>
      Hive.box<BookmarkModel>("bookmarkBox_$uid");

  Box<UserVocabModel> get userVocabBox =>
      Hive.box<UserVocabModel>("userVocabBox_$uid");

  Box<QuizResultModel> get quizResultBox =>
      Hive.box<QuizResultModel>("quizResultBox_$uid");
}
