import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/pengguna.dart';
import '../../domain/repositories/auth_repository.dart';

part 'auth_state.dart';

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  final Logger _logger;

  AuthCubit({required AuthRepository authRepository, Logger? logger})
      : _authRepository = authRepository,
        _logger = logger ?? Logger(),
        super(const AuthInitial()) {
    // Start listening to auth changes
    startListeningToAuthChanges();
  }

  /// Check if user is already logged in (for splash screen)
  Future<void> checkAuthStatus() async {
    _logger.i('[AuthCubit] checkAuthStatus called, emitting AuthLoading');
    emit(const AuthLoading());

    final isLoggedIn = await _authRepository.isLoggedIn();
    _logger.i('[AuthCubit] isLoggedIn: $isLoggedIn');

    if (isLoggedIn) {
      final user = await _authRepository.getCurrentUser();
      _logger.i('[AuthCubit] getCurrentUser returned: ${user?.id}');
      if (user != null) {
        _logger.i('[AuthCubit] Emitting Authenticated from checkAuthStatus');
        emit(Authenticated(user));
      } else {
        _logger.i('[AuthCubit] Emitting Unauthenticated (user is null)');
        emit(const Unauthenticated());
      }
    } else {
      _logger.i('[AuthCubit] Emitting Unauthenticated (not logged in)');
      emit(const Unauthenticated());
    }
  }

  /// Sign out the current user
  Future<void> logout() async {
    emit(const AuthLoading());

    final result = await _authRepository.logout();

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) {
        // Always emit Unauthenticated after successful logout
        emit(const Unauthenticated());
      },
    );
  }

  /// Refresh the current session
  Future<void> refreshSession() async {
    final result = await _authRepository.refreshSession();

    result.fold(
      (failure) {
        // If refresh fails, user needs to login again
        emit(const Unauthenticated());
      },
      (_) async {
        // Session refreshed, get current user
        final user = await _authRepository.getCurrentUser();
        if (user != null) {
          emit(Authenticated(user));
        }
      },
    );
  }

  /// Update user data in state (e.g., after profile update)
  void updateUser(Pengguna user) {
    _logger.i('[AuthCubit] updateUser called with user: ${user.id}, emitting Authenticated');
    emit(Authenticated(user));
  }

  /// Listen to auth state changes from repository (polling-based for JWT)
  void startListeningToAuthChanges() {
    _authRepository.authStateChanges.listen((user) {
      final currentState = state;
      _logger.i('[AuthCubit] authStateChanges received user: ${user?.id}, currentState: $currentState');

      if (user != null) {
        // User is authenticated - update state
        _logger.i('[AuthCubit] Emitting Authenticated from stream');
        emit(Authenticated(user));
      } else {
        // User is null (logged out or not logged in)
        if (currentState is Authenticated || currentState is AuthInitial) {
          // Only emit Unauthenticated if we were previously authenticated
          // or if we're in initial state and found no user
          _logger.i('[AuthCubit] Emitting Unauthenticated from stream');
          emit(const Unauthenticated());
        } else {
          _logger.i('[AuthCubit] Not emitting - already Unauthenticated or AuthLoading');
        }
      }
    });
  }
}
