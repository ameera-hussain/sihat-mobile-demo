import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_models.dart';
import '../../../mock_data/mock_auth.dart';

class AuthProvider extends ChangeNotifier {
  AuthMode _mode = AuthMode.login;
  bool _isLoading = false;
  String? _errorMessage;
  bool _obscurePassword = true;

  // OTP-specific state
  String? _pendingEmail; // email currently being verified
  int _otpSecondsRemaining = 0;
  Timer? _otpTimer;

  // Logout state
  bool _hasPreviousLogin = false;
  String? _prefillEmail;

  AuthMode get mode => _mode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get obscurePassword => _obscurePassword;
  String? get pendingEmail => _pendingEmail;
  int get otpSecondsRemaining => _otpSecondsRemaining;
  bool get canResendOtp => _otpSecondsRemaining <= 0;
  bool get hasPreviousLogin => _hasPreviousLogin;
  String? get prefillEmail => _prefillEmail;

  AuthProvider() {
    _initializeState();
  }

  Future<void> _initializeState() async {
    await _loadPersistenceState();
    notifyListeners();
  }

  Future<void> _loadPersistenceState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _hasPreviousLogin = prefs.getBool('hasPreviousLogin') ?? false;
      _prefillEmail = prefs.getString('prefillEmail');
    } catch (e) {
      // Platform channel may not be ready yet on app startup
      debugPrint('Warning: Could not load persistence state (will retry on next login): $e');
    }
  }

  void setMode(AuthMode mode) {
    _mode = mode;
    _errorMessage = null;
    notifyListeners();
  }

  void toggleObscurePassword() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  // BACKEND: replace body with actual login logic
  // check if there was previous login, different message like "welcome back"
  Future<AuthResult> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final isValid =
        email == MockAuth.validEmail && password == MockAuth.validPassword;

    _isLoading = false;
    if (!isValid) {
      _errorMessage = 'Invalid email or password.';
      notifyListeners();
      return const AuthResult(success: false, errorMessage: 'Invalid email or password.');
    }

    // Persist login state for next app launch
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasPreviousLogin', true);
      await prefs.setString('prefillEmail', email);
      _hasPreviousLogin = true;
      _prefillEmail = email;
    } catch (e) {
      // Platform channel may not be ready — log but don't crash
      debugPrint('Warning: Could not persist login state (data will not persist across app restarts): $e');
      // Still update in-memory state so app works during this session
      _hasPreviousLogin = true;
      _prefillEmail = email;
    }

    notifyListeners();
    return AuthResult(success: true, user: MockAuth.mockUser);
  }

  // BACKEND: Account creation logic
  Future<AuthResult> createAccount(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _isLoading = false;
    _pendingEmail = email;
    notifyListeners();

    startOtpTimer();
    return const AuthResult(success: true); // proceeds to OTP screen
  }

  // BACKEND: Google login
  Future<AuthResult> signInWithGoogle() async {
    _isLoading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 700));
    _isLoading = false;
    notifyListeners();
    return AuthResult(success: true, user: MockAuth.mockUser);
  }

  //  OTP flow ---------------------------------------------

  void startOtpTimer({int seconds = 38}) {
    _otpTimer?.cancel();
    _otpSecondsRemaining = seconds;
    notifyListeners();
    _otpTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpSecondsRemaining <= 0) {
        timer.cancel();
        return;
      }
      _otpSecondsRemaining--;
      notifyListeners();
    });
  }

  // BACKEND: verify OTP logic
  Future<AuthResult> verifyOtp(String code) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 600));

    _isLoading = false;
    if (code.length != 6) {
      _errorMessage = 'Please enter the full 6-digit code.';
      notifyListeners();
      return AuthResult(success: false, errorMessage: _errorMessage);
    }

    notifyListeners();
    return AuthResult(success: true, user: MockAuth.mockUser);
  }

  // BACKEND: replace body with → await authService.resendOtp(pendingEmail);
  Future<void> resendOtp() async {
    if (!canResendOtp) return;
    startOtpTimer();
  }

  //  Forgot password flow ---------------------------------------------

  // BACKEND: send reset link logic
  Future<AuthResult> sendResetLink(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    _isLoading = false;
    notifyListeners();
    return const AuthResult(success: true);
  }

  // Logout flow ---------------------------------------------

  /// Clears auth/session state only. Cached app data (profile, tracked entries,
  /// favorites) persists on disk after logout.
  ///
  /// Order of operations:
  /// 1. Clear SharedPreferences auth/session keys
  /// 2. Reset provider state (_mode, _errorMessage, _pendingEmail)
  /// 3. Cancel OTP timer
  /// 4. Call notifyListeners()
  /// 5. (Navigation happens at call site via pushNamedAndRemoveUntil)
  ///
  /// Note: _hasPreviousLogin is NOT cleared — its purpose is to remember
  /// there was a prior login on this device for welcome-back messaging.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Give a brief moment for UI to show loading state
      await Future.delayed(const Duration(milliseconds: 500));

      // 1. Clear auth/session keys from SharedPreferences (not app-data keys)
      try {
        // await prefs.remove('authToken');
        // await prefs.remove('refreshToken');
        // TODO: Remove auth/session keys when they exist (e.g., token keys)
      } catch (e) {
        debugPrint('Warning: Could not clear auth/session from SharedPreferences: $e');
      }

      // 2. Reset provider state
      _mode = AuthMode.login;
      _errorMessage = null;
      _pendingEmail = null;

      // 3. Cancel OTP timer
      _otpTimer?.cancel();
      _otpSecondsRemaining = 0;

      _isLoading = false;

      // TODO: call authRepository.logout() here once backend API is available
      // await authRepository.logout();

    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Logout failed: $e';
      debugPrint('Error during logout: $e');
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _otpTimer?.cancel();
    super.dispose();
  }
}
