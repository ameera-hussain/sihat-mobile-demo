import 'package:flutter/material.dart';
import '../features/dashboard/models/dashboard_readings.dart';

class MockDashboardData {
  static const List<DashboardActivityMetric> activityMetrics = [
    DashboardActivityMetric(
      label: 'Distance',
      value: '8 km',
      icon: Icons.directions_run,
      iconColor: Color(0xFF6B5ECD),
    ),
    DashboardActivityMetric(
      label: 'Steps',
      value: '10,000',
      icon: Icons.directions_walk,
      iconColor: Color(0xFF6B5ECD),
    ),
    DashboardActivityMetric(
      label: 'Calories',
      value: '500 kcal',
      icon: Icons.local_fire_department,
      iconColor: Color(0xFFCD3B3B),
      valueColor: Color(0xFFCD3B3B),
    ),
  ];
}
