import 'package:flutter/material.dart';

import '../models/reminder.dart';

class ReminderTile extends StatelessWidget {
  final Reminder reminder;
  final VoidCallback? onTap;
  final Widget? footer;

  const ReminderTile({
    super.key,
    required this.reminder,
    this.onTap,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final timing = reminder.timingState();
    final showTiming = reminder.outcome == ReminderOutcome.pending;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE7E4F2)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              offset: Offset(0, 2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: _iconBackground(reminder.type),
                  child: Icon(
                    _iconFor(reminder.type),
                    color: _iconColor(reminder.type),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reminder.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        reminder.subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Pill(
                            label: _typeLabel(reminder.type),
                            background: const Color(0xFFEEEAFB),
                            foreground: const Color(0xFF5D4CA9),
                          ),
                          if (showTiming)
                            _Pill(
                              label: _timingLabel(timing),
                              background: _timingColor(
                                timing,
                              ).withValues(alpha: 0.15),
                              foreground: _timingColor(timing),
                            ),
                          if (!showTiming)
                            _Pill(
                              label: _outcomeLabel(reminder.outcome),
                              background: _outcomeColor(
                                reminder.outcome,
                              ).withValues(alpha: 0.15),
                              foreground: _outcomeColor(reminder.outcome),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDateTime(reminder.dueAt),
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            if (footer != null) ...[const SizedBox(height: 12), footer!],
          ],
        ),
      ),
    );
  }

  IconData _iconFor(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return Icons.calendar_month;
      case ReminderType.foodLog:
        return Icons.restaurant_menu;
      case ReminderType.medication:
        return Icons.medication;
    }
  }

  Color _iconBackground(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return const Color(0xFFE2F3E5);
      case ReminderType.foodLog:
        return const Color(0xFFE3F7FA);
      case ReminderType.medication:
        return const Color(0xFFFFE9E1);
    }
  }

  Color _iconColor(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return const Color(0xFF2E7D32);
      case ReminderType.foodLog:
        return const Color(0xFF008FA1);
      case ReminderType.medication:
        return const Color(0xFFDE5B34);
    }
  }

  String _typeLabel(ReminderType type) {
    switch (type) {
      case ReminderType.appointment:
        return 'Appointment';
      case ReminderType.foodLog:
        return 'Food Log';
      case ReminderType.medication:
        return 'Medication';
    }
  }

  String _timingLabel(ReminderTimingState state) {
    switch (state) {
      case ReminderTimingState.upcoming:
        return 'Upcoming';
      case ReminderTimingState.due:
        return 'Due';
      case ReminderTimingState.overdue:
        return 'Overdue';
    }
  }

  Color _timingColor(ReminderTimingState state) {
    switch (state) {
      case ReminderTimingState.upcoming:
        return const Color(0xFF2E7D32);
      case ReminderTimingState.due:
        return const Color(0xFFF9A825);
      case ReminderTimingState.overdue:
        return const Color(0xFFC62828);
    }
  }

  String _outcomeLabel(ReminderOutcome outcome) {
    switch (outcome) {
      case ReminderOutcome.pending:
        return 'Pending';
      case ReminderOutcome.completed:
        return 'Completed';
      case ReminderOutcome.missed:
        return 'Missed';
    }
  }

  Color _outcomeColor(ReminderOutcome outcome) {
    switch (outcome) {
      case ReminderOutcome.pending:
        return const Color(0xFFF9A825);
      case ReminderOutcome.completed:
        return const Color(0xFF2E7D32);
      case ReminderOutcome.missed:
        return const Color(0xFFC62828);
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$day/$month/${dateTime.year}\n$hour:$minute';
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color background;
  final Color foreground;

  const _Pill({
    required this.label,
    required this.background,
    required this.foreground,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}
