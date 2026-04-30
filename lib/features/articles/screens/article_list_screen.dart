import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/article_model.dart';
import '../providers/article_provider.dart';
import '../widgets/article_card.dart';

class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({super.key});

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();
}

class _ArticleListScreenState extends State<ArticleListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () =>
          Provider.of<ArticleProvider>(context, listen: false).fetchArticles(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ArticleProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("News2Learn"), centerTitle: true),
      body: provider.articles.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.articles.length,
              itemBuilder: (context, index) {
                final article = provider.articles[index];
                return ArticleCard(article: article);
              },
            ),
    );
  }
}
