import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../models/vocab_model.dart';
import '../../../shared/theme/design_tokens.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<VocabModel>('vocabBox');
    final player = AudioPlayer();

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
                Text(
                  "Từ vựng của tôi",
                  style: DesignTokens.headingStyle.copyWith(
                    fontSize: 28,
                    foreground: Paint()
                      ..shader =
                          DesignTokens.primaryAccentGradient.createShader(
                        const Rect.fromLTWH(0.0, 0.0, 250.0, 70.0),
                      ),
                  ),
                ),
                const SizedBox(height: 6),
                ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, Box<VocabModel> box, _) {
                    final count = box.values.length;
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            gradient: DesignTokens.primaryAccentGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "$count từ",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "đã lưu trong kho từ vựng",
                          style: DesignTokens.bodyStyle,
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // WORD LIST
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: box.listenable(),
                    builder: (context, Box<VocabModel> box, _) {
                      final vocabList = box.values.toList();

                      if (vocabList.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.book_outlined,
                                  size: 72, color: Colors.grey.shade300),
                              const SizedBox(height: 16),
                              Text(
                                "Chưa có từ nào",
                                style: DesignTokens.subheadingStyle.copyWith(
                                    color: Colors.grey.shade400),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Tìm kiếm từ trong từ điển và lưu lại nhé!",
                                style: DesignTokens.bodyStyle.copyWith(
                                    color: Colors.grey.shade400),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        itemCount: vocabList.length,
                        itemBuilder: (context, index) {
                          final vocab = vocabList[index];
                          return _buildItem(
                              context, vocab, index, player, box);
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItem(
    BuildContext context,
    VocabModel vocab,
    int index,
    AudioPlayer player,
    Box<VocabModel> box,
  ) {
    // Pick a subtle accent color per item
    final List<Color> accentColors = [
      const Color(0xFF3B82F6),
      const Color(0xFF8B5CF6),
      const Color(0xFF06B6D4),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];
    final accent = accentColors[index % accentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: DesignTokens.softShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              height: 60,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Word + POS + Audio
                  Row(
                    children: [
                      Text(
                        vocab.word,
                        style: DesignTokens.subheadingStyle.copyWith(
                          fontSize: 18,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          vocab.partOfSpeech,
                          style: TextStyle(
                            color: accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {
                          if (vocab.pronunciation != null &&
                              vocab.pronunciation!.isNotEmpty) {
                            await player.play(UrlSource(vocab.pronunciation!));
                          }
                        },
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.volume_up_rounded,
                              size: 17, color: accent),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),
                  Text(
                    vocab.phonetic,
                    style: DesignTokens.bodyStyle.copyWith(
                      color: const Color(0xFF8B5CF6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vocab.meaningVi,
                    style: DesignTokens.bodyStyle.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                ],
              ),
            ),

            // DELETE
            GestureDetector(
              onTap: () {
                box.deleteAt(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Đã xóa '${vocab.word}'"),
                    backgroundColor: const Color(0xFF8B5CF6),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                );
              },
              child: Container(
                width: 36,
                height: 36,
                margin: const EdgeInsets.only(left: 10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.delete_outline_rounded,
                    color: Colors.red.shade400, size: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
