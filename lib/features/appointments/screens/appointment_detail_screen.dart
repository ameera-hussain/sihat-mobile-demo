import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/appointments_data.dart';
import '../providers/appointments_provider.dart';
import '../../../core/services/call_session_controller.dart';
import '../../../core/constants/app_decorations.dart';
import '../widgets/video_call_screen.dart';

class AppointmentDetailScreen extends StatelessWidget {
  final Appointment appointment;
  const AppointmentDetailScreen({super.key, required this.appointment});

  // TEMP: for testing/demo only — remove when not needed.
  static bool debugForceJoinAvailable = true;

  bool get _isTeleconsult => appointment.type == AppointmentType.teleconsultation;
  bool get _isOperational => appointment.status == AppointmentStatus.scheduled;

  static const Duration _joinWindowBefore = Duration(minutes: 15);
  static const Duration _joinWindowAfter = Duration(hours: 1);

  bool get _canJoinNow {
    var forceJoinInDebug = false;
    assert(() {
      forceJoinInDebug = debugForceJoinAvailable;
      return true;
    }());
    if (forceJoinInDebug) {
      return true;
    }

    final now = DateTime.now();
    final windowStart = appointment.date.subtract(_joinWindowBefore);
    final windowEnd = appointment.date.add(_joinWindowAfter);
    return now.isAfter(windowStart) && now.isBefore(windowEnd);
  }

  String get _joinAvailabilityLabel {
    final now = DateTime.now();
    final windowStart = appointment.date.subtract(_joinWindowBefore);
    if (now.isBefore(windowStart)) {
      return 'Available 15 min before your appointment';
    }
    return 'This call is no longer available';
  }

  @override
  Widget build(BuildContext context) {
    // Watching this means the button/section below automatically swaps
    // between "Join Video Call" and "Return to Call" as the call's
    // active/minimized state changes — including while this screen sits
    // underneath the floating bubble.
    final call = context.watch<CallSessionController>();
    final callActiveHere = call.isActiveFor(appointment);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointment Details',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showManageAppointmentSheet(context),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: cardDecoration.copyWith(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFECE8FB)),
              ),
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.clinicName,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _detailRow(
                    context,
                    icon: Icons.schedule_outlined,
                    text: _formatDate(appointment.date),
                  ),
                  const SizedBox(height: 4),
                  _detailRow(
                    context,
                    icon: _typeIcon(appointment.type),
                    text: _typeLabel(appointment.type),
                  ),
                  const SizedBox(height: 8),
                  _statusChip(appointment.status),
                ],
              ),
            ),
            if (!_isOperational) ...[
              const SizedBox(height: 10),
              Text(
                'This appointment is ${_statusLabel(appointment.status).toLowerCase()}, so Join Call and Reschedule are unavailable.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const Spacer(),
            if (_isTeleconsult && _isOperational)
              callActiveHere
                  ? _buildReturnToCallSection(context, call)
                  : _buildJoinCallSection(context),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(
    BuildContext context, {
    required IconData icon,
    required String text,
  }) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusChip(AppointmentStatus status) {
    final (label, color) = switch (status) {
      AppointmentStatus.scheduled => ('Scheduled', const Color(0xFF2E7D32)),
      AppointmentStatus.cancelled => ('Cancelled', const Color(0xFFC62828)),
      AppointmentStatus.completed => ('Completed', const Color(0xFF1565C0)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildJoinCallSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!_canJoinNow) ...[
          Text(
            _joinAvailabilityLabel,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
        ],
        FilledButton.icon(
          onPressed: !_canJoinNow
              ? null
              : () {
                  context.read<CallSessionController>().start(appointment);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const VideoCallScreen(),
                    ),
                  );
                },
          icon: const Icon(Icons.videocam),
          label: const Text('Join Video Call'),
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF5D53A3),
            disabledBackgroundColor: Colors.grey.shade300,
            disabledForegroundColor: Colors.grey.shade600,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  // NEW: shown instead of the Join button once this appointment's call
  // is already active (whether the user is fully in it or it's currently
  // minimized to the floating bubble somewhere else).
  Widget _buildReturnToCallSection(
    BuildContext context,
    CallSessionController call,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Call in progress',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () {
            call.restore();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const VideoCallScreen()),
            );
          },
          icon: const Icon(Icons.videocam),
          label: const Text('Return to Call'),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF5D53A3),
            side: const BorderSide(color: Color(0xFF5D53A3)),
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  String _typeLabel(AppointmentType type) {
    switch (type) {
      case AppointmentType.walkin:
        return 'Walk-in';
      case AppointmentType.teleconsultation:
        return 'Teleconsultation';
      case AppointmentType.physical:
        return 'In-person';
      case AppointmentType.emergency:
        return 'Emergency';
    }
  }

  String _statusLabel(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.scheduled:
        return 'Scheduled';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.completed:
        return 'Completed';
    }
  }

  IconData _typeIcon(AppointmentType type) {
    switch (type) {
      case AppointmentType.walkin:
        return Icons.directions_walk;
      case AppointmentType.teleconsultation:
        return Icons.video_call_rounded;
      case AppointmentType.physical:
        return Icons.local_hospital_rounded;
      case AppointmentType.emergency:
        return Icons.emergency;
    }
  }

  Future<void> _showManageAppointmentSheet(BuildContext context) async {
    final canReschedule = appointment.status == AppointmentStatus.scheduled;
    final canCancel = appointment.status == AppointmentStatus.scheduled;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Manage Appointment',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                appointment.clinicName,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
              const SizedBox(height: 4),
              Text(_formatDate(appointment.date)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,           
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF5D53A3),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: !canReschedule
                      ? null
                      : () async {
                          Navigator.of(sheetContext).pop();
                          await Future<void>.delayed(Duration.zero);
                          if (!context.mounted) {
                            return;
                          }
                          final updated = await context.push<bool>(
                            '/appointments/reschedule/${appointment.id}',
                          );
                          if (context.mounted && updated == true) {
                            // Intentionally no snackbar here to avoid overlay activation
                            // during navigator re-attachment/layout transitions.
                          }
                        },
                  icon: const Icon(Icons.event_repeat),
                  label: const Text('Reschedule'),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFC62828),
                    side: const BorderSide(color: Color(0xFFC62828)),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: !canCancel
                      ? null
                      : () async {
                          final shouldCancel = await showDialog<bool>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: const Text('Cancel Appointment?'),
                              content: const Text(
                                'Are you sure you want to cancel this appointment? This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(false),
                                  child: const Text('No'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.of(dialogContext).pop(true),
                                  child: const Text('Yes, Cancel'),
                                ),
                              ],
                            ),
                          );

                          if (shouldCancel != true || !context.mounted) {
                            return;
                          }

                          final provider = context.read<AppointmentsProvider>();
                          final success = await provider.cancelAppointment(appointment.id);
                          if (!context.mounted) {
                            return;
                          }

                          if (!success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Unable to cancel appointment.'),
                              ),
                            );
                            return;
                          }
                          Navigator.of(sheetContext).pop();
                        },
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Appointment'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} at ${_formatTime(date)}';

  String _formatTime(DateTime date) =>
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}
