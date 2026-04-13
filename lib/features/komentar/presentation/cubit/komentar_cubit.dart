import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';

part 'komentar_state.dart';

/// Cubit for managing komentar list state and realtime updates
class KomentarCubit extends Cubit<KomentarState> {
  final KomentarRepository _komentarRepository;
  final Logger _logger;

  StreamSubscription<List<Komentar>>? _komentarSubscription;
  String? _currentTiketId;

  KomentarCubit({
    required KomentarRepository komentarRepository,
    Logger? logger,
  })  : _komentarRepository = komentarRepository,
        _logger = logger ?? Logger(),
        super(const KomentarInitial());

  /// Load komentar for a specific tiket
  Future<void> loadKomentar(String tiketId) async {
    _currentTiketId = tiketId;
    emit(const KomentarLoading());

    final result = await _komentarRepository.getKomentarByTiketId(tiketId);

    result.fold(
      (failure) => emit(KomentarError(failure.message)),
      (komentarList) => emit(KomentarLoaded(
        komentarList: komentarList,
        hasNewKomentar: false,
      )),
    );
  }

  /// Subscribe to realtime updates via polling (Backend API doesn't have realtime)
  void subscribeToRealtimeUpdates(String tiketId) {
    _logger.i('Setting up polling subscription for tiket: $tiketId');

    // Clean up existing subscription
    _unsubscribeFromRealtimeUpdates();

    // Subscribe to repository's polling stream
    _komentarSubscription = _komentarRepository
        .subscribeToKomentarUpdates(tiketId)
        .listen(
          (komentarList) {
            _logger.i('Received ${komentarList.length} komentar via polling');
            _handleUpdatedKomentarList(komentarList);
          },
          onError: (error) {
            _logger.e('Error in komentar subscription: $error');
          },
        );
  }

  /// Handle updated komentar list from polling
  void _handleUpdatedKomentarList(List<Komentar> komentarList) {
    final currentState = state;
    if (currentState is! KomentarLoaded) {
      // Initial load
      emit(KomentarLoaded(
        komentarList: komentarList,
        hasNewKomentar: false,
      ));
      return;
    }

    // Check if there are new komentar
    final currentIds = currentState.komentarList.map((k) => k.id).toSet();
    final newKomentar = komentarList.where((k) => !currentIds.contains(k.id)).toList();

    if (newKomentar.isNotEmpty) {
      _logger.i('Found ${newKomentar.length} new komentar');
      emit(KomentarLoaded(
        komentarList: komentarList,
        hasNewKomentar: true,
        newKomentarId: newKomentar.last.id,
      ));
    } else {
      // No new komentar - don't emit to avoid unnecessary rebuilds
      _logger.d('No new komentar, skipping emit');
    }
  }

  /// Mark new komentar as seen
  void markNewKomentarAsSeen() {
    final currentState = state;
    if (currentState is KomentarLoaded && currentState.hasNewKomentar) {
      emit(currentState.copyWith(
        hasNewKomentar: false,
        newKomentarId: null,
      ));
    }
  }

  /// Refresh komentar list silently (without showing loading state)
  Future<void> refresh() async {
    if (_currentTiketId == null) return;

    final result = await _komentarRepository.getKomentarByTiketId(_currentTiketId!);

    result.fold(
      (failure) => emit(KomentarError(failure.message)),
      (komentarList) {
        final currentState = state;
        if (currentState is KomentarLoaded) {
          // Silent update - merge with existing to avoid duplicates
          final existingIds = currentState.komentarList.map((k) => k.id).toSet();
          final mergedList = [
            ...currentState.komentarList,
            ...komentarList.where((k) => !existingIds.contains(k.id)),
          ];
          // Sort by creation time
          mergedList.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));

          if (mergedList.length > currentState.komentarList.length) {
            emit(KomentarLoaded(
              komentarList: mergedList,
              hasNewKomentar: true,
              newKomentarId: mergedList.last.id,
            ));
          }
        } else {
          emit(KomentarLoaded(
            komentarList: komentarList,
            hasNewKomentar: false,
          ));
        }
      },
    );
  }

  /// Add a new komentar
  Future<void> addKomentar({
    required String tiketId,
    required String isiPesan,
  }) async {
    final currentState = state;

    final result = await _komentarRepository.addKomentar(
      tiketId: tiketId,
      isiPesan: isiPesan,
    );

    result.fold(
      (failure) => emit(KomentarError(failure.message)),
      (komentar) async {
        // Refresh the list to include the new komentar
        await refresh();
      },
    );
  }

  /// Delete a komentar
  Future<void> deleteKomentar(String komentarId) async {
    final result = await _komentarRepository.deleteKomentar(komentarId);

    result.fold(
      (failure) => emit(KomentarError(failure.message)),
      (_) {
        // Remove from current list
        final currentState = state;
        if (currentState is KomentarLoaded) {
          final updatedList = currentState.komentarList
              .where((k) => k.id != komentarId)
              .toList();
          emit(currentState.copyWith(komentarList: updatedList));
        }
      },
    );
  }

  /// Unsubscribe from realtime updates
  void _unsubscribeFromRealtimeUpdates() {
    _komentarSubscription?.cancel();
    _komentarSubscription = null;
    _logger.i('Unsubscribed from komentar updates');
  }

  @override
  Future<void> close() {
    _unsubscribeFromRealtimeUpdates();
    _komentarRepository.unsubscribeFromKomentarUpdates();
    return super.close();
  }
}
