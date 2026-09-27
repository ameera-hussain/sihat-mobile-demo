import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/ai_chat_provider.dart';
import '../widgets/chat_bubble.dart';

class ChatDashboardScreen extends StatefulWidget {
  final String? initialPrompt;

  const ChatDashboardScreen({super.key, this.initialPrompt});

  @override
  State<ChatDashboardScreen> createState() => _ChatDashboardScreenState();
}

class _ChatDashboardScreenState extends State<ChatDashboardScreen> {
  static const List<String> _defaultSuggestions = <String>[
    'How can I improve sleep quality?',
    'Simple full-body home workout',
    'Healthy late-night snack ideas',
  ];

  static const Color _backgroundColor = Color(0xFFF7FAFB);
  static const Color _userBubbleColor = Color(0xFF5D53A3);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final prompt = widget.initialPrompt?.trim() ?? '';
      if (prompt.isEmpty) {
        return;
      }

      final provider = context.read<AiChatProvider>();
      provider.messageController.text = prompt;
      provider.sendMessage(prompt);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AiChatProvider>(
      builder: (context, provider, _) {
        final screenWidth = MediaQuery.of(context).size.width;

        return Scaffold(
          backgroundColor: _backgroundColor,
          body: SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
                  child: Row(
                    children: [
                      Text(
                        'Ask ARI',
                        style: TextStyle(
                          color: const Color(0xFF20252D),
                          fontSize: screenWidth < 360 ? 24 : 28,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
                    itemCount: provider.activeMessages.length,
                    itemBuilder: (context, index) {
                      final msg = provider.activeMessages[index];

                      return ChatBubble(
                        sender: msg.isUserMessage ? 'You' : 'ARI',
                        message: msg.text,
                        isUser: msg.isUserMessage,
                        userBubbleColor: _userBubbleColor,
                        maxWidth: screenWidth * 0.78,
                      );
                    },
                  ),
                ),
                _MessageComposer(
                  suggestions: _defaultSuggestions,
                  isSending: provider.isSending,
                  controller: provider.messageController,
                  onSend: () =>
                      provider.sendMessage(provider.messageController.text),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _MessageComposer extends StatelessWidget {
  final List<String> suggestions;
  final bool isSending;
  final TextEditingController controller;
  final VoidCallback onSend;

  const _MessageComposer({
    required this.suggestions,
    required this.isSending,
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final composerHeight = width < 360 ? 48.0 : 52.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
      color: Colors.transparent,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: suggestions.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => controller.text = suggestions[index],
                  child: Ink(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      suggestions[index],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF22262F),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (!isSending) {
                      onSend();
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Message ARI...',
                    filled: true,
                    fillColor: const Color(0xFF96DCDD),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(34),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: isSending ? null : onSend,
                borderRadius: BorderRadius.circular(40),
                child: Ink(
                  width: composerHeight,
                  height: composerHeight,
                  decoration: const BoxDecoration(
                    color: Color(0xFF048D8E),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSending ? Icons.hourglass_bottom : Icons.send,
                    color: const Color(0xFF5D53A3),
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
