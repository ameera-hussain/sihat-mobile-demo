import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/appointments/providers/appointments_provider.dart';
import 'features/dashboard/providers/dashboard_provider.dart';
import 'features/vitals/providers/vitals_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/profile/providers/dependents_provider.dart';
import 'features/ai_chat/providers/ai_chat_provider.dart';
import 'features/payments/providers/payment_providers.dart';
import 'features/reminders/providers/reminders_provider.dart';
import 'features/notifications/providers/notifications_provider.dart';
import 'features/settings/providers/billing_subscription_provider.dart';
import 'features/profile/providers/profile_provider.dart';
import 'features/profile/providers/medical_history_provider.dart';
import 'features/profile/providers/allergies_provider.dart';
import 'core/services/call_session_controller.dart';
import 'core/services/local_notification_service.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Wrapped defensively: a notification-setup failure on any one platform
  // (e.g. a missing platform-specific settings object) should never take
  // down the whole app before it can even render.
  try {
    await LocalNotificationService.instance.init();
    await LocalNotificationService.instance.requestPermissions();
  } catch (e, stackTrace) {
    debugPrint('Local notification setup failed: $e');
    debugPrintStack(stackTrace: stackTrace);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentsProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProxyProvider<NotificationsProvider, RemindersProvider>(
          create: (context) => RemindersProvider(
            notificationsProvider: context.read<NotificationsProvider>(),
          ),
          update: (context, notifications, previous) =>
              previous ?? RemindersProvider(notificationsProvider: notifications),
        ),
        ChangeNotifierProvider(create: (_) => VitalsProvider()),
        ChangeNotifierProvider(create: (_) => AiChatProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProviders()),
        ChangeNotifierProvider(create: (_) => BillingSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => CallSessionController()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => MedicalHistoryProvider()),
        ChangeNotifierProvider(create: (_) => AllergiesProvider()),
        ChangeNotifierProvider(create: (_) => DependentsProvider()),
        // add more providers here
      ],
      child: const SihatApp(),
    ),
  );
}
