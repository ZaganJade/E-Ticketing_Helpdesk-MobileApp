part of 'komentar_input_cubit.dart';

/// Status of komentar input
enum KomentarInputStatus {
  initial,
  submitting,
  success,
  error,
}

/// State for komentar input
class KomentarInputState extends Equatable {
  final String message;
  final bool isValid;
  final bool isSubmitting;
  final KomentarInputStatus status;
  final String? errorMessage;

  const KomentarInputState({
    this.message = '',
    this.isValid = false,
    this.isSubmitting = false,
    this.status = KomentarInputStatus.initial,
    this.errorMessage,
  });

  /// Get max lines based on content
  int get maxLines {
    final lineCount = '\n'.allMatches(message).length + 1;
    return lineCount.clamp(1, 5);
  }

  /// Check if message is empty
  bool get isEmpty => message.isEmpty;

  KomentarInputState copyWith({
    String? message,
    bool? isValid,
    bool? isSubmitting,
    KomentarInputStatus? status,
    String? errorMessage,
  }) {
    return KomentarInputState(
      message: message ?? this.message,
      isValid: isValid ?? this.isValid,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        message,
        isValid,
        isSubmitting,
        status,
        errorMessage,
      ];
}
