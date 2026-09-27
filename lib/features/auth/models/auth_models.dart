class AuthResult {
  final bool success;
  final String? errorMessage;
  final AppUser? user;

  const AuthResult({
    required this.success,
    this.errorMessage,
    this.user,
  });
}

class AppUser {
  final String id;
  final String email;
  final String? name;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
  });
}

enum AuthMode { login, createAccount }
