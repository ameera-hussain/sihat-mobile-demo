import 'package:flutter/material.dart';
import '../../../core/constants/app_decorations.dart';
import 'wearable_picker_sheet.dart';

class ConnectWearableCard extends StatelessWidget {
  const ConnectWearableCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: cardDecoration,
      child: Row(
        children: [
          Icon(Icons.watch, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync from a wearable',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Connect a device to auto-fill readings',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: () => _showWearablePicker(context),
            child: const Text('Connect'),
          ),
        ],
      ),
    );
  }

  void _showWearablePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => WearablePickerSheet(
        onSelected: (wearable) {
          Navigator.of(sheetContext).pop();
          _connectWearable(context, wearable);
        },
      ),
    );
  }

  // BACKEND: replace with real pairing flow. For now this just simulates a connection attempt
  void _connectWearable(BuildContext context, String wearable) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Connecting to $wearable… (not wired up yet)')),
    );
  }
}