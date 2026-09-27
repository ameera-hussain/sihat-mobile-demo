import 'package:flutter/foundation.dart';
import '../../../core/models/app_notification.dart';

class NotificationsProvider with ChangeNotifier {
  final List<AppNotification> _items = [];
  int _counter = 0;

  List<AppNotification> get items =>
      [..._items]..sort((a, b) => b.timestamp.compareTo(a.timestamp));

  int get unreadCount => _items.where((n) => !n.read).length;

  void add({
    required AppNotificationType type,
    required String title,
    required String body,
    String? relatedReminderId,
    DateTime? timestamp,
  }) {
    _counter += 1;
    _items.add(AppNotification(
      id: 'notif-$_counter',
      type: type,
      title: title,
      body: body,
      timestamp: timestamp ?? DateTime.now(),
      relatedReminderId: relatedReminderId,
    ));
    notifyListeners();
  }

  void markAsRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(read: true);
    notifyListeners();
  }

  void markAllAsRead() {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(read: true);
    }
    notifyListeners();
  }
}
