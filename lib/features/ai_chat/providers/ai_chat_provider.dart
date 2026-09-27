import 'package:flutter/material.dart';
import '../models/chat_models.dart';

class AiChatProvider with ChangeNotifier {
  AiChatProvider() {
    _seedInitialData();
  }

  final TextEditingController messageController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  bool _isSending = false;

  bool get isSending => _isSending;

  List<ChatMessage> get activeMessages {
    return List.unmodifiable(_messages);
  }

  Future<void> sendMessage(String message) async {
    final trimmed = message.trim();
    if (trimmed.isEmpty || _isSending) {
      return;
    }

    final now = DateTime.now();
    _messages.add(ChatMessage(text: trimmed, isUserMessage: true, timestamp: now));

    _isSending = true;
    notifyListeners();

    messageController.clear();
    await Future.delayed(const Duration(milliseconds: 500));

    _messages.add(
      ChatMessage(
        text: _mockResponse(trimmed),
        isUserMessage: false,
        timestamp: DateTime.now(),
      ),
    );

    _isSending = false;
    notifyListeners();
  }

  String _mockResponse(String prompt) {
    return 'A good next step is to keep hydration, balanced meals, sleep 7-8 hours, and regular movement. If you want, I can break this into a simple day-by-day plan.';
  }

  void _seedInitialData() {
    final now = DateTime.now();

    _messages
      ..clear()
      ..addAll([
      ChatMessage(
        text:
            'What steps can I take to improve my overall health and immunity?',
        isUserMessage: true,
        timestamp: now.subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        text:
            'Start with sleep quality, hydration, a nutrient-rich diet, stress control, and regular movement. I can break this into a weekly plan for you.',
        isUserMessage: false,
        timestamp: now.subtract(const Duration(hours: 2, minutes: 1)),
      ),
    ]);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }
}
