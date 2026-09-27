import '../../../features/profile/models/my_profile_data.dart';
import '../../../features/profile/models/my_dependent_data.dart';


class MockProfileData {
  static List<MyProfileData> profileData = [
    const MyProfileData(
      id: '1',
      name: 'Haris Jamal',
      email: 'haris@gmail.com',
      nationality: 'Malaysian',
      phoneNumber: '+60123456789',
      identificationType: IdentificationType.ic,
      identificationnumber: '800731-14-5678',
      dateOfBirth: '1980-07-31',
      genderType: GenderType.male,
      ethnicity: 'Malay',
      address: '10, Jalan Ampang',
      district: 'Kuala Lumpur',
      city: 'Kuala Lumpur',
      postcode: '50450',
      state: 'Wilayah Persekutuan',
    ),
  ];
}

class MockMedicalHistoryData {
  static List<MyMedicalHistory> medicalHistory = [
    const MyMedicalHistory(
      id: '1',
      condition: 'Asthma',
      diagnosisDate: '2010-05-15',
      treatment: 'Inhaler',
      notes: 'Mild asthma, use inhaler as needed.',
    ),
    const MyMedicalHistory(
      id: '2',
      condition: 'Diabetes Type 2',
      diagnosisDate: '2015-08-20',
      treatment: 'Metformin',
      notes: 'Monitor blood sugar levels regularly.',
    ),
  ];
}

class MockAllergiesData {
  static List<MyAllergies> myAllergies = [
    const MyAllergies(
      id: '1',
      allergen: 'Peanuts',
      reaction: 'Anaphylaxis',
      notes: 'Carries an epinephrine auto-injector.',
    ),
    const MyAllergies(
      id: '2',
      allergen: 'Penicillin',
      reaction: 'Rash',
      notes: 'Avoid penicillin and related antibiotics.',
    ),
  ];
}

class MockDependentsData {
  static List<MyDependent> dependents = [
    const MyDependent(
      id: '1',
      guardianId: '1',
      dependentUserId: '2',
      dependentType: DependentType.child,
      name: 'Hannah Ghani',
      relationshipLabel: 'Daughter',
      dateOfBirth: '2000-09-19',
      canViewFullProfile: true,
    ),
    const MyDependent(
      id: '2',
      guardianId: '1',
      dependentUserId: '3',
      dependentType: DependentType.child,
      name: 'Wan Rosli',
      relationshipLabel: 'Son',
      dateOfBirth: '2002-03-01',
      canViewFullProfile: true,
    ),
  ];
}