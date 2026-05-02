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
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.red,
      unselectedItemColor: Colors.white,
      backgroundColor: Colors.blue,           // Sửa ở đây
      // elevation: 8,                            // Thêm bóng đổ nhẹ
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.article), label: "Articles"),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Dictionary"),
        BottomNavigationBarItem(icon: Icon(Icons.style), label: "Flashcards"),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: "Vocabulary"),
        BottomNavigationBarItem(icon: Icon(Icons.quiz), label: "Quiz"),
        BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: "Bookmark"),
      ],
    );
  }
}
