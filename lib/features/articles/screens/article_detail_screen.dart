import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/article_model.dart';
import '../../../models/vocab_model.dart';
import '../../../services/rss_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/translation_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String fullContent = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFullContent();
  }

  Future<void> _loadFullContent() async {
    final content = await RssService().fetchFullContent(widget.article.link);

    setState(() {
      fullContent = content;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final displayText = fullContent.isNotEmpty
        ? fullContent
        : widget.article.description;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 IMAGE + BACK
                    Stack(
                      children: [
                        widget.article.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.article.imageUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(height: 220, color: Colors.grey[300]),

                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 📄 CONTENT
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📰 TITLE
                          Text(
                            widget.article.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 🕒 DATE
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(widget.article.pubDate),
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 16),

                          // 💡 TIP
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8B9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFD99F),
                              ),
                            ),
                            child: const Text(
                              "💡 Mẹo: Hãy nhấn vào từ để tra nghĩa và lưu từ đó vào danh sách từ vựng",
                              style: TextStyle(fontSize: 13),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 📖 CONTENT
                          _buildContent(context, displayText),

                          const SizedBox(height: 20),

                          // 🤖 BUTTON
                          Center(
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F8EFC),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                "⭐ Generate AI Summary",
                                style: TextStyle(color: Colors.white),
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
    );
  }

  // 🔥 CONTENT + HIGHLIGHT WORD
  Widget _buildContent(BuildContext context, String text) {
    // Split text into sentences first so we can translate the whole sentence
    final sentenceRegex = RegExp(r'(?<=[.!?])\s+|\n+');
    final sentences = text
        .split(sentenceRegex)
        .where((s) => s.trim().isNotEmpty)
        .toList();

    final vocabBox = Hive.box<VocabModel>('vocabBox');
    final savedWords = vocabBox.values.map((e) => e.word.toLowerCase()).toSet();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sentences.map((sentence) {
        final words = sentence.split(' ');

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Wrap(
            children: words.map((word) {
              final cleanWord = word
                  .replaceAll(RegExp(r'[^\w]'), '')
                  .toLowerCase();
              final isSaved = savedWords.contains(cleanWord);

              return GestureDetector(
                onTap: () {
                  if (cleanWord.isNotEmpty) _showVocabPopup(context, cleanWord);
                },
                onDoubleTap: () async {
                  // Translate the whole sentence to Vietnamese
                  await _showSentenceTranslation(context, sentence.trim());
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 4, bottom: 6),
                  padding: isSaved
                      ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                      : EdgeInsets.zero,
                  decoration: isSaved
                      ? BoxDecoration(
                          color: Colors.yellow[200],
                          borderRadius: BorderRadius.circular(4),
                        )
                      : null,
                  child: Text(
                    "$word ",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isSaved ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }

  // Hiển thị bản dịch câu
  Future<void> _showSentenceTranslation(
    BuildContext context,
    String sentence,
  ) async {
    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    final translated = await TranslationService().translateToVi(sentence);

    if (!context.mounted) return;
    Navigator.pop(context); // close loading

    if (translated.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể dịch câu này')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Original:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(sentence, style: const TextStyle(fontSize: 16)),
              const Divider(height: 20),
              Text(
                'Vietnamese:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 6),
              Text(translated, style: const TextStyle(fontSize: 16)),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 📚 POPUP TỪ VỰNG
  void _showVocabPopup(BuildContext context, String word) async {
    final box = Hive.box<VocabModel>('vocabBox');

    // Popup loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    final data = await DictionaryService().fetchWord(word);
    if (!context.mounted) return;
    Navigator.pop(context); // Đóng loading

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy thông tin từ vựng")),
      );
      return;
    }

    final isSaved = box.values.any(
      (e) => e.word.toLowerCase() == word.toLowerCase(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để thấy bo góc của Container
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER MÀU CAM ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Text(
                      word.toLowerCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () async {
                        if (data["audio"] != null) {
                          final player = AudioPlayer();
                          await player.play(UrlSource(data["audio"]));
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // --- NỘI DUNG NGHĨA ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["phonetic"] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 15),

                    // Hiển thị danh sách các loại từ và nghĩa
                    ...((data["meanings"] as List).map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${m['pos'] == 'noun'
                                  ? 'Danh từ'
                                  : m['pos'] == 'verb'
                                  ? 'Động từ'
                                  : m['pos']} (${m['pos'].toString().substring(0, 1)}):",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "1. ${m['meaning']}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    })),

                    const Divider(height: 30),
                    //NÚT LƯU / XÓA
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (isSaved) {
                              // --- LOGIC XÓA TỪ ---
                              // Tìm key của từ đó trong Hive box để xóa chính xác
                              final Map<dynamic, VocabModel> vocabMap = box
                                  .toMap();
                              dynamic keyToDelete;

                              vocabMap.forEach((key, value) {
                                if (value.word.toLowerCase() ==
                                    word.toLowerCase()) {
                                  keyToDelete = key;
                                }
                              });

                              if (keyToDelete != null) {
                                await box.delete(keyToDelete);

                                // Thông báo cho người dùng
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Đã xóa từ '$word' khỏi từ vựng",
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(
                                    context,
                                  ); // Đóng popup sau khi xóa
                                }
                              }
                            } else {
                              // --- LOGIC LƯU TỪ ---
                              await box.add(
                                VocabModel(
                                  vocabId: DateTime.now().toString(),
                                  word: word,
                                  meaningVi:
                                      data["meanings"][0]["meaning"] ?? "",
                                  phonetic: data["phonetic"] ?? "",
                                  example: "",
                                  pronunciation: data["audio"],
                                  partOfSpeech:
                                      data["meanings"][0]["pos"] ?? "unknown",
                                ),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Đã lưu từ '$word'")),
                                );
                                Navigator.pop(context);
                              }
                            }
                            // Cập nhật lại giao diện màn hình chính để mất/hiện highlight
                            setState(() {});
                          },
                          icon: Icon(
                            isSaved ? Icons.delete_outline : Icons.bookmark_add,
                            color: Colors.white,
                          ),
                          label: Text(
                            isSaved ? "XÓA KHỎI TỪ VỰNG" : "LƯU VÀO TỪ VỰNG",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved
                                ? const Color.fromARGB(255, 255, 51, 51)
                                : Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
