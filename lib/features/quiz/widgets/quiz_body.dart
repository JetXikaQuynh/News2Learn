import 'package:flutter/material.dart';

import '../../../models/vocab_model.dart';

class QuizBody extends StatelessWidget {
  final VocabModel vocab;

  final int currentQuestion;
  final int totalQuestions;
  final int score;

  final List<String> options;

  final bool answered;
  final int? selectedIndex;
  final int correctIndex;

  final Function(int) onSelectAnswer;
  final VoidCallback onNextQuestion;

  const QuizBody({
    super.key,
    required this.vocab,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.score,
    required this.options,
    required this.answered,
    required this.selectedIndex,
    required this.correctIndex,
    required this.onSelectAnswer,
    required this.onNextQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
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
                "Trắc nghiệm kiểm tra từ vựng",
                style: TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Câu ${currentQuestion + 1}/$totalQuestions",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(
                    "Điểm: $score",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              LinearProgressIndicator(
                value: (currentQuestion + 1) / totalQuestions,
                backgroundColor: Colors.grey[300],
                color: Colors.deepOrange,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 35),

              const Text(
                "Nghĩa của từ dưới đây là gì?",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Row(
                children: [
                  Text(
                    vocab.word,
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Text(
                      vocab.phonetic,
                      style: const TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              ...List.generate(options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),

                  child: GestureDetector(
                    onTap: () => onSelectAnswer(index),

                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(15),

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
                                fontSize: 18,
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

              const SizedBox(height: 10),

              if (answered && selectedIndex == correctIndex)
                const Text(
                  "Tuyệt vời!",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 18,
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

              const SizedBox(height: 10),

              if (answered)
                Align(
                  alignment: Alignment.centerRight,

                  child: ElevatedButton(
                    onPressed: onNextQuestion,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),

                    child: const Text(
                      "Tiếp tục",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
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
