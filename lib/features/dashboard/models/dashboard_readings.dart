import 'package:flutter/material.dart';

class DashboardActivityMetric {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color? valueColor;

  const DashboardActivityMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    this.valueColor,
  });
}
