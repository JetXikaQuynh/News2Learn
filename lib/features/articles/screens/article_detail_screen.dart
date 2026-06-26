import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../../models/article_model.dart';
import '../../../models/vocab_model.dart';
import '../../../services/rss_service.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../../services/dictionary_service.dart';
import '../../../services/translation_service.dart';

class ArticleDetailScreen extends StatefulWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  String fullContent = "";
  String _translatedArticleContent = "";
  bool isLoading = true;
  bool _isTranslatingArticle = false;
  bool _isArticleTranslated = false;
  List<String> _sentences = [];

  @override
  void initState() {
    super.initState();
    _loadFullContent();
  }

  Future<void> _loadFullContent() async {
    final content = await RssService().fetchFullContent(widget.article.link);

    setState(() {
      fullContent = content;
      isLoading = false;
      _splitSentences(content);
    });
  }

  void _splitSentences(String text) {
    if (text.isEmpty) return;
    final sentenceRegex = RegExp(r'(?<=[.!?])\s+|\n+');
    _sentences = text
        .split(sentenceRegex)
        .where((s) => s.trim().isNotEmpty)
        .toList();
  }

  String _findSentenceContainingWord(String word) {
    final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
    for (final sentence in _sentences) {
      final sentenceWords = sentence
          .split(RegExp(r'\s+'))
          .map((w) => w.replaceAll(RegExp(r'[^\w]'), '').toLowerCase());
      if (sentenceWords.contains(cleanWord)) {
        return sentence.trim();
      }
    }
    return word;
  }

  @override
  Widget build(BuildContext context) {
    final originalText = fullContent.isNotEmpty
        ? fullContent
        : widget.article.description;
    final displayText =
        _isArticleTranslated && _translatedArticleContent.isNotEmpty
        ? _translatedArticleContent
        : originalText;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 🔥 IMAGE + BACK
                    Stack(
                      children: [
                        widget.article.imageUrl.isNotEmpty
                            ? Image.network(
                                widget.article.imageUrl,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : Container(height: 220, color: Colors.grey[300]),

                        Positioned(
                          top: 16,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const CircleAvatar(
                              backgroundColor: Colors.black54,
                              child: Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // 📄 CONTENT
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 📰 TITLE
                          Text(
                            widget.article.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // 🕒 DATE
                          Text(
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(widget.article.pubDate),
                            style: const TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 16),

                          // 💡 TIP
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF8B9),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFFFFD99F),
                              ),
                            ),
                            child: Text(
                              _isArticleTranslated
                                  ? "💡 Bài báo đang hiển thị tiếng Việt. Nhấn vào nút để xem bản gốc và sử dụng chức năng dịch từ/câu."
                                  : "💡 Mẹo: Nhấn 1 lần vào từ để tra nghĩa và nhấn 2 lần để dịch cả câu",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // 📖 CONTENT
                          _buildContent(context, displayText),

                          const SizedBox(height: 20),

                          // 🤖 BUTTON
                          Center(
                            child: ElevatedButton(
                              onPressed: _isTranslatingArticle
                                  ? null
                                  : () {
                                      if (_isArticleTranslated) {
                                        setState(() {
                                          _isArticleTranslated = false;
                                        });
                                        return;
                                      }
                                      _showArticleTranslation(
                                        context,
                                        originalText,
                                      );
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4F8EFC),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                _isTranslatingArticle
                                    ? 'Đang dịch...'
                                    : _isArticleTranslated
                                    ? 'XEM BẢN GỐC'
                                    : '⭐ DỊCH CẢ BÀI BÁO',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  // 🔥 CONTENT + HIGHLIGHT WORD
  Widget _buildContent(BuildContext context, String text) {
    final vocabBox = Hive.box<VocabModel>('vocabBox');
    final savedWords = vocabBox.values.map((e) => e.word.toLowerCase()).toSet();
    final words = text.split(' ');

    return Wrap(
      children: words.map((word) {
        final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '').toLowerCase();
        final isSaved = savedWords.contains(cleanWord);

        return GestureDetector(
          onTap: _isArticleTranslated
              ? null
              : () {
                  if (cleanWord.isNotEmpty) _showVocabPopup(context, cleanWord);
                },
          onDoubleTap: _isArticleTranslated
              ? null
              : () {
                  final sentence = _findSentenceContainingWord(word);
                  _showSentenceTranslation(context, sentence);
                },
          child: Container(
            margin: const EdgeInsets.only(right: 4, bottom: 6),
            padding: isSaved
                ? const EdgeInsets.symmetric(horizontal: 4, vertical: 2)
                : EdgeInsets.zero,
            decoration: isSaved
                ? BoxDecoration(
                    color: Colors.yellow[200],
                    borderRadius: BorderRadius.circular(4),
                  )
                : null,
            child: Text(
              "$word ",
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSaved ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // Dịch toàn bộ bài báo và hiển thị ngay trên trang
  Future<void> _showArticleTranslation(
    BuildContext context,
    String text,
  ) async {
    if (text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không có nội dung để dịch')),
      );
      return;
    }

    setState(() {
      _isTranslatingArticle = true;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    final translated = await TranslationService().translateToVi(text);

    if (!context.mounted) return;
    Navigator.pop(context);
    setState(() {
      _isTranslatingArticle = false;
    });

    if (translated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể dịch bài báo này')),
      );
      return;
    }

    setState(() {
      _translatedArticleContent = translated;
      _isArticleTranslated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Bài báo đã được dịch sang tiếng Việt')),
    );
  }

  // Hiển thị bản dịch câu
  Future<void> _showSentenceTranslation(
    BuildContext context,
    String sentence,
  ) async {
    // show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    final translated = await TranslationService().translateToVi(sentence);

    if (!context.mounted) return;
    Navigator.pop(context); // close loading

    if (translated.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Không thể dịch câu này')));
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(38),
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4F8EFC), Color(0xFF2563EB)],
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.translate, color: Colors.white, size: 24),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Dịch câu',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.language,
                                size: 18,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Original (English)',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            sentence,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Arrow
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.arrow_downward,
                          color: Colors.orange[600],
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Vietnamese
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green[200]!, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.green[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Vietnamese',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[600],
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            translated,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Close Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4F8EFC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'ĐÓNG',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // 📚 POPUP TỪ VỰNG
  void _showVocabPopup(BuildContext context, String word) async {
    final box = Hive.box<VocabModel>('vocabBox');

    // Popup loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          const Center(child: CircularProgressIndicator(color: Colors.orange)),
    );

    final data = await DictionaryService().fetchWord(word);
    if (!context.mounted) return;
    Navigator.pop(context); // Đóng loading

    if (data == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Không tìm thấy thông tin từ vựng")),
      );
      return;
    }

    final isSaved = box.values.any(
      (e) => e.word.toLowerCase() == word.toLowerCase(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Để thấy bo góc của Container
      builder: (_) {
        return Container(
          margin: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- HEADER MÀU CAM ---
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: const BoxDecoration(
                  color: Colors.deepOrangeAccent,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: Row(
                  children: [
                    Text(
                      word.toLowerCase(),
                      style: const TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Colors.white),
                      onPressed: () async {
                        if (data["audio"] != null) {
                          final player = AudioPlayer();
                          await player.play(UrlSource(data["audio"]));
                        }
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 28,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),

              // --- NỘI DUNG NGHĨA ---
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data["phonetic"] ?? "",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 15),

                    // Hiển thị danh sách các loại từ và nghĩa
                    ...((data["meanings"] as List).map((m) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${m['pos'] == 'noun'
                                  ? 'Danh từ'
                                  : m['pos'] == 'verb'
                                  ? 'Động từ'
                                  : m['pos']} (${m['pos'].toString().substring(0, 1)}):",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              "1. ${m['meaning']}",
                              style: const TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      );
                    })),

                    const Divider(height: 30),
                    //NÚT LƯU / XÓA
                    Center(
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (isSaved) {
                              // --- LOGIC XÓA TỪ ---
                              // Tìm key của từ đó trong Hive box để xóa chính xác
                              final Map<dynamic, VocabModel> vocabMap = box
                                  .toMap();
                              dynamic keyToDelete;

                              vocabMap.forEach((key, value) {
                                if (value.word.toLowerCase() ==
                                    word.toLowerCase()) {
                                  keyToDelete = key;
                                }
                              });

                              if (keyToDelete != null) {
                                await box.delete(keyToDelete);

                                // Thông báo cho người dùng
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Đã xóa từ '$word' khỏi từ vựng",
                                      ),
                                      duration: const Duration(seconds: 2),
                                    ),
                                  );
                                  Navigator.pop(
                                    context,
                                  ); // Đóng popup sau khi xóa
                                }
                              }
                            } else {
                              // --- LOGIC LƯU TỪ ---
                              await box.add(
                                VocabModel(
                                  vocabId: DateTime.now().toString(),
                                  word: word,
                                  meaningVi:
                                      data["meanings"][0]["meaning"] ?? "",
                                  phonetic: data["phonetic"] ?? "",
                                  example: "",
                                  pronunciation: data["audio"],
                                  partOfSpeech:
                                      data["meanings"][0]["pos"] ?? "unknown",
                                ),
                              );

                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Đã lưu từ '$word'")),
                                );
                                Navigator.pop(context);
                              }
                            }
                            // Cập nhật lại giao diện màn hình chính để mất/hiện highlight
                            setState(() {});
                          },
                          icon: Icon(
                            isSaved ? Icons.delete_outline : Icons.bookmark_add,
                            color: Colors.white,
                          ),
                          label: Text(
                            isSaved ? "XÓA KHỎI TỪ VỰNG" : "LƯU VÀO TỪ VỰNG",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isSaved
                                ? const Color.fromARGB(255, 255, 51, 51)
                                : Colors.orangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
