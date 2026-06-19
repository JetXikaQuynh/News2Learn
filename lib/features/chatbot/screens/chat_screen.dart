import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../../../services/ai_service.dart';
import '../widgets/chat_bubble.dart';

class ChatScreen extends StatefulWidget {
  final String topic;

  const ChatScreen({super.key, required this.topic});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();

  final ScrollController _scrollController = ScrollController();

  final AIService _aiService = AIService();

  List<ChatMessage> messages = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading =
            true; // Hiển thị trạng thái "AI is typing..." khi đang nạp câu hỏi đầu tiên
      });

      try {
        // Gọi API bắt đầu cuộc trò chuyện và nhận câu hỏi ngẫu nhiên từ Gemini
        final initialData = await _aiService.startConversation(widget.topic);
        final welcomeText =
            initialData["reply"] ?? "Hello! Let's talk about ${widget.topic}.";

        setState(() {
          messages.add(ChatMessage(text: welcomeText, isUser: false));
          isLoading = false; // Tắt trạng thái chờ loading
        });
      } catch (e) {
        setState(() {
          messages.add(
            ChatMessage(
              text: "Hello! Welcome to our session about ${widget.topic}.",
              isUser: false,
            ),
          );
          isLoading = false;
        });
      }
    });

    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await _aiService.startConversation(widget.topic);
    // });

    // messages.add(
    //   ChatMessage(
    //     text: "Hello! Let's practice English about ${widget.topic}.",
    //     isUser: false,
    //   ),
    // );
  }

  Future<void> sendMessage() async {
    final text = _controller.text.trim();

    if (text.isEmpty) return;

    setState(() {
      messages.add(ChatMessage(text: text, isUser: true));

      isLoading = true;
    });

    _controller.clear();

    try {
      final aiResponse = await _aiService.sendMessage(text);
      final correction = aiResponse["correction"] ?? "";
      final reply = aiResponse["reply"] ?? "";

      setState(() {
        if (correction.isNotEmpty) {
          final lastIndex = messages.length - 1;
          messages[lastIndex] = ChatMessage(
            text: messages[lastIndex].text,
            isUser: true,
            correction: correction, // Gắn lỗi sai vào đây
          );
        }

        // Thêm phản hồi tiếp theo của AI chatbot
        messages.add(ChatMessage(text: reply, isUser: false));
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        messages.add(ChatMessage(text: "Error: $e", isUser: false));

        isLoading = false;
      });
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FA),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          widget.topic,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(12),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: messages[index]);
              },
            ),
          ),

          if (isLoading)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.blue.shade100,
                    child: const Icon(
                      Icons.smart_toy,
                      size: 18,
                      color: Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Text(
                    "AI is typing...",
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: const BoxDecoration(color: Colors.white),
            child: SafeArea(
              child: Row(
                children: [
                  const Icon(Icons.mic, color: Colors.blue),

                  const SizedBox(width: 8),

                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => sendMessage(),
                      decoration: const InputDecoration(
                        hintText: "Type your message...",
                        border: InputBorder.none,
                      ),
                    ),
                  ),

                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
