import '../models/reminder.dart';

class ReminderResolutionEvent {
  final String action;
  final DateTime occurredAt;

  const ReminderResolutionEvent({
    required this.action,
    required this.occurredAt,
  });
}

abstract class ReminderTypeResolver {
  ReminderType get type;

  Reminder resolve({
    required Reminder reminder,
    required DateTime now,
    ReminderResolutionEvent? event,
  });
}

class AppointmentReminderResolver implements ReminderTypeResolver {
  @override
  ReminderType get type => ReminderType.appointment;

  @override
  Reminder resolve({
    required Reminder reminder,
    required DateTime now,
    ReminderResolutionEvent? event,
  }) {
    if (event == null) {
      return reminder;
    }

    if (event.action == 'video_joined') {
      return reminder.copyWith(outcome: ReminderOutcome.completed);
    }

    if (event.action == 'no_show_marked') {
      return reminder.copyWith(outcome: ReminderOutcome.missed);
    }

    return reminder;
  }
}

class FoodLogReminderResolver implements ReminderTypeResolver {
  @override
  ReminderType get type => ReminderType.foodLog;

  @override
  Reminder resolve({
    required Reminder reminder,
    required DateTime now,
    ReminderResolutionEvent? event,
  }) {
    if (event != null && event.action == 'food_logged') {
      return reminder.copyWith(outcome: ReminderOutcome.completed);
    }

    final cutoff = DateTime(reminder.dueAt.year, reminder.dueAt.month, reminder.dueAt.day)
        .add(const Duration(days: 1));

    if (reminder.outcome == ReminderOutcome.pending && now.isAfter(cutoff)) {
      return reminder.copyWith(outcome: ReminderOutcome.missed);
    }

    return reminder;
  }
}

class MedicationReminderResolver implements ReminderTypeResolver {
  final Duration graceWindow;

  const MedicationReminderResolver({
    this.graceWindow = const Duration(hours: 2),
  });

  @override
  ReminderType get type => ReminderType.medication;

  @override
  Reminder resolve({
    required Reminder reminder,
    required DateTime now,
    ReminderResolutionEvent? event,
  }) {
    if (event != null && event.action == 'medication_confirmed') {
      return reminder.copyWith(outcome: ReminderOutcome.completed);
    }

    if (reminder.outcome == ReminderOutcome.pending &&
        now.isAfter(reminder.dueAt.add(graceWindow))) {
      return reminder.copyWith(outcome: ReminderOutcome.missed);
    }

    return reminder;
  }
}