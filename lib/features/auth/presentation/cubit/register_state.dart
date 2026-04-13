part of 'register_cubit.dart';

/// Status of registration operation
enum RegisterStatus {
  initial,
  loading,
  success,
  error,
}

/// State for registration form
class RegisterState extends Equatable {
  final String nama;
  final String email;
  final String password;
  final String confirmPassword;
  final bool isNamaValid;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool isConfirmPasswordMatch;
  final double passwordStrength;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final RegisterStatus status;
  final String? errorMessage;
  final Pengguna? user;

  const RegisterState({
    this.nama = '',
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.isNamaValid = false,
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.isConfirmPasswordMatch = false,
    this.passwordStrength = 0,
    this.obscurePassword = true,
    this.obscureConfirmPassword = true,
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.user,
  });

  /// Check if form is valid
  bool get isFormValid =>
      isNamaValid && isEmailValid && isPasswordValid && isConfirmPasswordMatch;

  /// Check if currently loading
  bool get isLoading => status == RegisterStatus.loading;

  /// Check if registration was successful
  bool get isSuccess => status == RegisterStatus.success;

  /// Check if there's an error
  bool get isError => status == RegisterStatus.error;

  /// Get password strength label
  String get passwordStrengthLabel {
    if (passwordStrength < 0.3) return 'Lemah';
    if (passwordStrength < 0.6) return 'Sedang';
    if (passwordStrength < 0.9) return 'Kuat';
    return 'Sangat Kuat';
  }

  /// Get password strength color
  int get passwordStrengthColor {
    if (passwordStrength < 0.3) return 0xFFEF4444; // error
    if (passwordStrength < 0.6) return 0xFFF59E0B; // warning
    if (passwordStrength < 0.9) return 0xFF10B981; // success
    return 0xFF059669; // dark success
  }

  RegisterState copyWith({
    String? nama,
    String? email,
    String? password,
    String? confirmPassword,
    bool? isNamaValid,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? isConfirmPasswordMatch,
    double? passwordStrength,
    bool? obscurePassword,
    bool? obscureConfirmPassword,
    RegisterStatus? status,
    String? errorMessage,
    Pengguna? user,
  }) {
    return RegisterState(
      nama: nama ?? this.nama,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isNamaValid: isNamaValid ?? this.isNamaValid,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      isConfirmPasswordMatch: isConfirmPasswordMatch ?? this.isConfirmPasswordMatch,
      passwordStrength: passwordStrength ?? this.passwordStrength,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      obscureConfirmPassword: obscureConfirmPassword ?? this.obscureConfirmPassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        nama,
        email,
        password,
        confirmPassword,
        isNamaValid,
        isEmailValid,
        isPasswordValid,
        isConfirmPasswordMatch,
        passwordStrength,
        obscurePassword,
        obscureConfirmPassword,
        status,
        errorMessage,
        user,
      ];
}
