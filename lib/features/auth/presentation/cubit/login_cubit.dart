import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pengguna.dart';
import '../../domain/repositories/auth_repository.dart';

part 'login_state.dart';

/// Cubit for managing login form state
class LoginCubit extends Cubit<LoginState> {
  final AuthRepository _authRepository;

  LoginCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const LoginState());

  /// Update email field
  void emailChanged(String email) {
    final isValid = _isValidEmail(email);
    emit(state.copyWith(
      email: email,
      isEmailValid: isValid,
      errorMessage: null,
      status: LoginStatus.initial,
    ));
  }

  /// Update password field
  void passwordChanged(String password) {
    final isValid = password.length >= 8;
    emit(state.copyWith(
      password: password,
      isPasswordValid: isValid,
      errorMessage: null,
      status: LoginStatus.initial,
    ));
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  /// Attempt login
  Future<void> login() async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: 'Mohon isi email dan password dengan benar',
      ));
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    final result = await _authRepository.login(
      email: state.email,
      password: state.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: LoginStatus.error,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: LoginStatus.success,
        user: user,
      )),
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }
}
