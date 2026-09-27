import 'package:flutter/material.dart';
import '../models/my_profile_data.dart';
import '../../../mock_data/mock_profile_data.dart';

class MedicalHistoryProvider with ChangeNotifier {
  List<MyMedicalHistory> _entries = [];
  bool _isLoading = false;

  List<MyMedicalHistory> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchMedicalHistory() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _entries = MockMedicalHistoryData.medicalHistory;
    _isLoading = false;
    notifyListeners();
  }

  /// Replaces the whole list in one go — simplest option when a section
  /// saves several add/edit/delete changes at once.
  Future<void> saveAll(List<MyMedicalHistory> updated) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _entries = updated;
    _isLoading = false;
    notifyListeners();
  }
}