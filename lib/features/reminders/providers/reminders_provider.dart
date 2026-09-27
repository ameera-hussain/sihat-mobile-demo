import 'package:flutter/material.dart';

import '../../../mock_data/mock_reminders_data.dart';
import '../models/reminder.dart';
import 'reminder_resolvers.dart';
import '../../../core/services/local_notification_service.dart';
import '../../../core/models/app_notification.dart';
import '../../notifications/providers/notifications_provider.dart';

class RemindersProvider with ChangeNotifier {
  RemindersProvider({required this.notificationsProvider});

  final NotificationsProvider notificationsProvider;

  static const Map<ReminderTimingState, int> timingWeights = {
    ReminderTimingState.overdue: 100,
    ReminderTimingState.due: 70,
    ReminderTimingState.upcoming: 40,
  };

  static const Map<ReminderCategory, int> categoryWeights = {
    ReminderCategory.critical: 30,
    ReminderCategory.high: 20,
    ReminderCategory.medium: 10,
    ReminderCategory.low: 0,
  };

  final Map<ReminderType, ReminderTypeResolver> _resolvers = {
    ReminderType.appointment: AppointmentReminderResolver(),
    ReminderType.foodLog: FoodLogReminderResolver(),
    ReminderType.medication: const MedicationReminderResolver(),
  };

  List<Reminder> _reminders = [];
  bool _isLoading = false;
  int _medicationCounter = 0;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  Future<void> fetchReminders() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300));
    _reminders = MockRemindersData.reminders;
    _medicationCounter = _reminders
        .where((item) => item.type == ReminderType.medication)
        .length;
    _isLoading = false;
    notifyListeners();
  }

  List<ReminderType> availableFilterTypes() {
    final typeSet = _reminders.map((item) => item.type).toSet();
    return ReminderType.values.where((type) => typeSet.contains(type)).toList();
  }

  List<Reminder> activeReminders({ReminderType? filter}) {
    final source = filter == null
        ? _reminders
        : _reminders.where((item) => item.type == filter).toList();

    final active = source
        .where((item) => item.outcome == ReminderOutcome.pending)
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));

    return active;
  }

  Map<ReminderTimingState, List<Reminder>> activeGroupedByTiming({
    ReminderType? filter,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final grouped = <ReminderTimingState, List<Reminder>>{
      ReminderTimingState.overdue: [],
      ReminderTimingState.due: [],
      ReminderTimingState.upcoming: [],
    };

    for (final reminder in activeReminders(filter: filter)) {
      grouped[reminder.timingState(now: currentTime)]!.add(reminder);
    }

    return grouped;
  }

  List<Reminder> historyReminders({ReminderType? filter}) {
    final source = filter == null
        ? _reminders
        : _reminders.where((item) => item.type == filter).toList();

    final history = source
        .where((item) => item.outcome != ReminderOutcome.pending)
        .toList()
      ..sort((a, b) => b.dueAt.compareTo(a.dueAt));

    return history;
  }

  bool canSnooze(String reminderId) {
    final reminder = _reminders
        .where((item) => item.id == reminderId)
        .cast<Reminder?>()
        .firstWhere((item) => item != null, orElse: () => null);
    return reminder != null && reminder.snoozeCount < 1;
  }

  bool snoozeReminder({
    required String reminderId,
    Duration increment = const Duration(minutes: 30),
  }) {
    final index = _reminders.indexWhere((item) => item.id == reminderId);
    if (index == -1) {
      return false;
    }

    final reminder = _reminders[index];
    if (reminder.snoozeCount >= 1) {
      return false;
    }

    final updated = reminder.copyWith(
      dueAt: reminder.dueAt.add(increment),
      snoozeCount: reminder.snoozeCount + 1,
    );
    _reminders[index] = updated;
    notifyListeners();

    if (reminder.type == ReminderType.medication) {
      final notifId =
          LocalNotificationService.instance.notificationIdFor(reminderId);
      LocalNotificationService.instance.cancelReminder(notifId);
      LocalNotificationService.instance.scheduleReminder(
        id: notifId,
        medicineName: updated.title,
        dosage: updated.subtitle,
        scheduledTime: updated.dueAt,
        repeatsDaily: updated.frequency == ReminderFrequency.daily,
      );
    }

    return true;
  }

  Reminder? addMedicationReminder({
    required String title,
    required String subtitle,
    required DateTime dueAt,
    required ReminderFrequency frequency,
    ReminderCategory category = ReminderCategory.high,
  }) {
    _medicationCounter += 1;
    final reminder = Reminder(
      id: 'r-medication-user-$_medicationCounter',
      type: ReminderType.medication,
      title: title,
      subtitle: subtitle,
      dueAt: dueAt,
      category: category,
      frequency: frequency,
    );
    _reminders = [reminder, ..._reminders];
    notifyListeners();

    LocalNotificationService.instance.scheduleReminder(
      id: LocalNotificationService.instance.notificationIdFor(reminder.id),
      medicineName: title,
      dosage: subtitle,
      scheduledTime: dueAt,
      repeatsDaily: frequency == ReminderFrequency.daily,
    );

    notificationsProvider.add(
      type: AppNotificationType.medication,
      title: 'Medication reminder set',
      body: '$title — ${TimeOfDay.fromDateTime(dueAt).format24Hour()}',
      relatedReminderId: reminder.id,
    );

    return reminder;
  }

  bool updateMedicationReminder({
    required String reminderId,
    DateTime? dueAt,
    ReminderFrequency? frequency,
  }) {
    final index = _reminders.indexWhere((item) => item.id == reminderId);
    if (index == -1) return false;

    final reminder = _reminders[index];
    if (reminder.type != ReminderType.medication) return false;

    final updated = reminder.copyWith(dueAt: dueAt, frequency: frequency);
    _reminders[index] = updated;
    notifyListeners();

    final notifId =
        LocalNotificationService.instance.notificationIdFor(reminderId);
    LocalNotificationService.instance.cancelReminder(notifId);
    LocalNotificationService.instance.scheduleReminder(
      id: notifId,
      medicineName: updated.title,
      dosage: updated.subtitle,
      scheduledTime: updated.dueAt,
      repeatsDaily: updated.frequency == ReminderFrequency.daily,
    );

    return true;
  }

  bool deleteMedicationReminder(String reminderId) {
    final reminder = _reminders
        .where((item) => item.id == reminderId)
        .cast<Reminder?>()
        .firstWhere((item) => item != null, orElse: () => null);
    if (reminder == null || reminder.type != ReminderType.medication) {
      return false;
    }

    _reminders.removeWhere((item) => item.id == reminderId);
    notifyListeners();

    LocalNotificationService.instance.cancelReminder(
      LocalNotificationService.instance.notificationIdFor(reminderId),
    );

    notificationsProvider.add(
      type: AppNotificationType.medication,
      title: 'Medication reminder deleted',
      body: '${reminder.title} was removed.',
      relatedReminderId: reminderId,
    );

    return true;
  }

  List<Reminder> topReminders({
    int limit = 5,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final sorted = [..._reminders]
      ..sort((a, b) {
        final scoreCompare = _scoreForReminder(b, currentTime)
            .compareTo(_scoreForReminder(a, currentTime));
        if (scoreCompare != 0) {
          return scoreCompare;
        }
        return a.dueAt.compareTo(b.dueAt);
      });

    if (sorted.length <= limit) {
      return sorted;
    }
    return sorted.take(limit).toList();
  }

  Map<ReminderType, List<Reminder>> groupedByType({ReminderType? filter}) {
    final source = filter == null
        ? _reminders
        : _reminders.where((reminder) => reminder.type == filter).toList();

    final grouped = <ReminderType, List<Reminder>>{};
    for (final reminder in source) {
      grouped.putIfAbsent(reminder.type, () => []).add(reminder);
    }

    for (final group in grouped.values) {
      group.sort((a, b) => a.dueAt.compareTo(b.dueAt));
    }

    return grouped;
  }

  void resolveReminder({
    required String reminderId,
    ReminderResolutionEvent? event,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();

    final index = _reminders.indexWhere((item) => item.id == reminderId);
    if (index == -1) {
      return;
    }

    final reminder = _reminders[index];
    final resolver = _resolvers[reminder.type];
    if (resolver == null) {
      return;
    }

    final resolved = resolver.resolve(
      reminder: reminder,
      now: currentTime,
      event: event,
    );
    _reminders[index] = resolved;
    notifyListeners();

    if (resolved.outcome != reminder.outcome) {
      _logOutcomeChange(reminder: reminder, resolved: resolved);
    }
  }

  void runAutoResolution({DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    var hasChanges = false;

    for (var i = 0; i < _reminders.length; i++) {
      final reminder = _reminders[i];
      final resolver = _resolvers[reminder.type];
      if (resolver == null) {
        continue;
      }

      final resolved = resolver.resolve(
        reminder: reminder,
        now: currentTime,
      );

      if (resolved.outcome != reminder.outcome) {
        _reminders[i] = resolved;
        hasChanges = true;
        _logOutcomeChange(reminder: reminder, resolved: resolved);
      }
    }

    if (hasChanges) {
      notifyListeners();
    }
  }

  void _logOutcomeChange({
    required Reminder reminder,
    required Reminder resolved,
  }) {
    notificationsProvider.add(
      type: _notifTypeFor(reminder.type),
      title: resolved.outcome == ReminderOutcome.completed
          ? '${reminder.title} completed'
          : '${reminder.title} missed',
      body: resolved.outcome == ReminderOutcome.completed
          ? 'Marked as completed.'
          : 'This reminder passed without confirmation.',
      relatedReminderId: reminder.id,
    );

    if (reminder.type == ReminderType.medication &&
        resolved.outcome == ReminderOutcome.completed) {
      LocalNotificationService.instance.cancelReminder(
        LocalNotificationService.instance.notificationIdFor(reminder.id),
      );
    }
  }

  AppNotificationType _notifTypeFor(ReminderType type) {
    switch (type) {
      case ReminderType.medication:
        return AppNotificationType.medication;
      case ReminderType.appointment:
        return AppNotificationType.appointment;
      case ReminderType.foodLog:
        return AppNotificationType.foodLog;
    }
  }

  int _scoreForReminder(Reminder reminder, DateTime now) {
    final timingState = reminder.timingState(now: now);
    final timingWeight = timingWeights[timingState] ?? 0;
    final categoryWeight = categoryWeights[reminder.category] ?? 0;
    return timingWeight + categoryWeight;
  }
}
