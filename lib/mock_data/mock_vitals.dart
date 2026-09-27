import '../features/vitals/models/vitals_reading.dart';

class MockVitals {
  static final List<VitalsReading> readings = [
    VitalsReading(
      id: 'v1',
      type: 'Blood Pressure',
      value: '120/80',
      unit: 'mmHg',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: VitalsStatus.normal,
    ),
    VitalsReading(
      id: 'v2',
      type: 'Heart Rate',
      value: '92',
      unit: 'bpm',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      status: VitalsStatus.warning,
      note: 'Slightly elevated — recorded post-exercise.',
    ),
    VitalsReading(
      id: 'v3',
      type: 'Blood Sugar',
      value: '5.4',
      unit: 'mmol/L',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: VitalsStatus.normal,
    ),
    VitalsReading(
      id: 'v4',
      type: 'SpO2',
      value: '98',
      unit: '%',
      date: DateTime.now().subtract(const Duration(days: 1)),
      status: VitalsStatus.normal,
    ),
    VitalsReading(
      id: 'v5',
      type: 'Temperature',
      value: '38.5',
      unit: '°C',
      date: DateTime.now().subtract(const Duration(days: 2)),
      status: VitalsStatus.critical,
      note: 'Fever — consult doctor if persists.',
    ),
  ];

  static final List<MedicalDocument> documents = [
    MedicalDocument(
      id: 'd1',
      fileName: 'blood_test_june2025.pdf',
      fileType: 'pdf',
      uploadedAt: DateTime.now().subtract(const Duration(days: 5)),
      filePath: '/mock/docs/blood_test_june2025.pdf',
    ),
    MedicalDocument(
      id: 'd2',
      fileName: 'xray_chest.jpg',
      fileType: 'image',
      uploadedAt: DateTime.now().subtract(const Duration(days: 12)),
      filePath: '/mock/docs/xray_chest.jpg',
    ),
  ];
}
