import 'package:flutter/material.dart';

enum AppointmentStatus { scheduled, cancelled, completed }

class Appointment {
  final String id;
  final String clinicName;
  final DateTime date;
  final AppointmentType type;
  final AppointmentStatus status;
  final Color iconColor;
  final Color iconAccent;

  const Appointment({
    required this.id,
    required this.clinicName,
    required this.date,
    required this.type,
    this.status = AppointmentStatus.scheduled,
    required this.iconColor,
    required this.iconAccent,
  });

  Appointment copyWith({
    String? id,
    String? clinicName,
    DateTime? date,
    AppointmentType? type,
    AppointmentStatus? status,
    Color? iconColor,
    Color? iconAccent,
  }) {
    return Appointment(
      id: id ?? this.id,
      clinicName: clinicName ?? this.clinicName,
      date: date ?? this.date,
      type: type ?? this.type,
      status: status ?? this.status,
      iconColor: iconColor ?? this.iconColor,
      iconAccent: iconAccent ?? this.iconAccent,
    );
  }
}

enum AppointmentType {walkin, teleconsultation, physical, emergency}

class AppointmentBookingSummaryData {
  final String clinicName;
  final String clinicAddress;
  final String patientName;
  final AppointmentType type;
  final String reason;
  final DateTime appointmentDateTime;

  const AppointmentBookingSummaryData({
    required this.clinicName,
    required this.clinicAddress,
    required this.patientName,
    required this.type,
    required this.reason,
    required this.appointmentDateTime,
  });
}