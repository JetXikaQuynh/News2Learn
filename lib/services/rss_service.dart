import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:webfeed/webfeed.dart';
import '../models/article_model.dart';
import 'package:html/parser.dart' as parser;

class RssService {
  final String _url = "https://feeds.nbcnews.com/nbcnews/public/world";
  //hàm lấy dữ liệu từ RSS feed, parse và trả về ds Article.
  Future<List<Article>> fetchArticles() async {
    try {
      final response = await http.get(Uri.parse(_url));

      if (response.statusCode != 200) {
        throw Exception("Failed to load RSS");
      }

      final feed = RssFeed.parse(response.body);

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
      developer.log("RSS ERROR: $e", name: 'RssService');
      return [];
    }
  }

  // Hàm lấy nội dung đầy đủ từ link bài báo (crawling)
  Future<String> fetchFullContent(String url) async {
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode != 200) return "";

      final document = parser.parse(response.body);

      final jsonLdScripts = document.querySelectorAll(
        'script[type="application/ld+json"]',
      );
      for (final script in jsonLdScripts) {
        final text = script.text.trim();
        if (text.isEmpty) continue;

        try {
          final data = json.decode(text);

          String? articleBody;
          if (data is Map<String, dynamic>) {
            articleBody = _extractArticleBodyFromJson(data);
          } else if (data is List) {
            for (final item in data) {
              if (item is Map<String, dynamic>) {
                articleBody = _extractArticleBodyFromJson(item);
                if (articleBody != null && articleBody.isNotEmpty) break;
              }
            }
          }

          if (articleBody != null && articleBody.trim().isNotEmpty) {
            return articleBody.trim();
          }
        } catch (_) {}
      }

      final selectors = [
        'div[data-component="text-block"]',
        'div[data-testid="article-body"]',
        'div[data-testid="articleBody"]',
        'div[class*="article-body"]',
        'article',
        'main',
        'section',
      ];

      for (final selector in selectors) {
        final elements = document.querySelectorAll(selector);
        if (elements.isEmpty) continue;

        final content = elements
            .map((e) => e.text.trim())
            .where((t) => t.isNotEmpty)
            .join("\n\n");
        if (content.isNotEmpty) return content;
      }

      return "";
    } catch (e) {
      developer.log("CRAWL ERROR: $e", name: 'RssService');
      return "";
    }
  }

  String? _extractArticleBodyFromJson(Map<String, dynamic> data) {
    final possibleKeys = ['articleBody', 'article_body', 'articlebody'];
    for (final key in possibleKeys) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  // Lấy ảnh từ RSS item
  String _getImage(RssItem item) {
    if (item.media?.thumbnails != null && item.media!.thumbnails!.isNotEmpty) {
      return item.media!.thumbnails!.first.url ?? "";
    }

    if (item.enclosure != null) {
      return item.enclosure!.url ?? "";
    }

    return "";
  }

  //Xóa HTML tag trong description
  String _cleanHtml(String htmlText) {
    return htmlText.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
