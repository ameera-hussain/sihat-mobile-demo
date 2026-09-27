import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/models/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationListScreen extends StatelessWidget {
  const NotificationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () =>
                context.read<NotificationsProvider>().markAllAsRead(),
            child: const Text('Mark all read'),
          ),
        ],
      ),
      body: Consumer<NotificationsProvider>(
        builder: (context, provider, _) {
          final items = provider.items;
          if (items.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                leading: Icon(_iconFor(item.type)),
                title: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight:
                        item.read ? FontWeight.normal : FontWeight.w700,
                  ),
                ),
                subtitle: Text(item.body),
                trailing: Text(_relativeTime(item.timestamp)),
                onTap: () =>
                    context.read<NotificationsProvider>().markAsRead(item.id),
              );
            },
          );
        },
      ),
    );
  }

  IconData _iconFor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.medication:
        return Icons.medication_outlined;
      case AppNotificationType.appointment:
        return Icons.event_outlined;
      case AppNotificationType.foodLog:
        return Icons.restaurant_outlined;
      case AppNotificationType.general:
        return Icons.info_outline;
    }
  }

  String _relativeTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m';
    if (diff.inHours < 24) return '${diff.inHours}h';
    return '${diff.inDays}d';
  }
}
