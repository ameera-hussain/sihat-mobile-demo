import 'package:flutter/foundation.dart';
import '../models/vitals_reading.dart';
import '../../../mock_data/mock_vitals.dart';

class VitalsProvider extends ChangeNotifier {
  List<VitalsReading> _readings = [];
  List<MedicalDocument> _documents = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<VitalsReading> get readings => _readings;
  List<MedicalDocument> get documents => _documents;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // TODO BACKEND
  Future<void> fetchVitals() async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600)); // simulates network latency

    _readings = MockVitals.readings;
    _documents = MockVitals.documents;
    _isLoading = false;
    notifyListeners();
  }

   // TODO BACKEND
  Future<void> addReading(VitalsReading reading) async {
    _readings = [reading, ..._readings];
    notifyListeners();
  }

  // TODO BACKEND
  Future<void> uploadDocument(String fileName, String fileType) async {
    final doc = MedicalDocument(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      fileName: fileName,
      fileType: fileType,
      uploadedAt: DateTime.now(),
      filePath: '/mock/docs/$fileName',
    );
    _documents = [doc, ..._documents];
    notifyListeners();
  }

  // TODO BACKEND
  void deleteDocument(String id) {
    _documents = _documents.where((d) => d.id != id).toList();
    notifyListeners();
  }
}
