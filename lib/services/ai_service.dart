import 'package:google_generative_ai/google_generative_ai.dart';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'dart:typed_data';

class AIService {
  static String get apiKey => dotenv.env['GEMINI_API_KEY'] ?? "";

  final GenerativeModel model = GenerativeModel(
    model: 'gemini-3.1-flash-lite',
    apiKey: apiKey,
  );

  //- chuyển giọng nói thành văn bản tiếng anh (dịch nếu nói tiếng việt)
  Future<String> transcribeAndTranslateAudio(
    Uint8List audioBytes,
    String mimeType,
  ) async {
    try {
      final response = await model.generateContent([
        Content.multi([
          DataPart(mimeType, audioBytes),
          TextPart(
            "Listen to this audio. "
            "If the audio is in English, transcribe it precisely into English text. "
            "If the audio is in Vietnamese, translate it naturally into English. "
            "Only output the final English transcription/translation. Do not include any explanations, markers, or notes. If you cannot hear anything, return an empty string.",
          ),
        ]),
      ]);
      return (response.text ?? "").trim();
    } catch (e) {
      print("Lỗi nhận dạng âm thanh: $e");
      return "";
    }
  }

  ChatSession? _chat;

  Future<Map<String, String>> startConversation(String topic) async {
    final prompt = _getPrompt(topic);

    // Bắt đầu cuộc hội thoại với System Instruction
    _chat = model.startChat(history: [Content.text(prompt)]);

    // Gửi một tin nhắn ẩn kích hoạt AI sinh ra câu hỏi mở đầu theo đúng cấu trúc JSON
    return await sendMessage("START_CONVERSATION");
  }

  Future<Map<String, String>> sendMessage(String message) async {
    try {
      final response = await _chat!.sendMessage(Content.text(message));
      final rawText = response.text ?? "";

      // Tìm và trích xuất JSON từ phản hồi của Gemini
      final jsonStart = rawText.indexOf('{');
      final jsonEnd = rawText.lastIndexOf('}');

      if (jsonStart != -1 && jsonEnd != -1) {
        final jsonString = rawText.substring(jsonStart, jsonEnd + 1);

        final Map<String, dynamic> data = jsonDecode(jsonString);
        return {
          "correction": data["correction"] ?? "",
          "reply": data["reply"] ?? "",
        };
      }

      return {"correction": "", "reply": rawText};
    } catch (e) {
      return {"correction": "", "reply": "⚠️ AI is busy. Please try again."};
    }
  }

  String _getPrompt(String topic) {
    final jsonInstruction = """

CRITICAL: You must always respond in the following JSON format. Do not include any markdown wrapper like ```json.
{
  "correction": "IMPORTANT RULE FOR CORRECTION: Only provide a corrected version if the user makes actual SPELLING (e.g., 'munite' -> 'minute') or GRAMMAR mistakes with a label 'Correction:'. DO NOT correct or penalize the user for capitalization issues (e.g., lowercase starters like 'wait' instead of 'Wait') or missing periods/punctuation at the end of the sentence. If there are no spelling/grammar mistakes, leave this field completely empty ''.",
  "reply": "Your natural response or next question here, maximum 3 sentences"
}
""";

    switch (topic) {
      case "PHÒNG VẤN XIN VIỆC":
        return """
You are an English interviewer for a major company.
Rules:
- When the user sends 'START_CONVERSATION', welcome them naturally to the interview and ask them to introduce themselves to begin.
- For subsequent messages, ask only ONE professional interview question each time.
- Wait for user's answer.
- Correct grammar mistakes first.
- Then continue the interview.
- Speak professionally.
$jsonInstruction""";

      case "GỌI MÓN TẠI NHÀ HÀNG":
        return """
You are a friendly waiter/waitress at a restaurant.
Rules:
- When the user sends 'START_CONVERSATION', greet them warmly, present the menu, and ask if they are ready to order.
- Correct grammar mistakes first.
- Then reply naturally as a waiter and ask for their choices (appetizers, main course, drinks).
- Keep conversation short and realistic.
$jsonInstruction""";

      case "ĐẶT PHÒNG KHÁCH SẠN":
        return """
You are a hotel receptionist.
Rules:
- When the user sends 'START_CONVERSATION', welcome them to the hotel and ask how you can assist with their reservation, check-in, or booking.
- Correct grammar mistakes first.
- Ask one question at a time (e.g., room type, number of nights, breakfast options).
$jsonInstruction""";

      case "DU LỊCH & HƯỚNG DẪN":
        return """
You are an enthusiastic and knowledgeable local tour guide.
Rules:
- When the user sends 'START_CONVERSATION', welcome them to a famous city or landmark and ask what kind of places they would like to explore or visit first.
- Correct grammar mistakes first.
- Suggest interesting locations and ask engaging questions about their travel preferences.
$jsonInstruction""";

      case "MUA SẮM":
        return """
You are a helpful shop assistant at a shopping mall or clothing store.
Rules:
- When the user sends 'START_CONVERSATION', greet the customer nicely, mention a current promotion, and ask how you can help them find what they need.
- Correct grammar mistakes first.
- Ask about their preferences (size, color, budget) and guide them to complete the purchase.
$jsonInstruction""";

      case "TRÒ CHUYỆN HÀNG NGÀY":
        return """
You are a close and friendly English-speaking friend.
Rules:
- When the user sends 'START_CONVERSATION', greet them casually and ask an engaging, lighthearted question about their day, hobbies, or weekend plans.
- Correct grammar mistakes gently.
- Keep the conversation relaxed, informal, using common idioms or casual phrases.
$jsonInstruction""";

      default:
        return """
You are a helpful English teacher conducting a free conversation practice.
Rules:
- When the user sends 'START_CONVERSATION', greet them and ask an interesting question about the topic '$topic' to start the talk.
- Correct grammar mistakes.
- Explain briefly.
- Continue conversation.
$jsonInstruction""";
    }
  }
}
