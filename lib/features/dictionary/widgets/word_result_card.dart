import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../models/vocab_model.dart';
import '../../../shared/theme/design_tokens.dart';
import '../../../services/hive_service.dart';

class WordResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String word;

  const WordResultCard({super.key, required this.data, required this.word});

  @override
  Widget build(BuildContext context) {
    final box = HiveService.instance.vocabBox;
    final player = AudioPlayer();

    // Nhóm các nghĩa theo Part of Speech
    final Map<String, List<String>> groupedMeanings = {};
    for (var m in (data["meanings"] as List)) {
      String pos = m['pos'] ?? 'unknown';
      if (!groupedMeanings.containsKey(pos)) {
        groupedMeanings[pos] = [];
      }
      groupedMeanings[pos]!.add(m['meaning']);
    }

    return StreamBuilder(
      stream: box.watch(),
      builder: (context, snapshot) {
        final savedItemIndex = box.values.toList().indexWhere(
          (e) => e.word.toLowerCase() == word.toLowerCase(),
        );
        final isSaved = savedItemIndex >= 0;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔊 BUTTONS
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: DesignTokens.primaryAccentGradient,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: DesignTokens.accentShadow,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (data["audio"] != null && data["audio"] != "") {
                          await player.play(UrlSource(data["audio"]));
                        }
                      },
                      icon: const Icon(
                        Icons.volume_up_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      label: const Text(
                        "Pronounce",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: isSaved ? Colors.grey.shade200 : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: isSaved ? [] : DesignTokens.softShadow,
                      border: isSaved
                          ? null
                          : Border.all(
                              color: const Color(0xFF8B5CF6),
                              width: 1.5,
                            ),
                    ),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        if (isSaved) {
                          box.deleteAt(savedItemIndex);
                        } else {
                          box.add(
                            VocabModel(
                              vocabId: DateTime.now().toString(),
                              word: word,
                              meaningVi: groupedMeanings.values.first.first,
                              phonetic: data["phonetic"] ?? "",
                              example: "",
                              pronunciation: data["audio"],
                              partOfSpeech: groupedMeanings.keys.first,
                            ),
                          );
                        }
                      },
                      icon: Icon(
                        isSaved
                            ? Icons.check_circle_rounded
                            : Icons.bookmark_add_rounded,
                        color: isSaved
                            ? Colors.grey.shade600
                            : const Color(0xFF8B5CF6),
                        size: 20,
                      ),
                      label: Text(
                        isSaved ? "Saved" : "Save Word",
                        style: TextStyle(
                          color: isSaved
                              ? Colors.grey.shade600
                              : const Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 🧠 WORD CARD
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: DesignTokens.softShadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          word,
                          style: DesignTokens.headingStyle.copyWith(
                            fontSize: 32,
                          ),
                        ),
                        const SizedBox(width: 12),
                        if (groupedMeanings.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            margin: const EdgeInsets.only(bottom: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              groupedMeanings.keys.first.toUpperCase(),
                              style: DesignTokens.bodyStyle.copyWith(
                                color: const Color(0xFF3B82F6),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data["phonetic"] ?? "",
                      style: DesignTokens.subheadingStyle.copyWith(
                        color: const Color(0xFF8B5CF6),
                        fontSize: 18,
                      ),
                    ),

                    const Divider(height: 32, color: Color(0xFFF1F5F9)),

                    // 🇻🇳 MEANING LIST
                    ...groupedMeanings.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getPosHeader(entry.key),
                              style: DesignTokens.subheadingStyle.copyWith(
                                color: const Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ...entry.value.asMap().entries.map((meaningEntry) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  left: 8,
                                  bottom: 8,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "• ",
                                      style: TextStyle(
                                        color: Color(0xFF8B5CF6),
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        meaningEntry.value,
                                        style: DesignTokens.bodyStyle.copyWith(
                                          fontSize: 16,
                                          height: 1.5,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),

              // Thêm khoảng trống ở cuối để không bị sát thanh điều hướng
              const SizedBox(height: 50),
            ],
          ),
        );
      },
    );
  }

  String _getPosHeader(String pos) {
    switch (pos.toLowerCase()) {
      case 'noun':
        return "Danh từ (n):";
      case 'verb':
        return "Động từ (v):";
      case 'adjective':
        return "Tính từ (adj):";
      case 'adverb':
        return "Trạng từ (adv):";
      default:
        return "$pos:";
    }
  }
}
