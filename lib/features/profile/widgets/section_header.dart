import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final bool isEditing;
  final VoidCallback onEditPressed;
  final VoidCallback? onSavePressed;
  final VoidCallback? onCancelPressed;

  const SectionHeader({
    super.key,
    required this.title,
    required this.isEditing,
    required this.onEditPressed,
    this.onSavePressed,
    this.onCancelPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        if (!isEditing)
          IconButton(icon: const Icon(Icons.edit, size: 20), onPressed: onEditPressed)
        else
          Row(
            children: [
              IconButton(icon: const Icon(Icons.close, size: 20, color: Colors.grey), onPressed: onCancelPressed),
              IconButton(icon: const Icon(Icons.check, size: 20, color: Colors.green), onPressed: onSavePressed),
            ],
          ),
      ],
    );
  }
}