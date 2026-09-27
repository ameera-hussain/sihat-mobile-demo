import 'package:flutter/material.dart';
import '../models/my_profile_data.dart';
import '../../../mock_data/mock_profile_data.dart';

class AllergiesProvider with ChangeNotifier {
  List<MyAllergies> _entries = [];
  bool _isLoading = false;

  List<MyAllergies> get entries => _entries;
  bool get isLoading => _isLoading;

  Future<void> fetchAllergies() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _entries = MockAllergiesData.myAllergies;
    _isLoading = false;
    notifyListeners();
  }

  /// Replaces the whole list in one go — simplest option when a section
  /// saves several add/edit/delete changes at once.
  Future<void> saveAll(List<MyAllergies> updated) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _entries = updated;
    _isLoading = false;
    notifyListeners();
  }
}