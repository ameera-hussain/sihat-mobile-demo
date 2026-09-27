enum AppNotificationType { medication, appointment, foodLog, general }

class AppNotification {
  final String id;
  final AppNotificationType type;
  final String title;
  final String body;
  final DateTime timestamp;
  final bool read;
  final String? relatedReminderId;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.timestamp,
    this.read = false,
    this.relatedReminderId,
  });

  AppNotification copyWith({bool? read}) => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        timestamp: timestamp,
        read: read ?? this.read,
        relatedReminderId: relatedReminderId,
      );
}