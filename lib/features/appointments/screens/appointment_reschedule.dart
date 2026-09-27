import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/appointments_data.dart';
import '../providers/appointments_provider.dart';

class AppointmentRescheduleScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentRescheduleScreen({super.key, required this.appointmentId});

  @override
  State<AppointmentRescheduleScreen> createState() => _AppointmentRescheduleScreenState();
}

class _AppointmentRescheduleScreenState extends State<AppointmentRescheduleScreen> {
  DateTime? _selectedDateTime;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final provider = context.read<AppointmentsProvider>();
      final isAlreadyLoaded = provider.appointments.any(
        (appointment) => appointment.id == widget.appointmentId,
      );
      if (!isAlreadyLoaded) {
        provider.fetchAppointmentById(widget.appointmentId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppointmentsProvider>(
      builder: (context, appointmentsProvider, _) {
        final appointment = _findAppointment(appointmentsProvider);

        if (appointmentsProvider.isLoading && appointment == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (appointment == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Reschedule Appointment')),
            body: const Center(child: Text('Appointment not found.')),
          );
        }

        final isEligible = appointment.status == AppointmentStatus.scheduled;
        final selectedDateTime = _selectedDateTime ?? appointment.date;

        return Scaffold(
          appBar: AppBar(title: const Text('Reschedule Appointment')),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.clinicName,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 6),
                Text(
                  _formatDateTime(appointment.date),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                _InfoRow(
                  label: 'Current slot',
                  value: _formatDateTime(appointment.date),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Selected slot',
                  value: _formatDateTime(selectedDateTime),
                ),
                if (!isEligible) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Only scheduled appointments can be rescheduled.',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    OutlinedButton.icon(
                      onPressed: !isEligible ? null : () => _pickDate(context),
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Pick Date'),
                    ),
                    OutlinedButton.icon(
                      onPressed: !isEligible ? null : () => _pickTime(context),
                      icon: const Icon(Icons.schedule),
                      label: const Text('Pick Time'),
                    ),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (!isEligible || _isSaving)
                        ? null
                        : () => _saveReschedule(appointmentsProvider, appointment),
                    child: Text(_isSaving ? 'Saving...' : 'Confirm Reschedule'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Appointment? _findAppointment(AppointmentsProvider provider) {
    try {
      return provider.appointments.firstWhere((a) => a.id == widget.appointmentId);
    } catch (_) {
      return null;
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final base = _selectedDateTime ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: base,
      firstDate: now,
      lastDate: now.add(const Duration(days: 180)),
    );

    if (picked == null || !mounted) {
      return;
    }

    final current = _selectedDateTime ?? base;
    setState(() {
      _selectedDateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        current.hour,
        current.minute,
      );
    });
  }

  Future<void> _pickTime(BuildContext context) async {
    final base = _selectedDateTime ?? DateTime.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: base.hour, minute: base.minute),
    );

    if (picked == null || !mounted) {
      return;
    }

    final current = _selectedDateTime ?? base;
    setState(() {
      _selectedDateTime = DateTime(
        current.year,
        current.month,
        current.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _saveReschedule(
    AppointmentsProvider provider,
    Appointment appointment,
  ) async {
    final selected = _selectedDateTime;
    if (selected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please pick a new date or time first.')),
      );
      return;
    }

    if (selected.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selected slot must be in the future.')),
      );
      return;
    }

    if (selected.isAtSameMomentAs(appointment.date)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please choose a different slot.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });
    final success = await provider.rescheduleAppointment(widget.appointmentId, selected);
    if (!mounted) {
      return;
    }

    if (!success) {
      setState(() {
        _isSaving = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to reschedule appointment.')),
      );
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.pop(true);
    });
  }

  String _formatDateTime(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$day/$month/$year $hour:$minute';
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}