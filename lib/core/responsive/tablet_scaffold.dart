import 'package:flutter/material.dart';
import 'package:sihat_mobile_app_flutter/core/constants/constants.dart';

class TabletScaffold extends StatefulWidget {
  final Widget child;
  const TabletScaffold({super.key, required this.child});

  @override
  State<TabletScaffold> createState() => _TabletScaffoldState();
}

class _TabletScaffoldState extends State<TabletScaffold> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: myDefaultBackground,
      drawer: buildAppDrawer(context),
      body: widget.child,
    );
  }
}