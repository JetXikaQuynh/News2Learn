import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../../../models/vocab_model.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../services/hive_service.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen>
    with SingleTickerProviderStateMixin {
  final AudioPlayer player = AudioPlayer();

  int currentIndex = 0;
  bool showMeaning = false;

  List<VocabModel> flashcards = [];

  @override
  void initState() {
    super.initState();
    final box = HiveService.instance.vocabBox;
    flashcards = box.values.toList();
  }

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  void toggleCard() {
    setState(() {
      showMeaning =
          !showMeaning; //khi showMeaning = true thì hiển thị nghĩa, khi showMeaning = false thì hiển thị từ vựng
    });
  }

  void nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        showMeaning = false;
      });
    }
  }

  void prevCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showMeaning = false;
      });
    }
  }

  void shuffleCards() {
    setState(() {
      flashcards.shuffle();
      currentIndex = 0;
      showMeaning = false;
    });
  }

  void resetCards() {
    final box = HiveService.instance.vocabBox;
    setState(() {
      flashcards = box.values.toList();
      currentIndex = 0;
      showMeaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Container(
        decoration: const BoxDecoration(
          gradient: DesignTokens.pastelBackgroundGradient,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.style_rounded,
                  size: 72,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 20),
                Text(
                  "Chưa có thẻ flashcard",
                  style: DesignTokens.subheadingStyle.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hãy lưu từ vựng từ từ điển để bắt đầu!",
                  style: DesignTokens.bodyStyle.copyWith(
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (currentIndex >= flashcards.length) currentIndex = 0;
    final vocab = flashcards[currentIndex];
    final progress = (currentIndex + 1) / flashcards.length;

    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Flashcards",
                          style: DesignTokens.headingStyle.copyWith(
                            fontSize: 28,
                            foreground: Paint()
                              ..shader = DesignTokens.primaryAccentGradient
                                  .createShader(
                                    const Rect.fromLTWH(0, 0, 200, 70),
                                  ),
                          ),
                        ),
                        Text(
                          "Thẻ ${currentIndex + 1} / ${flashcards.length}",
                          style: DesignTokens.bodyStyle,
                        ),
                      ],
                    ),
                    // Controls
                    Row(
                      children: [
                        _buildControlBtn(
                          Icons.shuffle_rounded,
                          shuffleCards,
                          tooltip: "Xáo trộn",
                        ),
                        const SizedBox(width: 8),
                        _buildControlBtn(
                          Icons.refresh_rounded,
                          resetCards,
                          tooltip: "Làm mới",
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 16),

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
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF8B5CF6),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                Expanded(
                  child: GestureDetector(
                    onTap: toggleCard,
                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: showMeaning ? 1 : 0),
                      duration: const Duration(milliseconds: 450),
                      builder: (context, double value, child) {
                        final angle = value * pi;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: angle <= pi / 2
                              ? _buildFrontCard(vocab)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildBackCard(vocab),
                                ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildNavBtn(
                      icon: Icons.arrow_back_rounded,
                      label: "Trước",
                      onTap: prevCard,
                      enabled: currentIndex > 0,
                      isLeft: true,
                    ),
                    Row(
                      children: List.generate(
                        flashcards.length > 7 ? 7 : flashcards.length,
                        (i) {
                          final dotIndex = flashcards.length > 7
                              ? (currentIndex - 3 + i).clamp(
                                  0,
                                  flashcards.length - 1,
                                )
                              : i;
                          final isActive = dotIndex == currentIndex;
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            width: isActive ? 10 : 6,
                            height: isActive ? 10 : 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActive
                                  ? const Color(0xFF8B5CF6)
                                  : Colors.grey.shade300,
                            ),
                          );
                        },
                      ),
                    ),
                    _buildNavBtn(
                      icon: Icons.arrow_forward_rounded,
                      label: "Sau",
                      onTap: nextCard,
                      enabled: currentIndex < flashcards.length - 1,
                      isLeft: false,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlBtn(
    IconData icon,
    VoidCallback onTap, {
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: DesignTokens.softShadow,
          ),
          child: Icon(icon, size: 20, color: const Color(0xFF8B5CF6)),
        ),
      ),
    );
  }

  Widget _buildNavBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool enabled,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        opacity: enabled ? 1.0 : 0.3,
        duration: const Duration(milliseconds: 200),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: DesignTokens.softShadow,
          ),
          child: Row(
            children: isLeft
                ? [
                    Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: DesignTokens.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ]
                : [
                    Text(
                      label,
                      style: DesignTokens.bodyStyle.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(icon, color: const Color(0xFF8B5CF6), size: 20),
                  ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrontCard(VocabModel vocab) {
    return Container(
      key: const ValueKey("front"),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  gradient: DesignTokens.primaryAccentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (vocab.partOfSpeech).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      vocab.word,
                      style: DesignTokens.headingStyle.copyWith(fontSize: 40),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () async {
                      if (vocab.pronunciation != null &&
                          vocab.pronunciation!.isNotEmpty) {
                        await player.play(UrlSource(vocab.pronunciation!));
                      }
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.volume_up_rounded,
                        size: 22,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                vocab.phonetic,
                style: DesignTokens.bodyStyle.copyWith(
                  fontSize: 20,
                  color: const Color(0xFF8B5CF6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    "Nhấn để xem nghĩa",
                    style: DesignTokens.bodyStyle.copyWith(
                      color: Colors.grey.shade400,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackCard(VocabModel vocab) {
    return Container(
      key: const ValueKey("back"),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6D28D9), Color(0xFF3B82F6)],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Nghĩa Tiếng Việt",
                style: DesignTokens.bodyStyle.copyWith(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                vocab.meaningVi,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
