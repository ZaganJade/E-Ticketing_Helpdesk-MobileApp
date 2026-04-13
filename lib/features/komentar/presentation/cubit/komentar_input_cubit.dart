import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';

part 'komentar_input_state.dart';

/// Cubit for managing komentar input state
class KomentarInputCubit extends Cubit<KomentarInputState> {
  final KomentarRepository _komentarRepository;

  KomentarInputCubit({
    required KomentarRepository komentarRepository,
  })  : _komentarRepository = komentarRepository,
        super(const KomentarInputState());

  /// Update message text
  void messageChanged(String message) {
    final isValid = message.trim().isNotEmpty;
    emit(state.copyWith(
      message: message,
      isValid: isValid,
      status: KomentarInputStatus.initial,
      errorMessage: null,
    ));
  }

  /// Clear message
  void clearMessage() {
    emit(const KomentarInputState());
  }

  /// Submit komentar
  Future<Komentar?> submit(String tiketId) async {
    if (!state.isValid) {
      emit(state.copyWith(
        status: KomentarInputStatus.error,
        errorMessage: 'Pesan tidak boleh kosong',
      ));
      return null;
    }

    // Emit optimistic state
    emit(state.copyWith(
      status: KomentarInputStatus.submitting,
      isSubmitting: true,
    ));

    final result = await _komentarRepository.addKomentar(
      tiketId: tiketId,
      isiPesan: state.message.trim(),
    );

    return result.fold(
      (failure) {
        emit(state.copyWith(
          status: KomentarInputStatus.error,
          isSubmitting: false,
          errorMessage: failure.message,
        ));
        return null;
      },
      (komentar) {
        emit(const KomentarInputState(
          status: KomentarInputStatus.success,
        ));
        return komentar;
      },
    );
  }

  /// Submit with optimistic update callback
  Future<void> submitWithCallback({
    required String tiketId,
    required Function(Komentar) onOptimistic,
    required Function(Komentar) onConfirmed,
    required Function(String) onError,
  }) async {
    if (!state.isValid) {
      onError('Pesan tidak boleh kosong');
      return;
    }

    // Create optimistic komentar
    final optimisticKomentar = _createOptimisticKomentar(tiketId);

    // Emit optimistic state
    emit(state.copyWith(
      status: KomentarInputStatus.submitting,
      isSubmitting: true,
    ));

    // Call optimistic callback immediately
    onOptimistic(optimisticKomentar);

    final result = await _komentarRepository.addKomentar(
      tiketId: tiketId,
      isiPesan: state.message.trim(),
    );

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: KomentarInputStatus.error,
          isSubmitting: false,
          errorMessage: failure.message,
        ));
        onError(failure.message);
      },
      (komentar) {
        emit(const KomentarInputState(
          status: KomentarInputStatus.success,
        ));
        onConfirmed(komentar);
      },
    );
  }

  /// Create optimistic komentar for immediate display
  Komentar _createOptimisticKomentar(String tiketId) {
    // This will be replaced when actual data comes back
    return Komentar(
      id: 'pending_${DateTime.now().millisecondsSinceEpoch}',
      tiketId: tiketId,
      penulisId: 'current_user',
      namaPenulis: 'Anda',
      peranPenulis: Peran.pengguna,
      isiPesan: state.message.trim(),
      dibuatPada: DateTime.now(),
    );
  }
}
