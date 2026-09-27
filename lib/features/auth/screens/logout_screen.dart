import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class LogoutScreen extends StatefulWidget {
  const LogoutScreen({super.key});

  @override
  State<LogoutScreen> createState() => _LogoutScreenState();
}

class _LogoutScreenState extends State<LogoutScreen> {
  Future<void> _handleLogout(AuthProvider authProvider) async {
    await authProvider.logout();

    if (!mounted) return;

    // Clear the entire route stack and navigate to login
    if (context.mounted) {
      context.go('/login');
    }
  }

  Future<void> _handleCancel() async {
    if (mounted && context.mounted) {
      // Use GoRouter's pop to go back in the route stack, or navigate to dashboard
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/dashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Block system back button/gesture while on logout confirmation screen.
      // (The "Cancel" button's pop will still work normally — PopScope only
      // intercepts the system back gesture, not programmatic Navigator.pop())
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Consumer<AuthProvider>(
              builder: (context, authProvider, _) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Optional confirmation icon/illustration
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color(0xFFFDE8F0),
                        ),
                        child: Icon(
                          Icons.logout,
                          size: 40,
                          color: Color(0xFFE96DAA),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Confirmation message text
                      Text(
                        'Logout?',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Are you sure you want to log out from Sihat? You will need to log in again to access your account.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Primary "Confirm Logout" button or loading indicator
                      SizedBox(
                        width: double.infinity,
                        child: authProvider.isLoading
                            ? Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF5D53A3),
                                  ),
                                ),
                              )
                            : FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: Color(0xFF5D53A3),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                onPressed: () => _handleLogout(authProvider),
                                child: const Text(
                                  'Confirm Logout',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(height: 12),

                      // Secondary "Cancel" text button (disabled while loading)
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed:
                              authProvider.isLoading ? null : _handleCancel,
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: authProvider.isLoading
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}