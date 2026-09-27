import 'package:flutter/material.dart';
import '../models/my_profile_data.dart';
import '../../../mock_data/mock_profile_data.dart';


class ProfileProvider with ChangeNotifier {
  List<MyProfileData> _profileData = [];
  bool _isLoading = false;
  List<MyProfileData> get profileData => _profileData;
  bool get isLoading => _isLoading;


  //get profile data
  Future<void> fetchProfileData() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    _profileData = MockProfileData.profileData;
    _isLoading = false;
    notifyListeners();
}

Future<void> updateProfileData(MyProfileData updatedProfile) async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 400));
    // Update the profile data in the list
    int index = _profileData.indexWhere((profile) => profile.id == updatedProfile.id);
    if (index != -1) {
      _profileData[index] = updatedProfile;
    }
    _isLoading = false;
    notifyListeners();
  }
}