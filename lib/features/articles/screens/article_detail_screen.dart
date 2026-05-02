import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/article_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../models/vocab_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🔥 IMAGE + BACK
              Stack(
                children: [
                  article.imageUrl.isNotEmpty
                      ? Image.network(
                          article.imageUrl,
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
                        child: Icon(Icons.arrow_back, color: Colors.white),
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
                      article.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    // 🕒 DATE
                    Text(
                      DateFormat('MMM dd, yyyy').format(article.pubDate),
                      style: const TextStyle(color: Colors.grey),
                    ),

                    const SizedBox(height: 16),

                    // 💡 TIP
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 248, 185),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color.fromARGB(255, 255, 217, 159),
                        ),
                      ),
                      child: const Text(
                        "💡 Mẹo: Hãy nhấn vào từ để tra nghĩa và lưu từ đó vào danh sách từ vựng",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 📖 CONTENT (CLICK WORD)
                    _buildContent(context),

                    const SizedBox(height: 20),

                    // 🤖 BUTTON
                    Center(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text(
                          "⭐ Generate AI Summary",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(
                            255,
                            79,
                            142,
                            252,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
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
    );
  }

  // 🔥 CLICK WORD → SHOW POPUP
  Widget _buildContent(BuildContext context) {
    final text = article.content.isNotEmpty
        ? article.content
        : article.description;

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

              // BUTTON
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
