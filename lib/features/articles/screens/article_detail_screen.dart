import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/article_model.dart';
import '../../../models/vocab_model.dart';
import '../../../services/rss_service.dart';

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
    final words = text.split(" ");

    final vocabBox = Hive.box<VocabModel>('vocabBox');
    final savedWords = vocabBox.values.map((e) => e.word.toLowerCase()).toSet();

    return Wrap(
      children: words.map((word) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();

        final isSaved = savedWords.contains(cleanWord);

        return GestureDetector(
          onTap: () {
            _showVocabPopup(context, cleanWord);
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
    );
  }

  // 📚 POPUP TỪ VỰNG
  void _showVocabPopup(BuildContext context, String word) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    word,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.volume_up),
                ],
              ),

              const SizedBox(height: 10),

              const Text("/bəˈfɔː/"),

              const SizedBox(height: 10),

              const Text(
                "Danh từ (n):\n1. Nghĩa ví dụ...\n\nĐộng từ (v):\n1. Nghĩa ví dụ...",
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text("+ Lưu vào Từ vựng"),
              ),
            ],
          ),
        );
      },
    );
  }
}
