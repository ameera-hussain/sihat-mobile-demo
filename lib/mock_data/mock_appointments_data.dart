import 'package:flutter/material.dart';
import '../features/appointments/models/appointments_data.dart';

class MockAppointmentsData {
  static List<Appointment> appointments = [
    // Upcoming
    Appointment(
      id: 'apt-1',
      clinicName: 'Dr. Smith - Dental Clinic',
      date: DateTime.now().add(const Duration(days: 1, hours: 10)),
      type: AppointmentType.walkin,
      status: AppointmentStatus.scheduled,
      iconColor: Colors.green,
      iconAccent: Colors.white,
    ),
    Appointment(
      id: 'apt-2',
      clinicName: 'Dr. Johnson - Eye Care Center',
      date: DateTime.now().add(const Duration(days: 2, hours: 14)),
      type: AppointmentType.teleconsultation,
      status: AppointmentStatus.scheduled,
      iconColor: Colors.green,
      iconAccent: Colors.white,
    ),
    Appointment(
      id: 'apt-3',
      clinicName: 'Dr. Lee - Rehab Center',
      date: DateTime.now().add(const Duration(days: 4, hours: 11)),
      type: AppointmentType.physical,
      status: AppointmentStatus.scheduled,
      iconColor: Colors.green,
      iconAccent: Colors.white,
    ),
    // Past
    Appointment(
      id: 'apt-4',
      clinicName: 'Dr. Brown - Health Clinic',
      date: DateTime.now().subtract(const Duration(days: 3, hours: 9)),
      type: AppointmentType.emergency,
      status: AppointmentStatus.completed,
      iconColor: Colors.grey,
      iconAccent: Colors.white,
    ),
    Appointment(
      id: 'apt-5',
      clinicName: 'Dr. Davis - Wellness Center',
      date: DateTime.now().subtract(const Duration(days: 8, hours: 15)),
      type: AppointmentType.teleconsultation,
      status: AppointmentStatus.completed,
      iconColor: Colors.grey,
      iconAccent: Colors.white,
    ),
    Appointment(
      id: 'apt-6',
      clinicName: 'Dr. Tan - Path Lab',
      date: DateTime.now().subtract(const Duration(days: 15)),
      type: AppointmentType.walkin,
      status: AppointmentStatus.cancelled,
      iconColor: Colors.grey,
      iconAccent: Colors.white,
    ),
    Appointment(
      id: 'apt-7',
      clinicName: 'Dr. Yusuf - Heart Centre',
      date: DateTime.now().subtract(const Duration(days: 22)),
      type: AppointmentType.physical,
      status: AppointmentStatus.completed,
      iconColor: Colors.grey,
      iconAccent: Colors.white,
    ),
  ];
}
