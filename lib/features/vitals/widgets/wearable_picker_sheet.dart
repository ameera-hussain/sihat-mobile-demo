import 'package:flutter/material.dart';

class WearablePickerSheet extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const WearablePickerSheet({super.key, required this.onSelected});

  static const _options = [
    (icon: Icons.watch, label: 'Apple Watch'),
    (icon: Icons.watch_outlined, label: 'Fitbit'),
    (icon: Icons.directions_run, label: 'Garmin'),
    (icon: Icons.favorite_border, label: 'Whoop'),
    (icon: Icons.bluetooth, label: 'Other Bluetooth device'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                'Choose a device',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            for (final option in _options)
              ListTile(
                leading: Icon(option.icon),
                title: Text(option.label),
                onTap: () => onSelected(option.label),
              ),
          ],
        ),
      ),
    );
  }
}