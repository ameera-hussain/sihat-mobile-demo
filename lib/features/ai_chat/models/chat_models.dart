class ChatMessage {
  final String text;
  final bool isUserMessage;
  final DateTime timestamp;

  const ChatMessage({
    required this.text,
    required this.isUserMessage,
    required this.timestamp,
  });
}
