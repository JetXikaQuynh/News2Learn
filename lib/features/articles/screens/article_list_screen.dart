import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../providers/article_provider.dart';
import '../widgets/article_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../bookmark/screens/bookmark_screen.dart';
import '../../dictionary/screens/dictionary_screen.dart';
import '../../vocabulary/screens/vocabulary_screen.dart';
import '../../flashcards/screens/flashcard_screen.dart';
import '../../quiz/screens/quiz_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../chatbot/screens/chatbot_topic_screen.dart';
import 'article_detail_screen.dart';
import '../../../services/bookmark_service.dart';
import '../../../models/article_model.dart';

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

  int selectedIndex = 0; // Bottom nav index
  int selectedCategoryIndex = 0; // Category index
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  late PageController _pageController;
  double currentPage = 0.0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.88);
    _pageController.addListener(() {
      setState(() {
        currentPage = _pageController.page ?? 0.0;
      });
    });
    Future.microtask(() {
      if (mounted) {
        Provider.of<ArticleProvider>(context, listen: false).fetchArticles();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    searchController.dispose();
    super.dispose();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning ☀️';
    } else if (hour < 17) {
      return 'Good Afternoon 🌤️';
    } else {
      return 'Good Evening 🌙';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFF1F5F9), // Soft slate
            Color(0xFFEFF6FF), // Soft cyan
            Color(0xFFF5F3FF), // Soft lavender
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // transparent to let the gradient show
        bottomNavigationBar: CustomBottomNavBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
        ),
        body: _getScreen(),
      ),
    );
  }

  Widget _buildArticleScreen() {
    final provider = Provider.of<ArticleProvider>(context);
    final user = FirebaseAuth.instance.currentUser;

    // Filter logic
    final filteredArticles = provider.articles.where((article) {
      final matchesSearch = article.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          article.description.toLowerCase().contains(searchQuery.toLowerCase());
      
      if (selectedCategoryIndex == 0) {
        return matchesSearch;
      }
      
      final category = categories[selectedCategoryIndex].toLowerCase();
      final matchesCategory = article.category.toLowerCase().contains(category) ||
          article.title.toLowerCase().contains(category) ||
          article.description.toLowerCase().contains(category);
          
      return matchesSearch && matchesCategory;
    }).toList();

    // Partition: First 3 as Featured if search is empty, the rest as Latest
    final showFeatured = searchQuery.isEmpty && selectedCategoryIndex == 0;
    final List<Article> featured = showFeatured && filteredArticles.length > 3
        ? filteredArticles.take(3).toList()
        : [];
    final List<Article> latest = showFeatured && filteredArticles.length > 3
        ? filteredArticles.skip(3).toList()
        : filteredArticles;

    return Stack(
      children: [
        SafeArea(
          child: provider.articles.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () => provider.fetchArticles(),
                  color: const Color(0xFF6D28D9),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 🏷️ HEADER LOGO & ICON
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Image.asset("assets/LOGO1.png", height: 44),
                        //     Container(
                        //       padding: const EdgeInsets.all(8),
                        //       decoration: BoxDecoration(
                        //         color: Colors.white,
                        //         shape: BoxShape.circle,
                        //         border: Border.all(color: const Color(0xFFE2E8F0)),
                        //       ),
                        //       child: const Icon(
                        //         Icons.notifications_none_rounded,
                        //         color: Color(0xFF64748B),
                        //         size: 20,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        //const SizedBox(height: 20),

                        // 👤 GREETING HEADER
                        _buildGreetingHeader(user),
                        const SizedBox(height: 20),

                        // 🔍 SEARCH
                        _buildSearchBar(),
                        const SizedBox(height: 20),

                        // 🧩 CATEGORIES TITLE
                        const Text(
                          "Categories",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 10),
                        
                        // 🧩 CATEGORY CHIPS
                        _buildCategorySelector(),
                        const SizedBox(height: 24),

                        // 🏆 FEATURED SECTION (Scale active PageView)
                        if (showFeatured && featured.isNotEmpty) ...[
                          _buildFeaturedCarousel(featured),
                          const SizedBox(height: 28),
                        ],

                        // 📰 FEED HEADER
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              searchQuery.isNotEmpty
                                  ? "Search Results"
                                  : "Latest News",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            if (latest.isNotEmpty)
                              Text(
                                "${latest.length} articles",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // 📰 MAGAZINE-STYLE ALTERNATING FEED LIST
                        latest.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: latest.length,
                                itemBuilder: (context, index) {
                                  // Alternating layout: every 3rd card is rendered as a Large Vertical Card (isListStyle: false)
                                  // The rest are compact list cards (isListStyle: true)
                                  final isHero = (index % 3 == 0);
                                  return ArticleCard(
                                    article: latest[index],
                                    isListStyle: !isHero,
                                  );
                                },
                              ),
                      ],
                    ),
                  ),
                ),
        ),

        // 🤖 sleek chatbot welcome pill bubble overlay
        _buildChatbotFab(),
      ],
    );
  }

  Widget _buildGreetingHeader(User? user) {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const ProfileScreen(),
          ),
        );
        setState(() {});
      },
      behavior: HitTestBehavior.opaque,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8B5CF6).withOpacity(0.2),
                width: 2.5,
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: const Color(0xFF8B5CF6),
              backgroundImage: user?.photoURL != null
                  ? NetworkImage(user!.photoURL!)
                  : null,
              child: user?.photoURL == null
                  ? const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 24,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getGreeting(),
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                user?.displayName ?? "Phuong Quynh",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (val) {
          setState(() {
            searchQuery = val;
          });
        },
        decoration: InputDecoration(
          icon: const Icon(Icons.search, color: Color(0xFF94A3B8)),
          hintText: "Search news articles...",
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          suffixIcon: searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      searchController.clear();
                      searchQuery = "";
                    });
                  },
                  child: const Icon(Icons.close, color: Color(0xFF94A3B8), size: 18),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildCategorySelector() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = selectedCategoryIndex == index;
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedCategoryIndex = index;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                  width: 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  categories[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : const Color(0xFF64748B),
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeaturedCarousel(List<Article> featuredList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Featured News",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            itemCount: featuredList.length,
            controller: _pageController,
            itemBuilder: (context, index) {
              final article = featuredList[index];

              // Dynamic scale calculation based on PageView scroll
              double scale = 1.0;
              if (_pageController.position.haveDimensions) {
                double diff = currentPage - index;
                scale = (1 - (diff.abs() * 0.07)).clamp(0.88, 1.0);
              } else {
                scale = index == 0 ? 1.0 : 0.92;
              }

              return Transform.scale(
                scale: scale,
                child: _buildFeaturedCard(context, article),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(BuildContext context, Article article) {
    final bookmarkService = BookmarkService();
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: article),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Image
              Positioned.fill(
                child: article.imageUrl.isNotEmpty
                    ? Image.network(
                        article.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: const Color(0xFFEFF6FF),
                          child: const Icon(Icons.broken_image_outlined, color: Colors.blue, size: 40),
                        ),
                      )
                    : Container(
                        color: const Color(0xFFEFF6FF),
                        child: const Icon(Icons.image_outlined, color: Colors.blue, size: 40),
                      ),
              ),
              // Gradient Overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.85),
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
              // Bookmark Button Overlay
              Positioned(
                top: 12,
                right: 12,
                child: ValueListenableBuilder(
                  valueListenable: bookmarkService.box.listenable(),
                  builder: (context, box, _) {
                    final isSaved = bookmarkService.isBookmarked(article.articleId);
                    return GestureDetector(
                      onTap: () => bookmarkService.toggleBookmark(article.articleId),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSaved ? Icons.bookmark : Icons.bookmark_border_rounded,
                          color: isSaved ? const Color(0xFFEF4444) : const Color(0xFF8B5CF6),
                          size: 18,
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Text Info
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Category Tag with glowing gradient decoration
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF8B5CF6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        article.category.isNotEmpty ? article.category.toUpperCase() : "FEATURED",
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      article.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Pub date
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.white70,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('MMM dd, yyyy').format(article.pubDate),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                          ),
                        ),
                      ],
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40.0),
        child: Column(
          children: [
            const Icon(
              Icons.article_outlined,
              size: 48,
              color: Color(0xFFCBD5E1),
            ),
            const SizedBox(height: 12),
            const Text(
              "No articles found",
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 14.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

 Widget _buildChatbotFab() {
  return Positioned(
    right: 16,
    bottom: 16,
    child: GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatbotTopicScreen()),
        );
      },
      child: Image.asset(
        'assets/bot_avatar2.png',
        width: 150,
        height: 150,
        fit: BoxFit.contain, // Đảm bảo toàn bộ ảnh được hiển thị bên trong khung
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
