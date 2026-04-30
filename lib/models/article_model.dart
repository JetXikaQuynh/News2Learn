class Article {
  final String articleId;
  final String title;
  final String description;
  final String content;
  final String link;
  final String imageUrl;
  final String category;
  final DateTime pubDate;
  final String? aiSummary;

  Article({
    required this.articleId,
    required this.title,
    required this.description,
    required this.content,
    required this.link,
    required this.imageUrl,
    required this.category,
    required this.pubDate,
    this.aiSummary,
  });

  // 🔁 Convert từ JSON (Firestore hoặc API)
  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      articleId: json['articleId'],
      title: json['title'],
      description: json['description'],
      content: json['content'],
      link: json['link'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      pubDate: DateTime.parse(json['pubDate']),
      aiSummary: json['ai_summary'],
    );
  }

  // 🔁 Convert sang JSON (lưu DB)
  Map<String, dynamic> toJson() {
    return {
      'articleId': articleId,
      'title': title,
      'description': description,
      'content': content,
      'link': link,
      'imageUrl': imageUrl,
      'category': category,
      'pubDate': pubDate.toIso8601String(),
      'ai_summary': aiSummary,
    };
  }
}
