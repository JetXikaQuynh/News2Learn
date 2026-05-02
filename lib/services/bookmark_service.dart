import 'package:hive_flutter/hive_flutter.dart';
import '../models/bookmark_model.dart';

class BookmarkService {
  final box = Hive.box<BookmarkModel>('bookmarkBox');

  final String userId = "user_1"; // giả lập user

  // kiểm tra đã lưu chưa
  bool isBookmarked(String articleId) {
    return box.values.any(
      (b) => b.articleId == articleId && b.userId == userId,
    );
  }

  // bấm bookmark
  void toggleBookmark(String articleId) {
    final key = box.keys.firstWhere((k) {
      final b = box.get(k);
      return b!.articleId == articleId && b.userId == userId;
    }, orElse: () => null);

    if (key != null) {
      box.delete(key);
    } else {
      box.add(
        BookmarkModel(
          bmId: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: userId,
          articleId: articleId,
        ),
      );
    }
  }

  // lấy danh sách article đã lưu
  List<String> getBookmarkedIds() {
    return box.values
        .where((b) => b.userId == userId)
        .map((b) => b.articleId)
        .toList();
  }
}
