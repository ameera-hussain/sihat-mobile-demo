import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/notifications/widgets/notification_bell.dart';

const Color myDefaultBackground = Colors.white;

PreferredSizeWidget buildAppBar() {
  return AppBar(
    backgroundColor: Colors.white,
    actions: const [
      NotificationBell(),
      SizedBox(width: 8),
    ],
  );
}

Drawer buildAppDrawer(BuildContext context) {
  void navigateTo(String location) {
    Navigator.of(context).pop();
    context.go(location);
  }

  return Drawer(
    backgroundColor: Colors.grey[300],
    child: Column(
      children: [
        DrawerHeader(
          child: Image.asset(
            'assets/images/SIHATLogoNarrow.png',
            fit: BoxFit.contain,
            // Adjust height to properly fit the standard AppBar height (56.0)
            height: 15,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text('H O M E'),
          onTap: () => navigateTo('/dashboard'),
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('P R O F I L E'),
          onTap: () => navigateTo('/profile'),
        ),
        ListTile(
          leading: const Icon(Icons.calendar_today),
          title: const Text('V I S I T S'),
          onTap: () => navigateTo('/appointments'),
        ),
        ListTile(
          leading: const Icon(Icons.health_and_safety),
          title: const Text('V I T A L S'),
          onTap: () => navigateTo('/vitals'),
        ),
        ListTile(
          leading: const Icon(Icons.receipt_long),
          title: const Text('T R A N S A C T I O N S'),
          onTap: () => navigateTo('/payments'),
        ),
        ListTile(
          leading: const Icon(Icons.settings),
          title: const Text('S E T T I N G S'),
          onTap: () => navigateTo('/settings'),
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text('L O G O U T'),
          onTap: () => navigateTo('/logout'),
        ),
      ],
    ),
  );
}
