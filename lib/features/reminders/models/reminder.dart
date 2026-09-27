import 'package:flutter/material.dart';

enum ReminderType { appointment, foodLog, medication }

enum ReminderCategory { critical, high, medium, low }

enum ReminderOutcome { pending, completed, missed }

enum ReminderTimingState { upcoming, due, overdue }

enum ReminderFrequency { once, daily, weekly, custom }

class Reminder {
  final String id;
  final ReminderType type;
  final String? appointmentId;
  final String title;
  final String subtitle;
  final DateTime dueAt;
  final ReminderCategory category;
  final ReminderOutcome outcome;
  final ReminderFrequency frequency;
  final int snoozeCount;

  const Reminder({
    required this.id,
    required this.type,
    this.appointmentId,
    required this.title,
    required this.subtitle,
    required this.dueAt,
    required this.category,
    this.outcome = ReminderOutcome.pending,
    this.frequency = ReminderFrequency.once,
    this.snoozeCount = 0,
  });

  Reminder copyWith({
    String? id,
    ReminderType? type,
    String? appointmentId,
    String? title,
    String? subtitle,
    DateTime? dueAt,
    ReminderCategory? category,
    ReminderOutcome? outcome,
    ReminderFrequency? frequency,
    int? snoozeCount,
  }) {
    return Reminder(
      id: id ?? this.id,
      type: type ?? this.type,
      appointmentId: appointmentId ?? this.appointmentId,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      dueAt: dueAt ?? this.dueAt,
      category: category ?? this.category,
      outcome: outcome ?? this.outcome,
      frequency: frequency ?? this.frequency,
      snoozeCount: snoozeCount ?? this.snoozeCount,
    );
  }
}

extension ReminderTiming on Reminder {
  ReminderTimingState timingState({
    DateTime? now,
    Duration dueWindow = const Duration(hours: 2),
  }) {
    final DateTime currentTime = now ?? DateTime.now();

    if (dueAt.isBefore(currentTime)) {
      return ReminderTimingState.overdue;
    }

    if (dueAt.difference(currentTime) <= dueWindow) {
      return ReminderTimingState.due;
    }

    return ReminderTimingState.upcoming;
  }
}

extension ReminderFrequencyLabel on ReminderFrequency {
  String get label {
    switch (this) {
      case ReminderFrequency.once:
        return 'Once';
      case ReminderFrequency.daily:
        return 'Daily';
      case ReminderFrequency.weekly:
        return 'Weekly';
      case ReminderFrequency.custom:
        return 'Custom';
    }
  }
}

/// Small helper used when logging notification-feed entries, since
/// TimeOfDay.format(context) needs a BuildContext that providers don't have.
extension TimeOfDayFormat on TimeOfDay {
  String format24Hour() =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
}
