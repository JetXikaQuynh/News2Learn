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
          articleId: DateTime.now().millisecondsSinceEpoch.toString(),
          title: item.title ?? "",
          description: _cleanHtml(item.description ?? ""),
          content: item.content?.value ?? "",
          link: item.link ?? "",
          imageUrl: "", // RSS CNN không có sẵn ảnh
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

  // 🔧 Xóa HTML tag trong description
  String _cleanHtml(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
