import 'package:flutter/material.dart';
import 'package:sihat_mobile_app_flutter/core/constants/constants.dart';

class DesktopScaffold extends StatefulWidget {
  final Widget child;
  const DesktopScaffold({super.key, required this.child});

  @override
  State<DesktopScaffold> createState() => _DesktopScaffoldState();
}

class _DesktopScaffoldState extends State<DesktopScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: myDefaultBackground,
      appBar: buildAppBar(),
      body: Row(
        children: [
          buildAppDrawer(context),
          Expanded(child: widget.child),
        ],
      ),
    );
  }
}