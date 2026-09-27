import 'package:flutter/foundation.dart';

import '../../../mock_data/mock_dashboard_data.dart';
import '../models/dashboard_readings.dart';

class DashboardProvider extends ChangeNotifier {
  List<DashboardActivityMetric> _activityMetrics = [];
  bool _isLoading = false;

  List<DashboardActivityMetric> get activityMetrics => _activityMetrics;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboard() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 400));

    _activityMetrics = MockDashboardData.activityMetrics;

    _isLoading = false;
    notifyListeners();
  }
}
