import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_decorations.dart';

class AskAriBar extends StatefulWidget {
  const AskAriBar({super.key});

  @override
  State<AskAriBar> createState() => _AskAriBarState();
}

class _AskAriBarState extends State<AskAriBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openAskAri(BuildContext context) {
    final query = _controller.text.trim();
    final route = query.isEmpty
        ? '/ask-ari'
        : '/ask-ari?q=${Uri.encodeComponent(query)}';
    context.push(route);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: cardDecoration.copyWith(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _openAskAri(context),
              decoration: const InputDecoration(
                isDense: true,
                hintText: 'Ask ARI anything...',
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              ),
            ),
          ),
          IconButton(
            onPressed: () => _openAskAri(context),
            icon: const Icon(Icons.send_rounded),
            color: Theme.of(context).colorScheme.primary,
            tooltip: 'Send',
          ),
        ],
      ),
    );
  }
}
