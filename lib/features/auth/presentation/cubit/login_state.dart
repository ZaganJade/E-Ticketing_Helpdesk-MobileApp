part of 'login_cubit.dart';

/// Status of login operation
enum LoginStatus {
  initial,
  loading,
  success,
  error,
}

/// State for login form
class LoginState extends Equatable {
  final String email;
  final String password;
  final bool isEmailValid;
  final bool isPasswordValid;
  final bool obscurePassword;
  final LoginStatus status;
  final String? errorMessage;
  final Pengguna? user;

  const LoginState({
    this.email = '',
    this.password = '',
    this.isEmailValid = false,
    this.isPasswordValid = false,
    this.obscurePassword = true,
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  /// Check if form is valid
  bool get isFormValid => isEmailValid && isPasswordValid;

  /// Check if currently loading
  bool get isLoading => status == LoginStatus.loading;

  /// Check if login was successful
  bool get isSuccess => status == LoginStatus.success;

  /// Check if there's an error
  bool get isError => status == LoginStatus.error;

  LoginState copyWith({
    String? email,
    String? password,
    bool? isEmailValid,
    bool? isPasswordValid,
    bool? obscurePassword,
    LoginStatus? status,
    String? errorMessage,
    Pengguna? user,
  }) {
    return LoginState(
      email: email ?? this.email,
      password: password ?? this.password,
      isEmailValid: isEmailValid ?? this.isEmailValid,
      isPasswordValid: isPasswordValid ?? this.isPasswordValid,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      status: status ?? this.status,
      errorMessage: errorMessage,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [
        email,
        password,
        isEmailValid,
        isPasswordValid,
        obscurePassword,
        status,
        errorMessage,
        user,
      ];
}
