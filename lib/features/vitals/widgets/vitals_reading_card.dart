import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/vitals_reading.dart';

class VitalsReadingCard extends StatelessWidget {
  final VitalsReading reading;
  final VoidCallback? onTap;
  const VitalsReadingCard({super.key, required this.reading, this.onTap});

  // Maps reading type -> icon + brand accent color.
  // Falls back to primary purple for anything not explicitly listed.
  static const Map<String, IconData> _icons = {
    'Blood Pressure': Icons.favorite,
    'Heart Rate': Icons.monitor_heart,
    'Blood Sugar': Icons.bloodtype,
    'Temperature': Icons.thermostat,
    'SpO2': Icons.air,
    'Weight': Icons.monitor_weight,
  };

  static const Map<String, Color> _colors = {
    'Blood Pressure': Color(0xFF5D53A3), // primary
    'Heart Rate': Color(0xFFE96DAA), // secondary
    'Blood Sugar': Color(0xFFE96DAA),
    'Temperature': Color(0xFF5D53A3),
    'SpO2': Color(0xFF5D53A3),
    'Weight': Color(0xFFE96DAA),
  };

  Color get _statusColor {
    switch (reading.status) {
      case VitalsStatus.warning:
        return const Color(0xFFE8A33D);
      case VitalsStatus.critical:
        return const Color(0xFFD9534F);
      case VitalsStatus.normal:
        return Colors.transparent; // no badge needed when normal
    }
  }

  String get _statusLabel {
    switch (reading.status) {
      case VitalsStatus.warning:
        return 'Elevated';
      case VitalsStatus.critical:
        return 'Critical';
      case VitalsStatus.normal:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final icon = _icons[reading.type] ?? Icons.health_and_safety;
    final accent = _colors[reading.type] ?? const Color(0xFF5D53A3);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5D53A3).withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 16, color: accent),
              ),
              const SizedBox(width: 8),
              Text(
                reading.type,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('h:mm a').format(reading.date),
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                reading.value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                reading.unit,
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
              if (reading.status != VitalsStatus.normal) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: _statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    _statusLabel,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (reading.note != null) ...[
            const SizedBox(height: 6),
            Text(
              reading.note!,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    ));
  }
}