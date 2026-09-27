import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/appointments_data.dart';
import '../providers/appointments_provider.dart';
import 'appointment_detail_screen.dart';

class AppointmentDetailEntryScreen extends StatefulWidget {
  final String appointmentId;

  const AppointmentDetailEntryScreen({
    super.key,
    required this.appointmentId,
  });

  @override
  State<AppointmentDetailEntryScreen> createState() =>
      _AppointmentDetailEntryScreenState();
}

class _AppointmentDetailEntryScreenState
    extends State<AppointmentDetailEntryScreen> {
  Future<Appointment?>? _initialLoad;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _initialLoad = context
            .read<AppointmentsProvider>()
            .fetchAppointmentById(widget.appointmentId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initialLoad == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<Appointment?>(
      future: _initialLoad!,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        return Consumer<AppointmentsProvider>(
          builder: (context, provider, _) {
            Appointment? appointment;
            try {
              appointment = provider.appointments
                  .firstWhere((a) => a.id == widget.appointmentId);
            } catch (_) {
              appointment = snapshot.data;
            }

            if (appointment == null) {
              return const Center(child: Text('Appointment not found.'));
            }

            return AppointmentDetailScreen(appointment: appointment);
          },
        );
      },
    );
  }
}
