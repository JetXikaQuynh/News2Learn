import 'package:firebase_auth/firebase_auth.dart';
import '../models/bookmark_model.dart';
import 'hive_service.dart';
import 'sync_service.dart';

class BookmarkService {
  get box => HiveService.instance.bookmarkBox;

  String get uid => FirebaseAuth.instance.currentUser!.uid;

  bool isBookmarked(String articleId) {
    return box.values.any((b) => b.articleId == articleId);
  }

  Future<void> toggleBookmark(String articleId) async {
    final key = box.keys.cast<dynamic>().firstWhere((k) {
      final b = box.get(k);

      return b!.articleId == articleId;
    }, orElse: () => null);

    if (key != null) {
      await box.delete(key);
    } else {
      await box.add(
        BookmarkModel(
          bmId: DateTime.now().millisecondsSinceEpoch.toString(),

          userId: uid,

          articleId: articleId,
        ),
      );
    }

    // Đồng bộ lên cloud nếu có kết nối
    await SyncService.instance.syncToCloud();
  }

  List<String> getBookmarkedIds() {
    return box.values.map((e) => e.articleId as String).toList().cast<String>();
  }
}
