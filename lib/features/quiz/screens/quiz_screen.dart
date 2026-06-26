import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/quiz_result_model.dart';
import '../../../models/user_vocab_model.dart';
import '../../../models/vocab_model.dart';
import '../../../shared/theme/design_tokens.dart';

import '../widgets/quiz_body.dart';
import '../screens/quiz_result_srceen.dart';
import '../../../services/hive_service.dart';
import '../../../services/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<VocabModel> allWords = [];
  List<VocabModel> quizWords = [];

  int currentQuestion = 0;
  int score = 0;

  bool answered = false;
  int? selectedIndex;
  int correctIndex = 0;

  List<String> options = [];

  @override
  void initState() {
    super.initState();

    final box = HiveService.instance.vocabBox;
    allWords = box.values.toList();

    generateQuiz();
  }

  void generateQuiz() {
    if (allWords.isEmpty) return;

    allWords.shuffle();

    quizWords = allWords.take(min(30, allWords.length)).toList();

    currentQuestion = 0;
    score = 0;

    loadQuestion();
  }

  void loadQuestion() {
    answered = false;
    selectedIndex = null;

    final currentWord = quizWords[currentQuestion];

    List<String> wrongAnswers = allWords
        .where((e) => e.word != currentWord.word)
        .map((e) => e.meaningVi)
        .toList();

    wrongAnswers.shuffle();

    options = [currentWord.meaningVi, ...wrongAnswers.take(3)];

    options.shuffle();

    correctIndex = options.indexOf(currentWord.meaningVi);

    setState(() {});
  }

  void selectAnswer(int index) {
    if (answered) return;

    answered = true;
    selectedIndex = index;

    final currentVocab = quizWords[currentQuestion];

    final uvBox = HiveService.instance.userVocabBox;

    final existingIndex = uvBox.values.toList().indexWhere(
      (e) => e.vocabId == currentVocab.vocabId,
    );

    if (index == correctIndex) {
      score++;

      if (existingIndex >= 0) {
        final old = uvBox.getAt(existingIndex)!;

        uvBox.putAt(
          existingIndex,
          UserVocabModel(
            uvId: old.uvId,
            userId: old.userId,
            vocabId: old.vocabId,
            isSaved: true,
            isLearned: true,
            reviewCount: old.reviewCount + 1,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now().add(const Duration(days: 3)),
            createdAt: old.createdAt,
          ),
        );
      }
    } else {
      if (existingIndex >= 0) {
        final old = uvBox.getAt(existingIndex)!;

        uvBox.putAt(
          existingIndex,
          UserVocabModel(
            uvId: old.uvId,
            userId: old.userId,
            vocabId: old.vocabId,
            isSaved: true,
            isLearned: false,
            reviewCount: old.reviewCount,
            lastReviewed: DateTime.now(),
            nextReview: DateTime.now().add(const Duration(days: 1)),
            createdAt: old.createdAt,
          ),
        );
      }
    }

    setState(() {});
  }

  void nextQuestion() {
    if (currentQuestion < quizWords.length - 1) {
      currentQuestion++;
      loadQuestion();
    } else {
      saveQuizResult();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => QuizResultScreen(
            score: score,
            totalQuestions: quizWords.length,
            onRestart: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const QuizScreen()),
              );
            },
          ),
        ),
      );
    }
  }

  Future<void> saveQuizResult() async {
    final quizService = QuizService();
    final userId = FirebaseAuth.instance.currentUser?.uid ?? "guest_user";

    await quizService.saveQuizResult(
      QuizResultModel(
        qrId: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        score: score,
        totalQuestions: quizWords.length,
        correctCount: score,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (allWords.length < 4) {
      return Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.pastelBackgroundGradient,
        ),
        child: const Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz_outlined, size: 72, color: Color(0xFFCBD5E1)),
                SizedBox(height: 16),
                Text(
                  "Cần ít nhất 4 từ vựng để làm Quiz",
                  style: TextStyle(
                    fontSize: 18,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final vocab = quizWords[currentQuestion];

    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: QuizBody(
          vocab: vocab,
          currentQuestion: currentQuestion,
          totalQuestions: quizWords.length,
          score: score,
          options: options,
          answered: answered,
          selectedIndex: selectedIndex,
          correctIndex: correctIndex,
          onSelectAnswer: selectAnswer,
          onNextQuestion: nextQuestion,
        ),
      ),
    );
  }
}
