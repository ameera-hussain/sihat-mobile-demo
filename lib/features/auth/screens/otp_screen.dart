import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../widgets/sihat_logo.dart';
import '../widgets/otp_code_input.dart';
import '../../../mock_data/mock_auth.dart';

class OtpScreen extends StatefulWidget {
  final String email;
  const OtpScreen({super.key, required this.email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String _code = '';

  @override
  void initState() {
    super.initState();
    // Start the resend countdown as soon as this screen opens,
    // in case the user navigated here directly without going through signup.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.otpSecondsRemaining <= 0) {
        auth.startOtpTimer();
      }
    });
  }

  Future<void> _handleVerify(AuthProvider auth) async {
    final result = await auth.verifyOtp(_code);
    if (!mounted) return;
    if (result.success) {
      // TODO: navigate to dashboard → context.go('/dashboard')
    } else if (result.errorMessage != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.errorMessage!)));
    }
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F3F6),
      body: SafeArea(
        child: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  const SihatLogo(height: 60),
                  const SizedBox(height: 28),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 64,
                          width: 64,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEDEBFA),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            color: Color(0xFF5D53A3),
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          'Verify Your Email',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "We've sent a 6-digit verification code to",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          MockAuth.maskEmail(widget.email),
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 24),
                        OtpCodeInput(
                          onChanged: (code) => setState(() => _code = code),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: const Color(0xFF5D53A3),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: auth.isLoading
                                ? null
                                : () => _handleVerify(auth),
                            child: auth.isLoading
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Verify',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Didn't receive the code?",
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: auth.canResendOtp ? auth.resendOtp : null,
                          child: Text(
                            'Resend OTP',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: auth.canResendOtp
                                  ? const Color(0xFF5D53A3)
                                  : Colors.grey.shade400,
                            ),
                          ),
                        ),
                        if (!auth.canResendOtp) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Available in ${_formatTime(auth.otpSecondsRemaining)}',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back, size: 16),
                        label: const Text('Back to Login'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.black87),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: () {
                          // TODO: navigate to support screen / open help chat
                        },
                        icon: const Icon(Icons.help_outline, size: 16),
                        label: const Text('Support'),
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.black87),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
