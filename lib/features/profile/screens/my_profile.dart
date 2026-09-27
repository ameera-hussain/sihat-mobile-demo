import 'package:flutter/material.dart';
import '../providers/profile_provider.dart';
import '../providers/medical_history_provider.dart';
import '../providers/allergies_provider.dart';
import '../providers/dependents_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/personal_info_section.dart';
import '../widgets/medical_history_section.dart';
import '../widgets/allergies_section.dart';
import '../widgets/dependents_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().fetchProfileData();
      context.read<MedicalHistoryProvider>().fetchMedicalHistory();
      context.read<AllergiesProvider>().fetchAllergies();
      context.read<DependentsProvider>().fetchDependents('');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, title: const Text('My Health Profile')),
      backgroundColor: Colors.white,
      body: Consumer4<ProfileProvider, MedicalHistoryProvider, AllergiesProvider, DependentsProvider>(
        builder: (context, profileProvider, medicalProvider, allergiesProvider, dependentsProvider, _) {
          if (profileProvider.isLoading || profileProvider.profileData.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          final profile = profileProvider.profileData.first;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              PersonalInfoSection(profile: profile),
              MedicalHistorySection(entries: medicalProvider.entries),
              AllergiesSection(entries: allergiesProvider.entries),
              DependentsSection(dependents: dependentsProvider.dependents, guardianId: profile.id),
            ],
          );
        },
      ),
    );
  }
}