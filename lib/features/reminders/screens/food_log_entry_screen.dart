import 'package:flutter/material.dart';

class FoodLogEntryScreen extends StatefulWidget {
  final String reminderTitle;

  const FoodLogEntryScreen({
    super.key,
    required this.reminderTitle,
  });

  @override
  State<FoodLogEntryScreen> createState() => _FoodLogEntryScreenState();
}

class _FoodLogEntryScreenState extends State<FoodLogEntryScreen> {
  final TextEditingController _mealController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  @override
  void dispose() {
    _mealController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Log', style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            widget.reminderTitle,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          const Text(
            'Log your current meal entry to resolve this reminder.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _mealController,
            decoration: const InputDecoration(
              labelText: 'Meal name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Notes',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 20),
          FilledButton(
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Meal logged.')),
              );
              Navigator.of(context).pop(true);
            },
            child: const Text('Save Meal Log'),
          ),
        ],
      ),
    );
  }
}
