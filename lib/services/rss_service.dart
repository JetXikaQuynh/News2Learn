import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import '../models/article_model.dart';

class RssService {
  final String _url = "https://feeds.bbci.co.uk/news/world/rss.xml";

  Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode != 200) {
        throw Exception("Failed to load RSS");
      }

      final feed = RssFeed.parse(response.body);

      // ⚠️ tránh null crash
      final items = feed.items ?? [];

      return items.map((item) {
        return Article(
          articleId: item.guid ?? item.link ?? DateTime.now().toString(),
          title: item.title ?? "",
          description: _cleanHtml(item.description ?? ""),
          content: item.content?.value ?? "",
          link: item.link ?? "",
          imageUrl: _getImage(item),
          category: (item.categories != null && item.categories!.isNotEmpty)
              ? item.categories!.first.toString()
              : "",
          pubDate: item.pubDate ?? DateTime.now(),
          aiSummary: null,
        );
      }).toList();
    } catch (e) {
      print("RSS ERROR: $e");
      return [];
    }
  }

  // 🔧 Lấy ảnh từ RSS item
  String _getImage(RssItem item) {
    // 🔹 1. media:thumbnail (BBC hay dùng)
    if (item.media?.thumbnails != null && item.media!.thumbnails!.isNotEmpty) {
      return item.media!.thumbnails!.first.url ?? "";
    }

    // 🔹 2. enclosure
    if (item.enclosure != null) {
      return item.enclosure!.url ?? "";
    }

    return "";
  }

  // 🔧 Xóa HTML tag trong description
  String _cleanHtml(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
