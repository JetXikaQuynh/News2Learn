import 'package:flutter/material.dart';
import '../../../services/dictionary_service.dart';
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
    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/LOGO1.png", height: 80),
              // 🔥 TITLE
              const Text(
                "Dictionary",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Look up words and build your vocabulary",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              // 🔍 SEARCH BAR
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Enter a word...",
                        filled: true,
                        fillColor: Colors.blue[100],
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  ElevatedButton(
                    onPressed: _search,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: const Size(100, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      "Search",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // 📊 RESULT
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (result != null)
                Expanded(
                  child: WordResultCard(data: result!, word: _controller.text),
                )
              else
                const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
