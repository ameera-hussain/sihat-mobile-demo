import 'package:flutter/material.dart';
import '../models/appointments_data.dart';

class AppointmentBookingSummaryScreen extends StatefulWidget {
  final AppointmentBookingSummaryData summary;

  const AppointmentBookingSummaryScreen({
    super.key,
    required this.summary,
  });

  @override
  State<AppointmentBookingSummaryScreen> createState() =>
      _AppointmentBookingSummaryScreenState();
}

class _AppointmentBookingSummaryScreenState extends State<AppointmentBookingSummaryScreen> {
  static const Color _headerColor = Color(0xFF5D53A3);

  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final summary = widget.summary;

    return Scaffold(
      backgroundColor: const Color(0xFFE6E9F0),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDDE1EC),
        elevation: 0,
        title: const Text(
          'Book an Appointment',
          style: TextStyle(fontWeight: FontWeight.w700, color: Colors.black87),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                children: [
                  const SizedBox(height: 8),
                  const Text(
                    'Confirm your appointment',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF122147),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please check your appointment details and confirm',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey.shade600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _SummaryCard(summary: summary, headerColor: _headerColor),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFDDE3EF),
                          foregroundColor: Color(0xFF122147),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () => Navigator.of(context).pop(false),
                        child: const Text(
                          'Previous',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SizedBox(
                      height: 54,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: _headerColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: _isSubmitting ? null : _confirm,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Confirm',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirm() async {
    setState(() {
      _isSubmitting = true;
    });
    await Future.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }
}

class _SummaryCard extends StatelessWidget {
  final AppointmentBookingSummaryData summary;
  final Color headerColor;

  const _SummaryCard({required this.summary, required this.headerColor});

  @override
  Widget build(BuildContext context) {
    final dateLabel = _formatDate(summary.appointmentDateTime);
    final timeLabel = _formatTime(summary.appointmentDateTime);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: headerColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        summary.clinicName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        summary.clinicAddress,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.95),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _SummaryRow(label: 'Patient Name', value: summary.patientName),
          const Divider(height: 1),
          _SummaryRow(
            label: 'Appointment Type',
            value: _appointmentTypeLabel(summary.type),
          ),
          const Divider(height: 1),
          _SummaryRow(label: 'Reason', value: summary.reason),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Appointment Date',
                        style: TextStyle(
                          color: Colors.blueGrey.shade400,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dateLabel,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        color: Colors.blueGrey.shade400,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      timeLabel,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final dayName = days[date.weekday - 1];
    final monthName = months[date.month - 1];
    return '$dayName, ${date.day.toString().padLeft(2, '0')} $monthName ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final suffix = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  String _appointmentTypeLabel(AppointmentType type) {
    switch (type) {
      case AppointmentType.teleconsultation:
        return 'Teleconsultation';
      case AppointmentType.physical:
        return 'Physical Visit';
      case AppointmentType.emergency:
        return 'Emergency';
      case AppointmentType.walkin:
        return 'Walk-in';
    }
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: TextStyle(
              color: Colors.blueGrey.shade400,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.left,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}