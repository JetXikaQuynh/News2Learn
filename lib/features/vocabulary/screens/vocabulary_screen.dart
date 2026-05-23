import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

import '../../../models/vocab_model.dart';

class VocabularyScreen extends StatelessWidget {
  const VocabularyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<VocabModel>('vocabBox');
    final player = AudioPlayer();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Từ vựng của tôi",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 6),

              ValueListenableBuilder(
                valueListenable: box.listenable(),
                builder: (context, Box<VocabModel> box, _) {
                  final vocabList = box.values.toList();

                  return Text(
                    "${vocabList.length} từ đã lưu",
                    style: const TextStyle(color: Colors.grey),
                  );
                },
              ),

              const SizedBox(height: 16),

              // 🔥 LIST WORDS
              Expanded(
                child: ValueListenableBuilder(
                  valueListenable: box.listenable(),
                  builder: (context, Box<VocabModel> box, _) {
                    final vocabList = box.values.toList();

                    if (vocabList.isEmpty) {
                      return const Center(child: Text("Chưa có từ nào"));
                    }

                    return ListView.builder(
                      itemCount: vocabList.length,
                      itemBuilder: (context, index) {
                        final vocab = vocabList[index];

                        return _buildItem(context, vocab, index, player, box);
                      },
                    );
                  },
                ),
              ),
            ],
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
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.20),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔤 WORD + POS + AUDIO
                Row(
                  children: [
                    Text(
                      vocab.word,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(width: 6),

                    Text(
                      "(${vocab.partOfSpeech})",
                      style: const TextStyle(color: Colors.blue),
                    ),

                    const SizedBox(width: 6),

                    GestureDetector(
                      onTap: () async {
                        if (vocab.pronunciation != null &&
                            vocab.pronunciation!.isNotEmpty) {
                          await player.play(UrlSource(vocab.pronunciation!));
                        }
                      },
                      child: const Icon(
                        Icons.volume_up,
                        size: 18,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // 🔤 PHONETIC
                Text(
                  vocab.phonetic,
                  style: const TextStyle(color: Colors.blue),
                ),

                const SizedBox(height: 6),

                // 🇻🇳 MEANING
                Text(
                  vocab.meaningVi,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // 🗑 DELETE
          GestureDetector(
            onTap: () {
              box.deleteAt(index);

              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text("Đã xóa '${vocab.word}'")));
            },
            child: const Icon(Icons.delete, color: Colors.red),
          ),
        ],
      ),
    );
  }
}
