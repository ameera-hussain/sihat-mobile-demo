import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../mock_data/mock_appointments_data.dart';
import '../models/appointments_data.dart';

class AppointmentsProvider with ChangeNotifier {
  List<Appointment> _appointments = [];
  bool _isLoading = false;

  void _notifySafely() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });
  }

  List<Appointment> get appointments => _appointments;
  // Reflects only list fetch state from fetchAppointments(), not local
  // per-action saving states (such as cancel/reschedule) managed in UI.
  bool get isLoading => _isLoading;

  List<Appointment> get upcomingAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) => a.date.isAfter(now) && a.status != AppointmentStatus.cancelled,
        )
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<Appointment> get pastAppointments {
    final now = DateTime.now();
    return _appointments
        .where(
          (a) => !a.date.isAfter(now) || a.status == AppointmentStatus.cancelled,
        )
        .toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> fetchAppointments() async {
    _isLoading = true;
    _notifySafely();

    await Future.delayed(const Duration(milliseconds: 400));

    _appointments = MockAppointmentsData.appointments;

    _isLoading = false;
    _notifySafely();
  }

  Future<Appointment?> fetchAppointmentById(String appointmentId) async {
    // Stubbed local resolution that can later be swapped for an API call.
    if (_appointments.isEmpty) {
      await fetchAppointments();
    }

    try {
      return _appointments.firstWhere((appointment) => appointment.id == appointmentId);
    } catch (_) {
      return null;
    }
  }

  Future<bool> rescheduleAppointment(String appointmentId, DateTime newDate) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return false;
    if (_appointments[index].status != AppointmentStatus.scheduled) return false;

    await Future.delayed(const Duration(milliseconds: 300));
    _appointments[index] = _appointments[index].copyWith(date: newDate);
    _notifySafely();
    return true;
  }

  Future<bool> cancelAppointment(String appointmentId) async {
    final index = _appointments.indexWhere((a) => a.id == appointmentId);
    if (index == -1) return false;
    if (_appointments[index].status != AppointmentStatus.scheduled) return false;

    await Future.delayed(const Duration(milliseconds: 250));
    _appointments[index] = _appointments[index].copyWith(
      status: AppointmentStatus.cancelled,
    );
    _notifySafely();
    return true;
  }

  Future<bool> addAppointmentFromBookingSummary(
    AppointmentBookingSummaryData summary,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final appointment = Appointment(
      id: 'apt-${DateTime.now().microsecondsSinceEpoch}',
      clinicName: summary.clinicName,
      date: summary.appointmentDateTime,
      type: summary.type,
      status: AppointmentStatus.scheduled,
      iconColor: Colors.green,
      iconAccent: Colors.white,
    );

    _appointments = [..._appointments, appointment];
    _notifySafely();
    return true;
  }
}

