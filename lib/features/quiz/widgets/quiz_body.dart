import 'package:flutter/material.dart';
import '../../../models/vocab_model.dart';
import '../../../shared/theme/design_tokens.dart';

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
    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TITLE
              Text(
                "Quiz",
                style: DesignTokens.headingStyle.copyWith(
                  fontSize: 28,
                  foreground: Paint()
                    ..shader = DesignTokens.primaryAccentGradient.createShader(
                      const Rect.fromLTWH(0, 0, 150, 70),
                    ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Trắc nghiệm kiểm tra từ vựng",
                style: DesignTokens.bodyStyle,
              ),
              const SizedBox(height: 24),

              // PROGRESS ROW
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Câu ${currentQuestion + 1}/$totalQuestions",
                    style: DesignTokens.subheadingStyle.copyWith(
                        color: const Color(0xFF334155), fontSize: 16),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryAccentGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: DesignTokens.accentShadow,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "$score điểm",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // PROGRESS BAR
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: DesignTokens.softShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (currentQuestion + 1) / totalQuestions,
                    backgroundColor: Colors.transparent,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6)),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // QUESTION CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: DesignTokens.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Nghĩa của từ dưới đây là gì?",
                      style: DesignTokens.bodyStyle.copyWith(
                        fontSize: 14,
                        color: Colors.grey.shade500,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          vocab.word,
                          style: DesignTokens.headingStyle.copyWith(
                            fontSize: 36,
                            foreground: Paint()
                              ..shader =
                                  DesignTokens.primaryAccentGradient
                                      .createShader(
                                const Rect.fromLTWH(0, 0, 200, 50),
                              ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            vocab.phonetic,
                            style: DesignTokens.bodyStyle.copyWith(
                                color: Colors.grey.shade400),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ANSWER OPTIONS
              ...List.generate(options.length, (index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: GestureDetector(
                    onTap: () => onSelectAnswer(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getOptionColor(index),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _getBorderColor(index),
                          width: 2,
                        ),
                        boxShadow: answered && index == correctIndex
                            ? [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha: 0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : DesignTokens.softShadow,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: _getCircleColor(index),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                String.fromCharCode(65 + index),
                                style: TextStyle(
                                  color: _getCircleTextColor(index),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              options[index],
                              style: DesignTokens.bodyStyle.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: const Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          if (answered && index == correctIndex)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.green.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check,
                                  color: Colors.white, size: 16),
                            ),
                          if (answered &&
                              selectedIndex == index &&
                              index != correctIndex)
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close,
                                  color: Colors.white, size: 16),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              const SizedBox(height: 8),

              // FEEDBACK
              if (answered && selectedIndex == correctIndex)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      const Text("🎉", style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Text(
                        "Tuyệt vời! Câu trả lời chính xác!",
                        style: DesignTokens.bodyStyle.copyWith(
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (answered && selectedIndex != correctIndex)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      const Text("💡", style: TextStyle(fontSize: 22)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Đáp án đúng: ${options[correctIndex]}",
                          style: DesignTokens.bodyStyle.copyWith(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              if (answered)
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryAccentGradient,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: DesignTokens.accentShadow,
                    ),
                    child: ElevatedButton(
                      onPressed: onNextQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text(
                        "Tiếp tục →",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Color _getOptionColor(int index) {
    if (!answered) return Colors.white;
    if (index == correctIndex) return Colors.green.shade50;
    if (selectedIndex == index && index != correctIndex) {
      return Colors.red.shade50;
    }
    return Colors.white;
  }

  Color _getBorderColor(int index) {
    if (!answered) return Colors.grey.shade200;
    if (index == correctIndex) return Colors.green.shade400;
    if (selectedIndex == index && index != correctIndex) {
      return Colors.red.shade400;
    }
    return Colors.grey.shade200;
  }

  Color _getCircleColor(int index) {
    if (!answered) return const Color(0xFFF1F5F9);
    if (index == correctIndex) return Colors.green.shade400;
    if (selectedIndex == index && index != correctIndex) {
      return Colors.red.shade400;
    }
    return const Color(0xFFF1F5F9);
  }

  Color _getCircleTextColor(int index) {
    if (!answered) return const Color(0xFF475569);
    if (index == correctIndex) return Colors.white;
    if (selectedIndex == index && index != correctIndex) return Colors.white;
    return const Color(0xFF475569);
  }
}
