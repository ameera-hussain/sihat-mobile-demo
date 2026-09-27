import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String sender;
  final String message;
  final bool isUser;
  final Color userBubbleColor;
  final double? maxWidth;

  const ChatBubble({
    super.key,
    required this.sender,
    required this.message,
    required this.isUser,
    this.userBubbleColor = const Color(0xFF088C8C),
    this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth ?? 320),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: isUser ? userBubbleColor : Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.07),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                sender,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF6C707D),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF1E2128),
                  fontSize: 16,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
