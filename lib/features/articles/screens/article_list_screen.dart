import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../bookmark/screens/bookmark_screen.dart';
import '../../dictionary/screens/dictionary_screen.dart';
import '../../vocabulary/screens/vocabulary_screen.dart';
import '../../flashcards/screens/flashcard_screen.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../profile/screens/profile_screen.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  final List<String> categories = [
    "All",
    "Technology",
    "Environment",
    "Health",
    "Education",
    "Business",
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<ArticleProvider>(context, listen: false).fetchArticles(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),

      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
      ),

      body: _getScreen(),
    );
  }

  Widget _buildArticleScreen() {
    final provider = Provider.of<ArticleProvider>(context);
    final user = FirebaseAuth.instance.currentUser;
    return SafeArea(
      child: provider.articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset("assets/LOGO1.png", height: 80),
                  // 👤 PROFILE
                  GestureDetector(
                    onTap: () async {
                      // Sử dụng await để đợi khi người dùng đóng ProfileScreen quay lại,
                      // hàm setState sẽ kích hoạt build lại màn hình để cập nhật tên mới.
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      );
                      setState(() {});
                    },
                    behavior: HitTestBehavior
                        .opaque, // Giúp nhận diện cả những vùng trống giữa Avatar và Text
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blue,
                          backgroundImage: user?.photoURL != null
                              ? NetworkImage(user!.photoURL!)
                              : null,
                          child: user?.photoURL == null
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Hi, ${user?.displayName ?? "Phuong Quynh"}",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text("Let's start reading News and learning!"),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🔍 SEARCH
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        icon: Icon(Icons.search, color: Colors.red),
                        hintText: "Search articles...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 🧩 CATEGORY
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: categories.asMap().entries.map((entry) {
                      int idx = entry.key;
                      String label = entry.value;
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          // Đổi màu để làm nổi bật category đang chọn (giả định dùng tạm biến cục bộ)
                          color: idx == 0 ? Colors.blue : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade100),
                        ),
                        child: Text(
                          label,
                          style: TextStyle(
                            color: idx == 0 ? Colors.white : Colors.blue,
                            fontWeight: idx == 0
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // 📰 GRID
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.articles.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          childAspectRatio: 0.65,
                        ),
                    itemBuilder: (context, index) {
                      return ArticleCard(article: provider.articles[index]);
                    },
                  ),
                ],
              ),
            ),
    );
  }

  Widget _getScreen() {
    switch (selectedIndex) {
      case 0:
        return _buildArticleScreen();
      case 1:
        return const DictionaryScreen();
      case 2:
        return const FlashcardScreen();
      case 3:
        return const VocabularyScreen();
      case 4:
        return const QuizScreen();
      case 5:
        return const BookmarkScreen();
      default:
        return const Center(child: Text("Coming soon"));
    }
  }
}
