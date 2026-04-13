part of 'auth_cubit.dart';

/// Base class for all auth states
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any auth check
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state during auth operations
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// User is authenticated
class Authenticated extends AuthState {
  final Pengguna user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

/// User is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Error state with message
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}
