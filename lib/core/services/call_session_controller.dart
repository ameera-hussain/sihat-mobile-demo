import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../features/appointments/models/appointments_data.dart';

/// Holds the state of an in-progress video call so it survives
/// navigation — e.g. when the call is minimized to a floating bubble
/// and the user browses other screens underneath it.
///
/// Provide this once near the root of the app (above MaterialApp),
/// e.g. with ChangeNotifierProvider(create: (_) => CallSessionController()).
class CallSessionController extends ChangeNotifier {
  Appointment? appointment;
  bool isActive = false;
  bool isMinimized = false;

  bool isMicOn = true;
  bool isCameraOn = true;
  bool isDoctorPrimary = true;

  Duration elapsed = Duration.zero;
  Timer? _timer;

  bool isActiveFor(Appointment other) =>
      isActive && appointment?.id == other.id;

  void start(Appointment appointment) {
    this.appointment = appointment;
    isActive = true;
    isMinimized = false;
    isMicOn = true;
    isCameraOn = true;
    isDoctorPrimary = true;
    elapsed = Duration.zero;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      elapsed += const Duration(seconds: 1);
      notifyListeners();
    });

    notifyListeners();
  }

  void minimize() {
    if (!isActive) return;
    isMinimized = true;
    notifyListeners();
  }

  void restore() {
    if (!isActive) return;
    isMinimized = false;
    notifyListeners();
  }

  void toggleMic() {
    isMicOn = !isMicOn;
    notifyListeners();
  }

  void toggleCamera() {
    isCameraOn = !isCameraOn;
    notifyListeners();
  }

  void toggleDoctorPrimary() {
    isDoctorPrimary = !isDoctorPrimary;
    notifyListeners();
  }

  void end() {
    _timer?.cancel();
    _timer = null;
    isActive = false;
    isMinimized = false;
    appointment = null;
    elapsed = Duration.zero;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
