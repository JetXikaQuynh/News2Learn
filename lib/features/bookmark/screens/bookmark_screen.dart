import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../services/bookmark_service.dart';
import '../../articles/providers/article_provider.dart';
import '../../articles/widgets/article_card.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkService = BookmarkService();
    final articleProvider = Provider.of<ArticleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: bookmarkService.box.listenable(),
          builder: (context, box, _) {
            final bookmarkedIds = bookmarkService.getBookmarkedIds();

            final bookmarkedArticles = articleProvider.articles
                .where((a) => bookmarkedIds.contains(a.articleId))
                .toList();

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔥 LOGO
                  Image.asset("assets/LOGO1.png", height: 80),

                  const SizedBox(height: 10),

                  // 🧡 TITLE
                  const Text(
                    "Bài báo yêu thích",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // 📊 COUNT
                  Text(
                    "${bookmarkedArticles.length} bài báo đã lưu",
                    style: const TextStyle(color: Colors.black54),
                  ),

                  const SizedBox(height: 16),

                  // 📰 LIST
                  Expanded(
                    child: bookmarkedArticles.isEmpty
                        ? const Center(child: Text("Chưa có bài nào được lưu"))
                        : GridView.builder(
                            itemCount: bookmarkedArticles.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 16,
                                  crossAxisSpacing: 16,
                                  childAspectRatio: 0.9,
                                ),
                            itemBuilder: (context, index) {
                              return ArticleCard(
                                article: bookmarkedArticles[index],
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
