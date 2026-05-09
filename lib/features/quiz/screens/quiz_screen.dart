import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/vocab_model.dart';

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

    final box = Hive.box<VocabModel>('vocabBox');

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

    if (index == correctIndex) {
      score++;
    }

    setState(() {});
  }

  void nextQuestion() {
    if (currentQuestion < quizWords.length - 1) {
      currentQuestion++;
      loadQuestion();
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (allWords.length < 4) {
      return Scaffold(
        body: Center(
          child: Text(
            "Cần ít nhất 4 từ vựng để làm Quiz",
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

    final isFinished = currentQuestion >= quizWords.length - 1 && answered;

    if (isFinished) {
      return _buildResultScreen();
    }

    final vocab = quizWords[currentQuestion];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Image.asset("assets/LOGO1.png", height: 80),

              const Text(
                "Quiz",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Trắc nghiệm kiểm tra từ vựng, giúp bạn nhớ từ sâu hơn!",
                style: TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 40),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Câu ${currentQuestion + 1}/${quizWords.length}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  RichText(
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      children: [
                        const TextSpan(
                          text: "Điểm: ",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: "$score",
                          style: const TextStyle(color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: (currentQuestion + 1) / quizWords.length,
                backgroundColor: Colors.grey[300],
                color: Colors.deepOrange,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 35),

              const Text(
                "Nghĩa của từ dưới đây là gì?",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 18),

              Row(
                children: [
                  Text(
                    vocab.word,
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(vocab.phonetic, style: const TextStyle(fontSize: 20)),
                ],
              ),

              const SizedBox(height: 30),

              // OPTIONS
              ...List.generate(options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),

                  child: GestureDetector(
                    onTap: () => selectAnswer(index),

                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),

                      decoration: BoxDecoration(
                        color: getOptionColor(index),
                        borderRadius: BorderRadius.circular(14),

                        border: Border.all(
                          color: getBorderColor(index),
                          width: 1.5,
                        ),
                      ),

                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[300],

                            child: Text(
                              String.fromCharCode(65 + index),
                              style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(width: 14),

                          Expanded(
                            child: Text(
                              options[index],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          if (answered && index == correctIndex)
                            const Icon(Icons.check, color: Colors.green),

                          if (answered &&
                              selectedIndex == index &&
                              index != correctIndex)
                            const Icon(Icons.close, color: Colors.red),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 20),

              // MESSAGE
              if (answered && selectedIndex == correctIndex)
                const Text(
                  "Tuyệt vời!",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              if (answered && selectedIndex != correctIndex)
                Text(
                  "Sai rồi! Đáp án đúng là: ${options[correctIndex]}",
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              const Spacer(),

              // NEXT BUTTON
              if (answered)
                Align(
                  alignment: Alignment.centerRight,

                  child: ElevatedButton(
                    onPressed: nextQuestion,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 28,
                        vertical: 16,
                      ),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    child: const Text(
                      "Tiếp tục",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultScreen() {
    final percent = ((score / quizWords.length) * 100).round();

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            children: [
              Image.asset("assets/LOGO1.png", height: 80),

              const SizedBox(height: 20),

              const Text(
                "Quiz",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 60),

              const Icon(Icons.emoji_events, size: 120, color: Colors.amber),

              const SizedBox(height: 30),

              const Text(
                "Bạn đã hoàn thành bài kiểm tra!",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                "Điểm của bạn: $score/${quizWords.length} câu",
                style: const TextStyle(fontSize: 22),
              ),

              const SizedBox(height: 30),

              LinearProgressIndicator(
                value: percent / 100,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                minHeight: 14,
                borderRadius: BorderRadius.circular(20),
              ),

              const SizedBox(height: 25),

              Text(
                "$percent%",
                style: const TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),

              const SizedBox(height: 30),

              Text(
                percent >= 70
                    ? "Xuất sắc! Bạn nhớ từ rất tốt!"
                    : "Hãy tiếp tục học tập! Bạn sẽ tiến bộ hơn thôi!",

                style: TextStyle(
                  fontSize: 20,
                  color: percent >= 70 ? Colors.green : Colors.deepOrange,
                  fontWeight: FontWeight.w600,
                ),

                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 50),

              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    generateQuiz();
                  });
                },

                icon: const Icon(Icons.refresh, color: Colors.white),

                label: const Text(
                  "Làm bài Quiz mới",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,

                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 18,
                  ),

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getOptionColor(int index) {
    if (!answered) return Colors.white;

    if (index == correctIndex) {
      return Colors.green.withOpacity(0.15);
    }

    if (selectedIndex == index && index != correctIndex) {
      return Colors.red.withOpacity(0.12);
    }

    return Colors.white;
  }

  Color getBorderColor(int index) {
    if (!answered) return Colors.grey.shade300;

    if (index == correctIndex) {
      return Colors.green;
    }

    if (selectedIndex == index && index != correctIndex) {
      return Colors.red;
    }

    return Colors.grey.shade300;
  }
}
