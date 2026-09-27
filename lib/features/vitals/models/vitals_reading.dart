class VitalsReading {
  final String id;
  final String type;
  final String value;
  final String unit;
  final DateTime date;
  final VitalsStatus status;
  final String? note;

  const VitalsReading({
    required this.id,
    required this.type,
    required this.value,
    required this.unit,
    required this.date,
    required this.status,
    this.note,
  });
}

enum VitalsStatus { normal, warning, critical }

class MedicalDocument {
  final String id;
  final String fileName;
  final String fileType;
  final DateTime uploadedAt;
  final String filePath;

  const MedicalDocument({
    required this.id,
    required this.fileName,
    required this.fileType,
    required this.uploadedAt,
    required this.filePath,
  });
}
