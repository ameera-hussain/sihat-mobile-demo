import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class SettingsMainScreen extends StatelessWidget {
  const SettingsMainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Divider(
            color: Colors.grey.shade300,
            height: 0.5,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            minTileHeight: 60.0,
            title: Text('Account Information'),
            leading: Icon(Icons.person),
            tileColor: Colors.white,
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () {
              context.go('/settings/account_information');
            },
          ),
          ListTile(
            minTileHeight: 60.0,
            title: Text('Billing & Subscription'),
            leading: Icon(Icons.notifications),
            tileColor: Colors.white,
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () {
              context.go('/settings/billing_subscription');
            },
          ),
          ListTile(
            minTileHeight: 60.0,
            title: Text('Terms of Service'),
            leading: Icon(Icons.description),
            tileColor: Colors.white,
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () {
              // Navigate to Terms of Service screen
            },
          ),
          ListTile(
            minTileHeight: 60.0,
            title: Text('Privacy Policy'),
            leading: Icon(Icons.policy),
            tileColor: Colors.white,
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () {
              // Navigate to Privacy Policy screen
            },
          ),
          ListTile(
            minTileHeight: 60.0,
            title: Text('About'),
            leading: Icon(Icons.info),
            tileColor: Colors.white,
            trailing: Icon(Icons.arrow_forward_ios, color: Colors.grey.shade400, size: 16),
            shape: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
            ),
            onTap: () {
              // Navigate to About screen
            },
          ),
        ],
      ),
    );
  }
}