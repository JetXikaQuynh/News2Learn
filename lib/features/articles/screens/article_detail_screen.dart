import 'package:flutter/material.dart';
import '../../../models/article_model.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Article")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📰 TITLE
            Text(
              article.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            // 🕒 DATE
            Text(
              article.pubDate.toString(),
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 16),

            // 📝 CONTENT
            Text(
              article.content.isNotEmpty
                  ? article.content
                  : article.description,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
