import 'package:flutter/material.dart';

/// The Sihat logo used across all auth screens.
class SihatLogo extends StatelessWidget {
  final double height;
  const SihatLogo({super.key, this.height = 60});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/SIHATLogoNarrow.png',
      height: height,
      fit: BoxFit.contain,
    );
  }
}