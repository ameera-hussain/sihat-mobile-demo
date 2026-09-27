enum IdentificationType {
  passport,
  ic,
  drivingLicense,
  unhcrCard,
}

enum GenderType {
  male,
  female,
}

class MyProfileData {
  final String id;
  final String? name;
  final String? email;
  final String? nationality;
  final String? phoneNumber;
  final IdentificationType? identificationType;
  final String? identificationnumber;
  final String? dateOfBirth;
  final GenderType? genderType;
  final String? ethnicity;
  final String? address;
  final String? district;
  final String? city;
  final String? postcode;
  final String? state;

  const MyProfileData({
    this.id = '',
    this.name,
    this.email,
    this.nationality,
    this.phoneNumber,
    this.identificationType,
    this.identificationnumber,
    this.dateOfBirth,
    this.genderType,
    this.ethnicity,
    this.address,
    this.district,
    this.city,
    this.postcode,
    this.state,
  });
}

class MyMedicalHistory {
  final String id;
  final String? condition;
  final String? diagnosisDate;
  final String? treatment;
  final String? notes;

  const MyMedicalHistory({
    this.id = '',
    this.condition,
    this.diagnosisDate,
    this.treatment,
    this.notes,
  });
}

class MyAllergies {
  final String id;
  final String? allergen;
  final String? reaction;
  final String? severity;
  final String? notes;

  const MyAllergies({
    this.id = '',
    this.allergen,
    this.reaction,
    this.severity,
    this.notes,
  });
}

