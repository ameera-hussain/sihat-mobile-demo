import 'package:flutter/material.dart';

class LabeledValue extends StatelessWidget {
  final String label;
  final String? value;

  const LabeledValue({super.key, required this.label, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 140, child: Text(label, style: TextStyle(color: Colors.grey[600]))),
          Expanded(
            child: Text(
              (value == null || value!.isEmpty) ? '-' : value!,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}