import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/notifikasi_model.dart';
import '../repositories/notifikasi_repository.dart';

// States
abstract class NotifikasiState {}

class NotifikasiInitial extends NotifikasiState {}

class NotifikasiLoading extends NotifikasiState {}

class NotifikasiRefreshing extends NotifikasiState {
  final List<NotifikasiModel> currentList;
  final bool showUnreadOnly;

  NotifikasiRefreshing({
    required this.currentList,
    this.showUnreadOnly = false,
  });
}

class NotifikasiListLoaded extends NotifikasiState {
  final List<NotifikasiModel> notifikasiList;
  final bool showUnreadOnly;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasNewData;

  NotifikasiListLoaded({
    required this.notifikasiList,
    this.showUnreadOnly = false,
    this.hasMore = true,
    this.isLoadingMore = false,
    this.hasNewData = false,
  });

  NotifikasiListLoaded copyWith({
    List<NotifikasiModel>? notifikasiList,
    bool? showUnreadOnly,
    bool? hasMore,
    bool? isLoadingMore,
    bool? hasNewData,
  }) {
    return NotifikasiListLoaded(
      notifikasiList: notifikasiList ?? this.notifikasiList,
      showUnreadOnly: showUnreadOnly ?? this.showUnreadOnly,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasNewData: hasNewData ?? this.hasNewData,
    );
  }

  int get unreadCount => notifikasiList.where((n) => !n.sudahDibaca).length;
}

class NotifikasiCountLoaded extends NotifikasiState {
  final int count;

  NotifikasiCountLoaded({required this.count});
}

class NotifikasiError extends NotifikasiState {
  final String message;

  NotifikasiError({required this.message});
}

// Cubit
class NotifikasiCubit extends Cubit<NotifikasiState> {
  final NotifikasiRepository _repository = NotifikasiRepository();
  StreamSubscription? _realtimeSubscription;
  Timer? _refreshDebounceTimer;

  NotifikasiCubit() : super(NotifikasiInitial());

  // Load notifikasi list
  Future<void> loadNotifikasi({
    bool onlyUnread = false,
    bool refresh = false,
  }) async {
    if (!refresh && state is NotifikasiListLoaded) {
      return;
    }

    emit(NotifikasiLoading());

    try {
      final notifikasiList = await _repository.getNotifikasiList(
        onlyUnread: onlyUnread,
        limit: 20,
        offset: 0,
      );

      emit(NotifikasiListLoaded(
        notifikasiList: notifikasiList,
        showUnreadOnly: onlyUnread,
        hasMore: notifikasiList.length == 20,
        isLoadingMore: false,
        hasNewData: false,
      ));
    } catch (e) {
      emit(NotifikasiError(message: e.toString()));
    }
  }

  // Load more (pagination)
  Future<void> loadMore() async {
    if (state is! NotifikasiListLoaded) return;

    final currentState = state as NotifikasiListLoaded;
    if (currentState.isLoadingMore || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final moreNotifikasi = await _repository.getNotifikasiList(
        onlyUnread: currentState.showUnreadOnly,
        limit: 20,
        offset: currentState.notifikasiList.length,
      );

      emit(NotifikasiListLoaded(
        notifikasiList: [...currentState.notifikasiList, ...moreNotifikasi],
        showUnreadOnly: currentState.showUnreadOnly,
        hasMore: moreNotifikasi.length == 20,
        isLoadingMore: false,
        hasNewData: false,
      ));
    } catch (e) {
      emit(currentState.copyWith(isLoadingMore: false));
    }
  }

  // Toggle filter
  Future<void> toggleFilter(bool showUnreadOnly) async {
    emit(NotifikasiLoading());

    try {
      final notifikasiList = await _repository.getNotifikasiList(
        onlyUnread: showUnreadOnly,
        limit: 20,
        offset: 0,
      );

      emit(NotifikasiListLoaded(
        notifikasiList: notifikasiList,
        showUnreadOnly: showUnreadOnly,
        hasMore: notifikasiList.length == 20,
        isLoadingMore: false,
        hasNewData: false,
      ));
    } catch (e) {
      emit(NotifikasiError(message: e.toString()));
    }
  }

  // Get unread count
  Future<void> getUnreadCount() async {
    try {
      final count = await _repository.getUnreadCount();
      emit(NotifikasiCountLoaded(count: count));
    } catch (e) {
      // Silently fail for count
    }
  }

  // Mark as read
  Future<void> markAsRead(String notifikasiId) async {
    try {
      await _repository.markAsRead(notifikasiId);

      if (state is NotifikasiListLoaded) {
        final currentState = state as NotifikasiListLoaded;
        final updatedList = currentState.notifikasiList.map((n) {
          if (n.id == notifikasiId) {
            return n.copyWith(sudahDibaca: true);
          }
          return n;
        }).toList();
        emit(currentState.copyWith(notifikasiList: updatedList));
      }

      // Refresh count
      getUnreadCount();
    } catch (e) {
      emit(NotifikasiError(message: e.toString()));
    }
  }

  // Mark all as read
  Future<void> markAllAsRead() async {
    try {
      await _repository.markAllAsRead();

      if (state is NotifikasiListLoaded) {
        final currentState = state as NotifikasiListLoaded;
        final updatedList = currentState.notifikasiList
            .map((n) => n.copyWith(sudahDibaca: true))
            .toList();
        emit(currentState.copyWith(notifikasiList: updatedList));
      }

      // Refresh count
      getUnreadCount();
    } catch (e) {
      emit(NotifikasiError(message: e.toString()));
    }
  }

  // Delete notifikasi
  Future<void> deleteNotifikasi(String notifikasiId) async {
    try {
      await _repository.deleteNotifikasi(notifikasiId);

      if (state is NotifikasiListLoaded) {
        final currentState = state as NotifikasiListLoaded;
        final updatedList = currentState.notifikasiList
            .where((n) => n.id != notifikasiId)
            .toList();
        emit(currentState.copyWith(notifikasiList: updatedList));
      }
    } catch (e) {
      emit(NotifikasiError(message: e.toString()));
    }
  }

  // Refresh with animation
  Future<void> refreshWithAnimation() async {
    if (state is NotifikasiListLoaded) {
      final currentState = state as NotifikasiListLoaded;
      // Show refreshing animation while keeping current data
      emit(NotifikasiRefreshing(
        currentList: currentState.notifikasiList,
        showUnreadOnly: currentState.showUnreadOnly,
      ));

      try {
        final notifikasiList = await _repository.getNotifikasiList(
          onlyUnread: currentState.showUnreadOnly,
          limit: 20,
          offset: 0,
        );

        emit(NotifikasiListLoaded(
          notifikasiList: notifikasiList,
          showUnreadOnly: currentState.showUnreadOnly,
          hasMore: notifikasiList.length == 20,
          isLoadingMore: false,
          hasNewData: true,
        ));
      } catch (e) {
        // On error, return to previous state
        emit(currentState);
      }
    } else {
      await loadNotifikasi();
    }
  }

  // Refresh (simple version)
  Future<void> refresh() async {
    if (state is NotifikasiListLoaded) {
      final currentState = state as NotifikasiListLoaded;
      await loadNotifikasi(
        onlyUnread: currentState.showUnreadOnly,
        refresh: true,
      );
    } else {
      await loadNotifikasi();
    }
  }

  // Subscribe to realtime updates with debounce
  void subscribeToRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository.subscribeToNotifikasi().listen((event) {
      // Debounce rapid updates
      _refreshDebounceTimer?.cancel();
      _refreshDebounceTimer = Timer(const Duration(milliseconds: 500), () {
        refreshWithAnimation();
        getUnreadCount();
      });
    });
  }

  // Unsubscribe from realtime updates
  void unsubscribeFromRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    _refreshDebounceTimer?.cancel();
  }

  @override
  Future<void> close() {
    _realtimeSubscription?.cancel();
    _refreshDebounceTimer?.cancel();
    return super.close();
  }
}
