import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/domain/repositories/auth_repository.dart';

part 'komentar_state.dart';

/// Cubit for managing komentar list state and realtime updates
class KomentarCubit extends Cubit<KomentarState> {
  final KomentarRepository _komentarRepository;
  final AuthRepository _authRepository;
  final Logger _logger;

  StreamSubscription<List<Komentar>>? _komentarSubscription;
  String? _currentTiketId;

  KomentarCubit({
    required KomentarRepository komentarRepository,
    required AuthRepository authRepository,
    Logger? logger,
  })  : _komentarRepository = komentarRepository,
        _authRepository = authRepository,
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
    _logger.d('Polling received ${komentarList.length} komentar, current state: ${currentState.runtimeType}');

    if (currentState is! KomentarLoaded) {
      // Initial load
      _logger.i('Initial load from polling: ${komentarList.length} komentar');
      emit(KomentarLoaded(
        komentarList: komentarList,
        hasNewKomentar: false,
      ));
      return;
    }

    // Check if there are new komentar from server
    final currentIds = currentState.komentarList.map((k) => k.id).toSet();
    final newKomentar = komentarList.where((k) => !currentIds.contains(k.id)).toList();

    // Check for optimistic komentars that need to be preserved
    final optimisticKomentars = currentState.komentarList
        .where((k) => k.id.startsWith('temp_'))
        .toList();
    _logger.d('Current has ${optimisticKomentars.length} optimistic komentar');

    if (newKomentar.isNotEmpty || optimisticKomentars.isNotEmpty) {
      _logger.i('Polling: ${newKomentar.length} new from server, ${optimisticKomentars.length} optimistic kept');

      // Fix 'Unknown' names from server by checking if we already have that komentar with a better name
      final fixedServerList = komentarList.map((k) {
        if (k.namaPenulis == 'Unknown' || k.namaPenulis.isEmpty) {
          // Check if we already have this komentar with a valid name in current state
          final existing = currentState.komentarList.firstWhere(
            (existing) => existing.id == k.id && existing.namaPenulis != 'Unknown' && existing.namaPenulis.isNotEmpty,
            orElse: () => k,
          );
          if (existing != k) {
            _logger.d('Fixed namaPenulis for komentar ${k.id}: ${k.namaPenulis} -> ${existing.namaPenulis}');
            return existing;
          }
        }
        return k;
      }).toList();

      // Merge server list with optimistic komentars
      final mergedList = [...fixedServerList, ...optimisticKomentars];
      // Sort by creation time
      mergedList.sort((a, b) => a.dibuatPada.compareTo(b.dibuatPada));

      emit(KomentarLoaded(
        komentarList: mergedList,
        hasNewKomentar: newKomentar.isNotEmpty,
        newKomentarId: newKomentar.isNotEmpty ? newKomentar.last.id : null,
      ));
    } else {
      // No changes - don't emit to avoid unnecessary rebuilds
      _logger.d('No changes from polling, skipping emit');
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

  /// Add a new komentar with optimistic update for instant UI feedback
  Future<void> addKomentar({
    required String tiketId,
    required String isiPesan,
  }) async {
    final currentState = state;
    _logger.i('Adding komentar - initial state: ${currentState.runtimeType}');

    // Get current user info from database via AuthRepository
    final currentUser = await _authRepository.getCurrentUser();
    final userName = currentUser?.nama ?? 'Unknown';
    final userId = currentUser?.id ?? Supabase.instance.client.auth.currentUser?.id ?? 'current_user';

    _logger.i('Current user from DB: $userId, name: $userName');

    // Optimistic update - add placeholder immediately
    final optimisticKomentar = Komentar(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      tiketId: tiketId,
      isiPesan: isiPesan,
      penulisId: userId,
      namaPenulis: userName,
      peranPenulis: Peran.pengguna, // Will be determined by backend
      dibuatPada: DateTime.now(),
    );

    final existingList = currentState is KomentarLoaded ? currentState.komentarList : <Komentar>[];
    _logger.i('Emitting optimistic komentar: ${optimisticKomentar.id} (existing: ${existingList.length})');

    // Emit immediately with new komentar
    emit(KomentarLoaded(
      komentarList: [...existingList, optimisticKomentar],
      hasNewKomentar: true,
      newKomentarId: optimisticKomentar.id,
    ));

    _logger.i('Calling repository.addKomentar...');
    final result = await _komentarRepository.addKomentar(
      tiketId: tiketId,
      isiPesan: isiPesan,
    );
    _logger.i('Repository.addKomentar returned: ${result.isRight() ? 'success' : 'failure'}');

    result.fold(
      (failure) {
        _logger.e('Failed to add komentar: ${failure.message}');
        // Revert on failure - remove optimistic komentar but stay on Loaded state
        final latestState = state;
        if (latestState is KomentarLoaded) {
          final hasOptimistic = latestState.komentarList.any((k) => k.id.startsWith('temp_'));
          if (hasOptimistic) {
            final revertedList = latestState.komentarList
                .where((k) => !k.id.startsWith('temp_'))
                .toList();
            _logger.i('Reverting to ${revertedList.length} komentar (removed optimistic)');
            emit(KomentarLoaded(
              komentarList: revertedList,
              hasNewKomentar: false,
            ));
          }
        }
        // Don't emit error state - just log the error
      },
      (komentar) {
        _logger.i('Success - Server returned komentar: id=${komentar.id}, namaPenulis=${komentar.namaPenulis}');

        // If server returns 'Unknown' or empty, use the optimistic name we already showed
        final effectiveKomentar = (komentar.namaPenulis == 'Unknown' || komentar.namaPenulis.isEmpty)
            ? komentar.copyWith(namaPenulis: userName)
            : komentar;

        // Replace optimistic komentar with real one
        final latestState = state;
        if (latestState is KomentarLoaded) {
          final updatedList = latestState.komentarList
              .where((k) => !k.id.startsWith('temp_'))
              .toList()
            ..add(effectiveKomentar);

          emit(KomentarLoaded(
            komentarList: updatedList,
            hasNewKomentar: true,
            newKomentarId: effectiveKomentar.id,
          ));
        }
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
