import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/responsive/responsive_layout.dart';
import 'core/responsive/mobile_scaffold.dart';
import 'core/responsive/tablet_scaffold.dart';
import 'core/responsive/desktop_scaffold.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/appointments/screens/appointments_screen.dart';
import 'features/vitals/screens/vitals_screen.dart';
import 'features/ai_chat/screens/chat_dashboard.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/settings/screens/settings_main.dart';
import 'features/payments/screens/payment_main.dart';
import 'features/reminders/screens/reminders_screen.dart';
import 'features/reminders/screens/food_log_entry_screen.dart';
import 'features/appointments/screens/appointment_detail_entry_screen.dart';
import 'features/appointments/screens/appointment_reschedule.dart';
import 'features/settings/screens/account_information.dart';
import 'features/settings/screens/billing_subscription.dart';
import 'core/widgets/call_bubble_overlay.dart';
import 'core/services/local_notification_service.dart';
import 'features/notifications/screens/notification_list_screen.dart';
import 'features/auth/screens/logout_screen.dart';
import 'features/profile/screens/my_profile.dart';

// Needed so CallBubbleOverlay can push a fresh VideoCallScreen onto
// the SAME navigator that GoRouter manages, from outside any single
// screen's BuildContext (e.g. when the user taps the floating bubble).
final rootNavigatorKey = GlobalKey<NavigatorState>();

class SihatApp extends StatefulWidget {
  const SihatApp({super.key});

  @override
  State<SihatApp> createState() => _SihatAppState();
}

class _SihatAppState extends State<SihatApp> {
  @override
  void initState() {
    super.initState();
    // Registered once, after the first frame, so rootNavigatorKey has a
    // valid context to navigate with when a notification is tapped.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      LocalNotificationService.instance.setOnTapCallback((payload) {
        final context = rootNavigatorKey.currentContext;
        if (context == null) return;

        // payload looks like 'reminder:<notificationId>'. For now this
        // just routes to the reminders list; once reminders have their
        // own detail route, parse the id out and push that instead.
        context.go('/reminders');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Sihat',
      theme: ThemeData(
        useMaterial3: true,
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE9E5F7),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                color: Color(0xFF5D53A3),
                fontWeight: FontWeight.w600,
              );
            }
            return const TextStyle(color: Colors.grey);
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Color(0xFF5D53A3));
            }
            return const IconThemeData(color: Colors.grey);
          }),
        ),
      ),
      routerConfig: _router,
      // Wraps EVERY screen the router shows with the call bubble overlay,
      // so a minimized call floats on top regardless of which route is
      // currently active.
      builder: (context, child) => CallBubbleOverlay(
        navigatorKey: rootNavigatorKey,
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}

final _router = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: '/dashboard',
  routes: [
    GoRoute(path: '/login', builder: (_, _) => const LoginScreen()),
    ShellRoute(
      builder: (context, state, child) => ResponsiveLayout(
        mobileScaffold: MobileScaffold(child: child),
        tabletScaffold: TabletScaffold(child: child),
        desktopScaffold: DesktopScaffold(child: child),
      ),
      routes: [
        GoRoute(
          path: '/dashboard',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: DashboardScreen()),
        ),
        GoRoute(
          path: '/appointments',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: AppointmentsScreen()),
        ),
        GoRoute(
          path: '/appointments/detail/:appointmentId',
          builder: (_, state) {
            final appointmentId = state.pathParameters['appointmentId'] ?? '';
            return AppointmentDetailEntryScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: '/appointments/reschedule/:appointmentId',
          builder: (_, state) {
            final appointmentId = state.pathParameters['appointmentId'] ?? '';
            return AppointmentRescheduleScreen(appointmentId: appointmentId);
          },
        ),
        GoRoute(
          path: '/reminders',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: RemindersScreen()),
        ),
        GoRoute(
          path: '/food-log/entry',
          pageBuilder: (_, state) => NoTransitionPage(
            child: FoodLogEntryScreen(
              reminderTitle:
                  state.uri.queryParameters['title'] ?? 'Food Log Reminder',
            ),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (_, _) => const NoTransitionPage(child: ProfileScreen()),
        ),
        GoRoute(
          path: '/vitals',
          pageBuilder: (_, _) =>
              const NoTransitionPage(child: VitalsScreen()),
        ),
        GoRoute(
          path: '/ask-ari',
          pageBuilder: (_, state) => NoTransitionPage(
            child: ChatDashboardScreen(
              initialPrompt: state.uri.queryParameters['q'],
            ),
          ),
        ),
        GoRoute(
          path: '/payments',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: PaymentMainScreen(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: SettingsMainScreen(),
          ),
        ),
        GoRoute(
          path: '/logout',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: LogoutScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/account_information',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: AccountInformationScreen(),
          ),
        ),
        GoRoute(
          path: '/settings/billing_subscription',
          pageBuilder: (_, _) => const NoTransitionPage(
            child: BillingSubscriptionScreen(),
          ),
        ),
        GoRoute(
  path: '/notifications',
  pageBuilder: (_, _) =>
      const NoTransitionPage(child: NotificationListScreen()),
),
      ],
    ),
  ],
);

