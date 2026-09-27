import '../features/reminders/models/reminder.dart';

class MockRemindersData {
  static final List<Reminder> reminders = [
    Reminder(
      id: 'r-appointment-1',
      type: ReminderType.appointment,
      appointmentId: 'apt-1',
      title: 'Dental Checkup',
      subtitle: 'Dr. Smith - Dental Clinic',
      dueAt: DateTime.now().add(const Duration(hours: 1, minutes: 10)),
      category: ReminderCategory.high,
    ),
    Reminder(
      id: 'r-medication-1',
      type: ReminderType.medication,
      title: 'Take Metformin 500mg',
      subtitle: 'After breakfast',
      dueAt: DateTime.now().subtract(const Duration(minutes: 45)),
      category: ReminderCategory.critical,
      frequency: ReminderFrequency.daily,
    ),
    Reminder(
      id: 'r-food-log-1',
      type: ReminderType.foodLog,
      title: 'Log Lunch Meal',
      subtitle: 'Track carbs and sugar intake',
      dueAt: DateTime.now().add(const Duration(hours: 3)),
      category: ReminderCategory.medium,
    ),
    Reminder(
      id: 'r-appointment-2',
      type: ReminderType.appointment,
      appointmentId: 'apt-2',
      title: 'Eye Examination',
      subtitle: 'Dr. Johnson - Eye Care Center',
      dueAt: DateTime.now().add(const Duration(days: 1, hours: 2)),
      category: ReminderCategory.high,
    ),
    Reminder(
      id: 'r-medication-2',
      type: ReminderType.medication,
      title: 'Take Evening Insulin',
      subtitle: '8 units before dinner',
      dueAt: DateTime.now().add(const Duration(hours: 6)),
      category: ReminderCategory.critical,
      frequency: ReminderFrequency.daily,
    ),
    Reminder(
      id: 'r-food-log-2',
      type: ReminderType.foodLog,
      title: 'Log Dinner Meal',
      subtitle: 'Add portion and calories',
      dueAt: DateTime.now().add(const Duration(hours: 10)),
      category: ReminderCategory.low,
    ),
    Reminder(
      id: 'r-appointment-3',
      type: ReminderType.appointment,
      appointmentId: 'apt-3',
      title: 'Physiotherapy Session',
      subtitle: 'Dr. Lee - Rehab Center',
      dueAt: DateTime.now().add(const Duration(days: 2, hours: 1)),
      category: ReminderCategory.medium,
    ),
  ];
}