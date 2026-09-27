import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/constants.dart';
import '../widgets/app_bottom_nav.dart';

class MobileScaffold extends StatefulWidget {
  final Widget child;
  const MobileScaffold({super.key, required this.child});

  @override
  State<MobileScaffold> createState() => _MobileScaffoldState();
}

class _MobileScaffoldState extends State<MobileScaffold> {
  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: myDefaultBackground,
      drawer: buildAppDrawer(context),
      body: widget.child,
      bottomNavigationBar: AppBottomNav(
        currentIndex: _locationToIndex(location),
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/vitals');
              break;
            case 2:
              context.go('/appointments');
              break;
            case 3:
              context.go('/ask-ari');
              break;
          }
        },
      ),
    );
  }

  int _locationToIndex(String location) {
    if (location.startsWith('/vitals')) return 1;
    if (location.startsWith('/appointments')) return 2;
    if (location.startsWith('/ask-ari')) return 3;
    return 0;
}}