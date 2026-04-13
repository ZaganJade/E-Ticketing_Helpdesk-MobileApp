import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/pengguna.dart';
import '../../domain/repositories/auth_repository.dart';

part 'register_state.dart';

/// Cubit for managing registration form state
class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepository _authRepository;

  RegisterCubit({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(const RegisterState());

  /// Update nama field
  void namaChanged(String nama) {
    final isValid = nama.trim().length >= 2;
    emit(state.copyWith(
      nama: nama,
      isNamaValid: isValid,
      errorMessage: null,
      status: RegisterStatus.initial,
    ));
  }

  /// Update email field
  void emailChanged(String email) {
    final isValid = _isValidEmail(email);
    emit(state.copyWith(
      email: email,
      isEmailValid: isValid,
      errorMessage: null,
      status: RegisterStatus.initial,
    ));
  }

  /// Update password field
  void passwordChanged(String password) {
    final isValid = password.length >= 8;
    final strength = _calculatePasswordStrength(password);
    emit(state.copyWith(
      password: password,
      isPasswordValid: isValid,
      passwordStrength: strength,
      errorMessage: null,
      status: RegisterStatus.initial,
    ));
  }

  /// Update confirm password field
  void confirmPasswordChanged(String confirmPassword) {
    final isMatch = confirmPassword == state.password;
    emit(state.copyWith(
      confirmPassword: confirmPassword,
      isConfirmPasswordMatch: isMatch,
      errorMessage: null,
      status: RegisterStatus.initial,
    ));
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  /// Toggle confirm password visibility
  void toggleConfirmPasswordVisibility() {
    emit(state.copyWith(obscureConfirmPassword: !state.obscureConfirmPassword));
  }

  /// Attempt registration
  Future<void> register() async {
    if (!state.isFormValid) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Mohon isi semua field dengan benar',
      ));
      return;
    }

    if (!state.isConfirmPasswordMatch) {
      emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: 'Konfirmasi password tidak cocok',
      ));
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    final result = await _authRepository.register(
      nama: state.nama.trim(),
      email: state.email.trim(),
      password: state.password,
    );

    result.fold(
      (failure) => emit(state.copyWith(
        status: RegisterStatus.error,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: RegisterStatus.success,
        user: user,
      )),
    );
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  /// Calculate password strength (0-1)
  double _calculatePasswordStrength(String password) {
    if (password.isEmpty) return 0;

    double strength = 0;

    // Length contribution (up to 0.4)
    if (password.length >= 8) strength += 0.2;
    if (password.length >= 12) strength += 0.2;

    // Character variety contribution (up to 0.6)
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[a-z]'))) strength += 0.15;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.15;
    if (password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) strength += 0.15;

    return strength.clamp(0.0, 1.0);
  }
}
