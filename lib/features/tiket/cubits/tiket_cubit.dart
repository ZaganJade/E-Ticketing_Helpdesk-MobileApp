import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/tiket_model.dart';
import '../repositories/tiket_repository.dart';

// States
abstract class TiketState {}

class TiketInitial extends TiketState {}

class TiketLoading extends TiketState {}

class TiketListLoaded extends TiketState {
  final List<TiketModel> tiketList;
  final String currentFilter;
  final bool hasMore;
  final bool isLoadingMore;

  TiketListLoaded({
    required this.tiketList,
    this.currentFilter = 'semua',
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  TiketListLoaded copyWith({
    List<TiketModel>? tiketList,
    String? currentFilter,
    bool? hasMore,
    bool? isLoadingMore,
  }) {
    return TiketListLoaded(
      tiketList: tiketList ?? this.tiketList,
      currentFilter: currentFilter ?? this.currentFilter,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

class TiketDetailLoaded extends TiketState {
  final TiketModel tiket;

  TiketDetailLoaded({required this.tiket});
}

class CreateTiketSuccess extends TiketState {
  final TiketModel tiket;

  CreateTiketSuccess({required this.tiket});
}

class TiketError extends TiketState {
  final String message;

  TiketError({required this.message});
}

// Cubit
class TiketCubit extends Cubit<TiketState> {
  final TiketRepository _repository;

  TiketCubit({required TiketRepository tiketRepository})
      : _repository = tiketRepository,
        super(TiketInitial());

  // Load tiket list
  Future<void> loadTiketList({
    String? filter,
    String? search,
    bool refresh = false,
  }) async {
    if (!refresh && state is TiketListLoaded) {
      return;
    }

    emit(TiketLoading());

    try {
      final tiketList = await _repository.getTiketList(
        status: filter,
        search: search,
        limit: 20,
        offset: 0,
      );

      emit(TiketListLoaded(
        tiketList: tiketList,
        currentFilter: filter ?? 'semua',
        hasMore: tiketList.length == 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(TiketError(message: e.toString()));
    }
  }

  // Load more (pagination)
  Future<void> loadMoreTiket({String? search}) async {
    if (state is! TiketListLoaded) return;

    final currentState = state as TiketListLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final moreTiket = await _repository.getTiketList(
        status: currentState.currentFilter == 'semua'
            ? null
            : currentState.currentFilter,
        search: search,
        limit: 20,
        offset: currentState.tiketList.length,
      );

      emit(TiketListLoaded(
        tiketList: [...currentState.tiketList, ...moreTiket],
        currentFilter: currentState.currentFilter,
        hasMore: moreTiket.length == 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  // Change filter
  Future<void> changeFilter(String filter, {String? search}) async {
    emit(TiketLoading());

    try {
      final tiketList = await _repository.getTiketList(
        status: filter == 'semua' ? null : filter,
        search: search,
        limit: 20,
        offset: 0,
      );

      emit(TiketListLoaded(
        tiketList: tiketList,
        currentFilter: filter,
        hasMore: tiketList.length == 20,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(TiketError(message: e.toString()));
    }
  }

  // Get tiket detail
  Future<void> getTiketDetail(String tiketId) async {
    emit(TiketLoading());

    try {
      final tiket = await _repository.getTiketDetail(tiketId);
      emit(TiketDetailLoaded(tiket: tiket));
    } catch (e) {
      emit(TiketError(message: e.toString()));
    }
  }

  // Create new tiket
  Future<void> createTiket({
    required String judul,
    required String deskripsi,
  }) async {
    emit(TiketLoading());

    try {
      final tiket = await _repository.createTiket(
        judul: judul,
        deskripsi: deskripsi,
      );
      emit(CreateTiketSuccess(tiket: tiket));
    } catch (e) {
      emit(TiketError(message: e.toString()));
    }
  }

  // Update tiket status
  Future<void> updateTiketStatus(String tiketId, String status) async {
    try {
      final tiket = await _repository.updateTiketStatus(tiketId, status);

      if (state is TiketDetailLoaded) {
        emit(TiketDetailLoaded(tiket: tiket));
      } else if (state is TiketListLoaded) {
        final currentState = state as TiketListLoaded;
        final updatedList = currentState.tiketList.map((t) {
          return t.id == tiketId ? tiket : t;
        }).toList();
        emit(currentState.copyWith(tiketList: updatedList));
      }
    } catch (e) {
      emit(TiketError(message: e.toString()));
    }
  }

  // Assign tiket
  Future<void> assignTiket(String tiketId, String? helpdeskId) async {
    try {
      final tiket = await _repository.assignTiket(tiketId, helpdeskId);

      if (state is TiketDetailLoaded) {
        emit(TiketDetailLoaded(tiket: tiket));
      }
    } catch (e) {
      emit(TiketError(message: e.toString()));
    }
  }

  // Refresh current state
  Future<void> refresh({String? search}) async {
    if (state is TiketListLoaded) {
      final currentState = state as TiketListLoaded;
      await loadTiketList(
        filter: currentState.currentFilter,
        search: search,
        refresh: true,
      );
    } else if (state is TiketDetailLoaded) {
      final currentState = state as TiketDetailLoaded;
      await getTiketDetail(currentState.tiket.id);
    }
  }
}
