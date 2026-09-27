import 'package:flutter/material.dart';
import '../models/my_dependent_data.dart';
import '../../../mock_data/mock_profile_data.dart';

class DependentsProvider with ChangeNotifier {
  List<MyDependent> _dependents = [];
  bool _isLoading = false;

  List<MyDependent> get dependents => _dependents;
  bool get isLoading => _isLoading;

  Future<void> fetchDependents(String guardianId) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _dependents = MockDependentsData.dependents
        .where((d) => d.guardianId == guardianId)
        .toList();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveAll(List<MyDependent> updated) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _dependents = updated;
    _isLoading = false;
    notifyListeners();
  }
}