import 'package:flutter/material.dart';
import '../../../shared/theme/design_tokens.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;
  final VoidCallback onRestart;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.onRestart,
  });

  @override
  Widget build(BuildContext context) {
    final percent = totalQuestions > 0
        ? ((score / totalQuestions) * 100).round()
        : 0;
    final isPassed = percent >= 70;

    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: DesignTokens.softShadow,
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: Color(0xFF8B5CF6),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Kết quả bài Quiz",
                      style: DesignTokens.headingStyle.copyWith(
                        fontSize: 28,
                        letterSpacing: -0.5,
                        foreground: Paint()
                          ..shader = DesignTokens.primaryAccentGradient
                              .createShader(
                                const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: DesignTokens.softShadow,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color:
                                  (isPassed
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFFF1F5F9))
                                      .withValues(alpha: 0.5),
                            ),
                          ),
                          Container(
                            width: 110,
                            height: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: isPassed
                                    ? [
                                        const Color(0xFFFDE68A),
                                        const Color(0xFFF59E0B),
                                      ]
                                    : [
                                        const Color(0xFFE2E8F0),
                                        const Color(0xFF94A3B8),
                                      ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (isPassed
                                              ? const Color(0xFFF59E0B)
                                              : const Color(0xFF94A3B8))
                                          .withValues(alpha: 0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                          ),
                          // Trophy icon
                          Icon(
                            isPassed
                                ? Icons.emoji_events_rounded
                                : Icons.sentiment_neutral_rounded,
                            size: 60,
                            color: Colors.white,
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Text(
                        isPassed ? "Congratulations! 🎉" : "Keep Learning! 💪",
                        style: DesignTokens.headingStyle.copyWith(
                          fontSize: 22,
                          color: isPassed
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Bạn đã hoàn thành bài kiểm tra!",
                        style: DesignTokens.bodyStyle.copyWith(
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tỷ lệ chính xác",
                                style: DesignTokens.bodyStyle.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF475569),
                                ),
                              ),
                              Text(
                                "$percent%",
                                style: DesignTokens.subheadingStyle.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isPassed
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFFF59E0B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Stack(
                            children: [
                              Container(
                                height: 12,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                height: 12,
                                width:
                                    (MediaQuery.of(context).size.width - 96) *
                                    (percent / 100),
                                decoration: BoxDecoration(
                                  gradient: isPassed
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF10B981),
                                            Color(0xFF34D399),
                                          ],
                                        )
                                      : const LinearGradient(
                                          colors: [
                                            Color(0xFFF59E0B),
                                            Color(0xFFFBBF24),
                                          ],
                                        ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.task_alt_rounded,
                                    color: Color(0xFF10B981),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Số câu đúng",
                                    style: DesignTokens.bodyStyle.copyWith(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "$score / $totalQuestions",
                                    style: DesignTokens.subheadingStyle
                                        .copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF1E293B),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 16,
                                horizontal: 12,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFF1F5F9),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    isPassed
                                        ? Icons.verified_rounded
                                        : Icons.star_half_rounded,
                                    color: const Color(0xFF8B5CF6),
                                    size: 20,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Kết quả",
                                    style: DesignTokens.bodyStyle.copyWith(
                                      fontSize: 12,
                                      color: const Color(0xFF64748B),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    isPassed ? "ĐẠT" : "CẦN CỐ GẮNG",
                                    style: DesignTokens.subheadingStyle
                                        .copyWith(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isPassed
                                              ? const Color(0xFF10B981)
                                              : const Color(0xFFF59E0B),
                                        ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),

                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isPassed
                              ? const Color(0xFFECFDF5)
                              : const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isPassed
                                ? const Color(0xFFD1FAE5)
                                : const Color(0xFFFEF3C7),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              isPassed ? "🔥" : "💪",
                              style: const TextStyle(fontSize: 24),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                isPassed
                                    ? "Xuất sắc! Bạn nhớ từ rất tốt! Bạn đã vượt qua bài thi."
                                    : "Hãy tiếp tục học tập! Bạn sẽ tiến bộ hơn trong bài quiz sau.",
                                style: DesignTokens.bodyStyle.copyWith(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isPassed
                                      ? const Color(0xFF065F46)
                                      : const Color(0xFF92400E),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: DesignTokens.primaryAccentGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: DesignTokens.accentShadow,
                        ),
                        child: ElevatedButton.icon(
                          onPressed: onRestart,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                          label: const Text("Làm bài Quiz mới"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            textStyle: DesignTokens.subheadingStyle.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
