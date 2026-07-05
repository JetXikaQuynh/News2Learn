import 'package:flutter/material.dart';
import '../../../services/dictionary_service.dart';
import '../../../shared/theme/design_tokens.dart';
import '../widgets/word_result_card.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final TextEditingController _controller = TextEditingController();

  Map<String, dynamic>? result;
  bool isLoading = false;

  Future<void> _search() async {
    final word = _controller.text.trim();
    if (word.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final data = await DictionaryService().fetchWord(word);

    setState(() {
      result = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Dictionary",
                  style: DesignTokens.headingStyle.copyWith(
                    fontSize: 28,
                    foreground: Paint()
                      ..shader = DesignTokens.primaryAccentGradient
                          .createShader(
                            const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tra từ điển Anh - Việt và xây dựng kho từ vựng!",
                  style: DesignTokens.bodyStyle,
                ),
                const SizedBox(height: 24),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: DesignTokens.softShadow,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _controller,
                          style: DesignTokens.bodyStyle.copyWith(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            hintText: "Enter a word...",
                            hintStyle: DesignTokens.bodyStyle.copyWith(
                              color: Colors.grey.shade400,
                              fontSize: 16,
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF8B5CF6),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                          ),
                          onSubmitted: (_) => _search(),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: DesignTokens.primaryAccentGradient,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: DesignTokens.accentShadow,
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                          onPressed: _search,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF8B5CF6),
                        ),
                      ),
                    ),
                  )
                else if (result != null)
                  Expanded(
                    child: WordResultCard(
                      data: result!,
                      word: _controller.text,
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.menu_book_rounded,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Nhập từ vựng cần tra cứu ở ô bên trên!",
                            style: DesignTokens.bodyStyle.copyWith(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
