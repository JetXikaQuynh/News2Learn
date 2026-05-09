import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import '../../../models/vocab_model.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({super.key});

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  final AudioPlayer player = AudioPlayer();

  int currentIndex = 0;
  bool showMeaning = false;

  List<VocabModel> flashcards = [];

  @override
  void initState() {
    super.initState();

    final box = Hive.box<VocabModel>('vocabBox');

    flashcards = box.values.toList();
  }

  void dispose() {
    player.dispose();
    super.dispose();
  }

  // Tối ưu hàm lật thẻ để mượt hơn
  void toggleCard() {
    setState(() {
      showMeaning = !showMeaning;
    });
  }

  void nextCard() {
    if (currentIndex < flashcards.length - 1) {
      setState(() {
        currentIndex++;
        showMeaning = false;
      });
    }
  }

  void prevCard() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        showMeaning = false;
      });
    }
  }

  void shuffleCards() {
    setState(() {
      flashcards.shuffle();
      currentIndex = 0;
      showMeaning = false;
    });
  }

  void resetCards() {
    final box = Hive.box<VocabModel>('vocabBox');

    setState(() {
      flashcards = box.values.toList();
      currentIndex = 0;
      showMeaning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (flashcards.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "Hãy lưu từ vựng để bắt đầu!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }

    if (currentIndex >= flashcards.length) currentIndex = 0;
    final vocab = flashcards[currentIndex];

    return Scaffold(
      backgroundColor: Colors.grey[100],

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset("assets/LOGO1.png", height: 80),

              const Text(
                "Flashcard",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepOrange,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "Thẻ ghi nhớ từ vựng hiệu quả",
                style: TextStyle(color: Colors.black87),
              ),

              const SizedBox(height: 30),

              // HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Thẻ ${currentIndex + 1}/${flashcards.length}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: shuffleCards,
                        icon: const Icon(
                          Icons.shuffle,
                          size: 18,
                          color: Color(0xFF000000),
                        ),
                        label: const Text(
                          "Xáo trộn",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      OutlinedButton.icon(
                        onPressed: resetCards,
                        icon: const Icon(
                          Icons.refresh,
                          size: 18,
                          color: Color(0xFF000000),
                        ),
                        label: const Text(
                          "Làm mới",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // PROGRESS BAR
              LinearProgressIndicator(
                value: (currentIndex + 1) / flashcards.length,
                backgroundColor: Colors.grey[300],
                color: Colors.deepOrange,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 30),

              // FLASHCARD
              Expanded(
                child: GestureDetector(
                  onTap: toggleCard,
                  child: Container(
                    width: double.infinity,

                    //key: ValueKey(showMeaning),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),

                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.50),
                          blurRadius: 12,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),

                    child: TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: showMeaning ? 1 : 0),
                      duration: const Duration(milliseconds: 500),
                      builder: (context, double value, child) {
                        final angle = value * pi;

                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(angle),
                          child: angle <= pi / 2
                              ? _buildFrontCard(vocab)
                              : Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildBackCard(vocab),
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // NAVIGATION
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: prevCard,

                    child: Row(
                      children: const [
                        Icon(
                          Icons.arrow_back,
                          color: Colors.deepOrange,
                          size: 30,
                        ),

                        SizedBox(width: 6),

                        Text("Trước", style: TextStyle(fontSize: 18)),
                      ],
                    ),
                  ),

                  GestureDetector(
                    onTap: nextCard,

                    child: Row(
                      children: const [
                        Text("Sau", style: TextStyle(fontSize: 18)),

                        SizedBox(width: 6),

                        Icon(
                          Icons.arrow_forward,
                          color: Colors.deepOrange,
                          size: 30,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // FRONT CARD
  Widget _buildFrontCard(VocabModel vocab) {
    return Center(
      key: const ValueKey("front"),

      child: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  vocab.word,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(width: 10),

                GestureDetector(
                  onTap: () async {
                    if (vocab.pronunciation != null &&
                        vocab.pronunciation!.isNotEmpty) {
                      await player.play(UrlSource(vocab.pronunciation!));
                    }
                  },

                  child: const Icon(Icons.volume_up, size: 32),
                ),
              ],
            ),

            const SizedBox(height: 14),

            Text(vocab.phonetic, style: const TextStyle(fontSize: 24)),

            const SizedBox(height: 14),

            Text(
              "(${vocab.partOfSpeech})",
              style: const TextStyle(fontSize: 24, color: Colors.blue),
            ),

            const SizedBox(height: 40),

            const Text(
              "Click để xem nghĩa",
              style: TextStyle(color: Colors.grey, fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }

  // BACK CARD
  Widget _buildBackCard(VocabModel vocab) {
    return Padding(
      key: const ValueKey("back"),
      padding: const EdgeInsets.all(24),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text(
              "Nghĩa Tiếng Việt",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ),

          const SizedBox(height: 30),

          Center(
            child: Text(
              vocab.meaningVi,
              style: const TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
