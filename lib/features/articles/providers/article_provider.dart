import 'package:flutter/material.dart';
import '../../../models/article_model.dart';
import '../../../services/rss_service.dart';

class ArticleProvider extends ChangeNotifier {
  final RssService _service = RssService();

  List<Article> articles = [];

  Future<void> fetchArticles() async {
    articles = await _service.fetchArticles();
    notifyListeners();
  }
}
