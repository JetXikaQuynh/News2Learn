import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import '../models/article_model.dart';
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart';

class RssService {
  // final String _url = "https://feeds.bbci.co.uk/news/world/rss.xml";
  final String _url = "https://feeds.nbcnews.com/nbcnews/public/world";
  //hàm lấy dữ liệu từ RSS feed, parse và trả về ds Article.
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

  // Hàm lấy nội dung đầy đủ từ link bài báo (crawling)
  Future<String> fetchFullContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return "";

      final document = parser.parse(response.body);

      // 🔥 BBC thường dùng class này
      final elements = document.querySelectorAll(
        'div[data-component="text-block"]',
      );

      if (elements.isEmpty) return "";

      // nối tất cả đoạn text lại
      final content = elements.map((e) => e.text.trim()).join("\n\n");

      return content;
    } catch (e) {
      print("CRAWL ERROR: $e");
      return "";
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
