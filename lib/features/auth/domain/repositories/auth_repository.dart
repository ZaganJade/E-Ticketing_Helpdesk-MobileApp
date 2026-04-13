import 'package:dartz/dartz.dart';
import '../entities/pengguna.dart';

/// Failure classes for authentication errors
abstract class AuthFailure {
  final String message;
  const AuthFailure(this.message);
}

class InvalidCredentialsFailure extends AuthFailure {
  const InvalidCredentialsFailure() : super('Email atau password salah');
}

class EmailAlreadyRegisteredFailure extends AuthFailure {
  const EmailAlreadyRegisteredFailure() : super('Email sudah terdaftar');
}

class WeakPasswordFailure extends AuthFailure {
  const WeakPasswordFailure() : super('Password terlalu lemah');
}

class InvalidEmailFailure extends AuthFailure {
  const InvalidEmailFailure() : super('Format email tidak valid');
}

class SessionExpiredFailure extends AuthFailure {
  const SessionExpiredFailure() : super('Sesi telah berakhir, silakan login kembali');
}

class ServerFailure extends AuthFailure {
  const ServerFailure([String message = 'Terjadi kesalahan server']) : super(message);
}

class NetworkFailure extends AuthFailure {
  const NetworkFailure() : super('Koneksi internet bermasalah');
}

class UnknownAuthFailure extends AuthFailure {
  const UnknownAuthFailure([String message = 'Terjadi kesalahan']) : super(message);
}

/// Interface for authentication repository
abstract class AuthRepository {
  /// Sign in with email and password
  /// Returns the user if successful, or an AuthFailure
  Future<Either<AuthFailure, Pengguna>> login({
    required String email,
    required String password,
  });

  /// Register a new user
  /// Returns the newly created user if successful, or an AuthFailure
  Future<Either<AuthFailure, Pengguna>> register({
    required String nama,
    required String email,
    required String password,
  });

  /// Sign out the current user
  Future<Either<AuthFailure, void>> logout();

  /// Get the currently logged in user
  /// Returns null if no user is logged in
  Future<Pengguna?> getCurrentUser();

  /// Check if a user is currently logged in
  Future<bool> isLoggedIn();

  /// Refresh the current session/token
  Future<Either<AuthFailure, void>> refreshSession();

  /// Listen to auth state changes
  Stream<Pengguna?> get authStateChanges;
}
