import 'package:flutter/material.dart';

const BorderRadius cardRadius = BorderRadius.all(Radius.circular(16));

final BoxDecoration cardDecoration = BoxDecoration(
  color: Colors.white,
  borderRadius: cardRadius,
  border: Border.all(
  color: const Color(0xFF5D53A3).withValues(alpha: 0.15),
  width: 1,
),
  boxShadow: [
    BoxShadow(
      color: const Color(0xFF5D53A3).withValues(alpha: 0.10),
      blurRadius: 13,
      offset: const Offset(0, 4),
    ),
  ],
);