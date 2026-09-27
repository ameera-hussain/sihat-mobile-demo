import '../features/auth/models/auth_models.dart';

class MockAuth {
  // Pretend this is the "registered" account for testing the login flow.
  static const validEmail = 'haris@gmail.com';
  static const validPassword = 'password123';

  static const mockUser = AppUser(
    id: 'u1',
    email: validEmail,
    name: 'Haris Jamal',
  );

  // Used to mask the email on the OTP screen, e.g. "al**@rivers.com"
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2 || parts[0].length < 2) return email;
    final visible = parts[0].substring(0, 2);
    return '$visible**@${parts[1]}';
  }
}
