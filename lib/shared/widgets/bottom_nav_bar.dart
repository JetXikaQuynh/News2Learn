import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: const Color(0xFF6D28D9), // Vibrant violet-purple
            unselectedItemColor: const Color(0xFF94A3B8), // Cool grey slate
            backgroundColor: Colors.white,
            elevation: 0,
            onTap: onTap,
            type: BottomNavigationBarType.fixed,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 10,
              letterSpacing: 0.2,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.article_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.article, size: 24),
                ),
                label: "News",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.translate, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.translate, size: 24),
                ),
                label: "Dict",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.style_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.style, size: 24),
                ),
                label: "Cards",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.menu_book_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.menu_book, size: 24),
                ),
                label: "Vocab",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.quiz_outlined, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.quiz, size: 24),
                ),
                label: "Quiz",
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.bookmark_outline, size: 22),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Icon(Icons.bookmark, size: 24),
                ),
                label: "Saved",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
