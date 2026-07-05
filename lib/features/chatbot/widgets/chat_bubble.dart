import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/chat_message.dart';
import '../../../services/translation_service.dart';
import '../../../shared/theme/design_tokens.dart';

class ChatBubble extends StatefulWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  final TranslationService _translationService = TranslationService();
  final FlutterTts _flutterTts = FlutterTts();
  bool _isTranslating = false;

  Future<void> _speak(String text) async {
    try {
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setPitch(1.0);
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Lỗi phát âm TTS: $e");
    }
  }

  Future<void> _handleTranslate() async {
    if (widget.message.translation != null) return;

    setState(() {
      _isTranslating = true;
    });

    final result = await _translationService.translateToVi(widget.message.text);

    if (mounted) {
      setState(() {
        widget.message.translation = result.isNotEmpty
            ? result
            : "Không thể dịch văn bản này.";
        _isTranslating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // USER MESSAGE
    if (widget.message.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 4),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              constraints: const BoxConstraints(maxWidth: 280),
              decoration: BoxDecoration(
                gradient: DesignTokens.primaryAccentGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(4),
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Text(
                widget.message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),
            if (widget.message.correction != null)
              Container(
                margin: const EdgeInsets.only(top: 6, bottom: 8),
                padding: const EdgeInsets.all(12),
                constraints: const BoxConstraints(maxWidth: 280),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_fix_high_rounded,
                      size: 16,
                      color: Colors.green.shade600,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        widget.message.correction!,
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    }

    // AI MESSAGE
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/bot_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: const BoxConstraints(maxWidth: 300),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(4),
                      topRight: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                    boxShadow: DesignTokens.softShadow,
                  ),
                  child: Text(
                    widget.message.text,
                    style: DesignTokens.bodyStyle.copyWith(
                      fontSize: 15,
                      color: const Color(0xFF1E293B),
                      height: 1.5,
                    ),
                  ),
                ),

                if (widget.message.translation != null)
                  Container(
                    margin: const EdgeInsets.only(top: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: const BoxConstraints(maxWidth: 300),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: Text(
                      widget.message.translation!,
                      style: DesignTokens.bodyStyle.copyWith(
                        color: const Color(0xFF1E40AF),
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ),

                const SizedBox(height: 6),
                Row(
                  children: [
                    _buildActionBtn(
                      icon: Icons.volume_up_rounded,
                      color: const Color(0xFF8B5CF6),
                      onTap: () => _speak(widget.message.text),
                    ),
                    const SizedBox(width: 6),
                    _isTranslating
                        ? Container(
                            width: 30,
                            height: 30,
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF8B5CF6),
                            ),
                          )
                        : _buildActionBtn(
                            icon: Icons.g_translate_rounded,
                            color: widget.message.translation != null
                                ? const Color(0xFF3B82F6)
                                : Colors.grey.shade400,
                            onTap: _handleTranslate,
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

  Widget _buildActionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
