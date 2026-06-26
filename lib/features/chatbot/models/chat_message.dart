class ChatMessage {
  final String text;
  final bool isUser;

  final String? correction;
  String? translation;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.correction,
    this.translation,
  });
}
