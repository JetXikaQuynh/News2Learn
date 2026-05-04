import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../models/vocab_model.dart';

class WordResultCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String word;

  const WordResultCard({super.key, required this.data, required this.word});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<VocabModel>('vocabBox');
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

    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box<VocabModel> box, _) {
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
                  ElevatedButton.icon(
                    onPressed: () async {
                      if (data["audio"] != null && data["audio"] != "") {
                        await player.play(UrlSource(data["audio"]));
                      }
                    },
                    icon: const Icon(
                      Icons.volume_up,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: const Text(
                      "Pronounce",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4294F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
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
                      isSaved ? Icons.check : Icons.bookmark_add,
                      color: Colors.white,
                      size: 20,
                    ),
                    label: Text(
                      isSaved ? "Saved" : "Save",
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaved
                          ? Colors.grey
                          : const Color(0xFFFF8551),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 🧠 WORD & POS
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  if (groupedMeanings.isNotEmpty)
                    Text(
                      "(${groupedMeanings.keys.first})",
                      style: const TextStyle(
                        fontSize: 20,
                        color: Color(0xFF4294F7),
                      ),
                    ),
                ],
              ),

              // 🔤 PHONETIC
              Text(
                data["phonetic"] ?? "",
                style: const TextStyle(color: Color(0xFF4294F7), fontSize: 18),
              ),

              const SizedBox(height: 15),

              // 🇻🇳 MEANING LIST
              ...groupedMeanings.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPosHeader(entry.key),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...entry.value.asMap().entries.map((meaningEntry) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 12, bottom: 6),
                          child: Text(
                            "${meaningEntry.key + 1}. ${meaningEntry.value}",
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.black87,
                              height: 1.4,
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                );
              }).toList(),

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
