import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/chat_message.dart';
import '../../../services/translation_service.dart'; // Đảm bảo đường dẫn này đúng với dự án của bạn

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final TranslationService _translationService = TranslationService();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTranslating = false; // Trạng thái vòng xoay loading khi đang dịch

  Future<void> _speak(String text) async {
    try {
      // Thiết lập ngôn ngữ đọc là tiếng Anh Mỹ
      await _flutterTts.setLanguage("en-US");

      // Thiết lập tốc độ đọc (0.0 đến 1.0). 0.45 đến 0.5 là vừa phải cho người học
      await _flutterTts.setSpeechRate(0.6);

      // Thiết lập cao độ giọng nói (0.5 đến 2.0)
      await _flutterTts.setPitch(1.0);

      // Kích hoạt phát âm đoạn văn bản
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Lỗi phát âm TTS: $e");
    }
  }

  // Hàm xử lý gọi API dịch thuật Google
  Future<void> _handleTranslate() async {
    // Nếu tin nhắn đã dịch rồi, bấm lại sẽ ẩn/hiện hoặc không cần dịch lại để tiết kiệm tài nguyên
    if (widget.message.translation != null) {
      return;
    }

    setState(() {
      _isTranslating = true;
    });

    // Gọi phương thức dịch từ file TranslationService của bạn
    final result = await _translationService.translateToVi(widget.message.text);

    if (mounted) {
      setState(() {
        // Lưu kết quả vào biến translation của Model để tránh trùng lặp khi scroll listview
        widget.message.translation = result.isNotEmpty
            ? result
            : "Không thể dịch văn bản này.";
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // TRƯỜNG HỢP 1: TIN NHẮN CỦA USER
    if (widget.message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(maxWidth: 260),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                widget.message.text,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            if (widget.message.correction != null)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 8),
                padding: const EdgeInsets.all(10),
                constraints: const BoxConstraints(maxWidth: 260),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  widget.message.correction!,
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    // TRƯỜNG HỢP 2: TIN NHẮN CỦA CHATBOT AI
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar của Bot (Giữ nguyên cấu trúc của bạn)
          Container(
            width: 35,
            height: 35,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/bot_avatar.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Khung chứa nội dung tiếng Anh gốc
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: Text(widget.message.text),
                ),

                // HIỂN THỊ KHUNG BẢN DỊCH (Nếu dữ liệu đã dịch tồn tại)
                if (widget.message.translation != null)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50.withOpacity(
                        0.6,
                      ), // Màu nền xanh nhạt dịu mắt
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Text(
                      widget.message.translation!,
                      style: TextStyle(
                        color: Colors.blue.shade900,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ),

                if (widget.message.correction != null)
                  Container(
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Text(
                      widget.message.correction!,
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 1),

                // Hàng nút chức năng bổ trợ (Loa phát âm & Dịch thuật)
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.volume_up,
                        size: 18,
                        color: Colors.grey,
                      ),
                      constraints: const BoxConstraints(),
                      padding: const EdgeInsets.all(4),
                      onPressed: () => _speak(widget.message.text),
                    ),
                    const SizedBox(width: 8),

                    // Cấu trúc nút dịch có kiểm tra trạng thái Loading
                    _isTranslating
                        ? const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.8,
                                color: Colors.grey,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: Icon(
                              Icons.g_translate,
                              size: 18,
                              // Đổi icon sang màu xanh dương nếu tin nhắn này đã được dịch xong
                              color: widget.message.translation != null
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(4),
                            onPressed:
                                _handleTranslate, // Gọi hàm kích hoạt dịch thuật tự động
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Giải phóng và dừng phát âm khi widget bị hủy
    super.dispose();
  }
}
