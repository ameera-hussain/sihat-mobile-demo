import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/activity_monitor_row.dart';
import '../widgets/ask_ari_bar.dart';
import '../widgets/hero_banner.dart';
import '../widgets/section_header.dart';
import '../../reminders/models/reminder.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../reminders/widgets/reminder_tile.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final String _userName = 'Haris Jamal'; // should come from username but hardcoded for now

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<DashboardProvider>().fetchDashboard();
      final remindersProvider = context.read<RemindersProvider>();
      await remindersProvider.fetchReminders();
      remindersProvider.runAutoResolution();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<DashboardProvider, RemindersProvider>(
      builder: (
        context,
        dashboardProvider,
        remindersProvider,
        _,
      ) {
        if (dashboardProvider.isLoading ||
            remindersProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final topReminders = remindersProvider.topReminders(limit: 5);

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            Text(
              'Welcome, $_userName',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            const AskAriBar(),
            const SizedBox(height: 16),
            const HeroBanner(),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Activity Monitor',
              showSeeAll: true,
              seeAllRoute: '/vitals',
            ),
            const SizedBox(height: 12),
            ActivityMonitorRow(metrics: dashboardProvider.activityMetrics),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Reminders',
              showSeeAll: true,
              seeAllRoute: '/reminders',
            ),
            const SizedBox(height: 12),
            if (topReminders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text('No reminders yet.'),
              )
            else
              ...topReminders.map(
                (reminder) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: ReminderTile(
                    reminder: reminder,
                    onTap: reminder.type == ReminderType.appointment
                        ? () {
                            final appointmentId = reminder.appointmentId;
                            if (appointmentId == null || appointmentId.isEmpty) {
                              return;
                            }
                            context.push('/appointments/detail/$appointmentId');
                          }
                        : null,
                  ),
                ),
              ),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}