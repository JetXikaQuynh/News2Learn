import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../../../services/ai_service.dart';
import '../../../shared/theme/design_tokens.dart';
import '../widgets/chat_bubble.dart';
import 'package:record/record.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';

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

  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isTranscribing = false;

  Future<void> _startVoiceInput() async {
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Chưa cấp quyền Microphone")),
        );
        return;
      }

      setState(() {
        _isRecording = true;
      });

      final encoder = kIsWeb ? AudioEncoder.aacLc : AudioEncoder.wav;
      final sampleRate = kIsWeb ? 44100 : 16000;
      final config = RecordConfig(
        encoder: encoder,
        sampleRate: sampleRate,
        numChannels: 1,
      );

      String recordPath = '';
      if (!kIsWeb) {
        final tempDir = await getTemporaryDirectory();
        recordPath = '${tempDir.path}/audio_record.wav';
      }

      await _audioRecorder.start(config, path: recordPath);
    } catch (e) {
      debugPrint("Lỗi khởi động ghi âm: $e");
      setState(() {
        _isRecording = false;
      });
    }
  }

  Future<void> _stopVoiceInput() async {
    try {
      final path = await _audioRecorder.stop();
      if (path == null) {
        setState(() {
          _isRecording = false;
        });
        return;
      }

      setState(() {
        _isRecording = false;
        _isTranscribing = true;
      });

      Uint8List audioBytes;
      if (kIsWeb) {
        final response = await http.get(Uri.parse(path));
        audioBytes = response.bodyBytes;
      } else {
        final file = io.File(path);
        audioBytes = await file.readAsBytes();
        debugPrint("[DEBUG_MIC] Path: $path, Size: ${audioBytes.length} bytes");
      }

      //- gửi lên gemini thực hiện transcribe & translate sang tiếng anh
      final mimeType = kIsWeb ? 'audio/m4a' : 'audio/wav';
      final text = await _aiService.transcribeAndTranslateAudio(
        audioBytes,
        mimeType,
      );

      if (text.isNotEmpty) {
        setState(() {
          _controller.text = text;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Không nhận dạng được âm thanh")),
          );
        }
      }
    } catch (e) {
      debugPrint("Lỗi dừng thu âm/STT: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi xử lý âm thanh: $e")));
      }
    } finally {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      setState(() {
        isLoading = true;
      });

      try {
        final initialData = await _aiService.startConversation(widget.topic);
        final welcomeText =
            initialData["reply"] ?? "Hello! Let's talk about ${widget.topic}.";

        setState(() {
          messages.add(ChatMessage(text: welcomeText, isUser: false));
          isLoading = false;
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
            correction: correction,
          );
        }
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
    return Container(
      decoration: const BoxDecoration(
        gradient: DesignTokens.pastelBackgroundGradient,
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: DesignTokens.softShadow,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Color(0xFF334155),
                size: 20,
              ),
            ),
          ),
          title: Column(
            children: [
              Text(
                widget.topic,
                style: DesignTokens.subheadingStyle.copyWith(
                  fontSize: 15,
                  color: const Color(0xFF1E293B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                "AI Tutor đang trực tuyến",
                style: DesignTokens.bodyStyle.copyWith(
                  fontSize: 12,
                  color: Colors.green.shade500,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: DesignTokens.softShadow,
              ),
              child: const Icon(
                Icons.more_vert_rounded,
                color: Color(0xFF334155),
                size: 20,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  return ChatBubble(message: messages[index]);
                },
              ),
            ),

            if (isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildTypingDot(delay: 0),
                            const SizedBox(width: 4),
                            _buildTypingDot(delay: 150),
                            const SizedBox(width: 4),
                            _buildTypingDot(delay: 300),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: DesignTokens.softShadow,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        if (_isTranscribing) return;
                        if (_isRecording) {
                          _stopVoiceInput();
                        } else {
                          _startVoiceInput();
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: _isRecording
                              ? Colors.red.shade100
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: _isTranscribing
                            ? const Padding(
                                padding: EdgeInsets.all(10),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF8B5CF6),
                                  ),
                                ),
                              )
                            : Icon(
                                _isRecording
                                    ? Icons.stop_rounded
                                    : Icons.mic_rounded,
                                color: _isRecording
                                    ? Colors.red
                                    : const Color(0xFF8B5CF6),
                                size: 20,
                              ),
                      ),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        onSubmitted: (_) => sendMessage(),
                        style: DesignTokens.bodyStyle.copyWith(
                          fontSize: 15,
                          color: const Color(0xFF1E293B),
                        ),
                        decoration: InputDecoration(
                          hintText: _isRecording
                              ? "Đang lắng nghe... bấm nút vuông để dừng"
                              : _isTranscribing
                              ? "Đang nhận dạng giọng nói..."
                              : "Nhập tin nhắn...",
                          hintStyle: DesignTokens.bodyStyle.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        gradient: DesignTokens.primaryAccentGradient,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: DesignTokens.accentShadow,
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        onPressed: sendMessage,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot({required int delay}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + delay),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF8B5CF6),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }
}
