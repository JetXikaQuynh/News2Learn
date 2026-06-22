import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../services/bookmark_service.dart';
import '../../articles/providers/article_provider.dart';
import '../../articles/widgets/article_card.dart';
import '../../articles/screens/article_list_screen.dart';
import '../../../shared/theme/design_tokens.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookmarkService = BookmarkService();
    final articleProvider = Provider.of<ArticleProvider>(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: ValueListenableBuilder(
            valueListenable: bookmarkService.box.listenable(),
            builder: (context, box, _) {
              final bookmarkedIds = bookmarkService.getBookmarkedIds();
              final bookmarkedArticles = articleProvider.articles
                  .where((a) => bookmarkedIds.contains(a.articleId))
                  .toList();

              return Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER with back button
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.black87),
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const ArticleListScreen()),
                            );
                          },
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Bài báo yêu thích",
                            style: DesignTokens.headingStyle.copyWith(
                              fontSize: 28,
                              foreground: Paint()
                                ..shader = DesignTokens.primaryAccentGradient.createShader(
                                  const Rect.fromLTWH(0.0, 0.0, 300.0, 70.0),
                                ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            gradient: DesignTokens.primaryAccentGradient,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "${bookmarkedArticles.length} bài",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          "đã lưu trong thư viện",
                          style: DesignTokens.bodyStyle,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // CONTENT
                    Expanded(
                      child: bookmarkedArticles.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bookmark_outline_rounded,
                                    size: 72,
                                    color: Colors.grey.shade300,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Chưa có bài nào được lưu",
                                    style: DesignTokens.subheadingStyle
                                        .copyWith(color: Colors.grey.shade400),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    "Đọc bài báo và nhấn nút lưu để thêm vào đây!",
                                    style: DesignTokens.bodyStyle.copyWith(
                                      color: Colors.grey.shade400,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            )
                          : GridView.builder(
                              itemCount: bookmarkedArticles.length,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisSpacing: 12,
                                    crossAxisSpacing: 12,
                                    // Lower aspect ratio -> allocate more height for each tile
                                    childAspectRatio: 0.60,
                                  ),
                              itemBuilder: (context, index) {
                                return ArticleCard(
                                  article: bookmarkedArticles[index],
                                  isListStyle: false,
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
      ),
    );
  }
}
