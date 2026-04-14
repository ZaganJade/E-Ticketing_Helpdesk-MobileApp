import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../models/notifikasi_model.dart';
import '../repositories/notifikasi_repository.dart';

// States
abstract class NotifikasiState extends Equatable {
  const NotifikasiState();

  @override
  List<Object?> get props => [];
}

class NotifikasiInitial extends NotifikasiState {
  const NotifikasiInitial();
}

class NotifikasiLoading extends NotifikasiState {
  const NotifikasiLoading();
}

class NotifikasiRefreshing extends NotifikasiState {
  final List<NotifikasiModel> currentList;
  final bool showUnreadOnly;

  const NotifikasiRefreshing({
    required this.currentList,
    this.showUnreadOnly = false,
  });

  @override
  List<Object?> get props => [currentList, showUnreadOnly];
}

class NotifikasiListLoaded extends NotifikasiState {
  final List<NotifikasiModel> notifikasiList;
  final bool showUnreadOnly;
  final bool hasMore;
  final bool isLoadingMore;
  final bool hasNewData;

  const NotifikasiListLoaded({
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

  @override
  List<Object?> get props => [
        notifikasiList,
        showUnreadOnly,
        hasMore,
        isLoadingMore,
        hasNewData,
      ];
}

class NotifikasiCountLoaded extends NotifikasiState {
  final int count;

  const NotifikasiCountLoaded({required this.count});

  @override
  List<Object?> get props => [count];
}

class NotifikasiError extends NotifikasiState {
  final String message;

  const NotifikasiError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit
class NotifikasiCubit extends Cubit<NotifikasiState> {
  final NotifikasiRepository _repository = NotifikasiRepository();
  final Logger _logger = Logger();
  StreamSubscription? _realtimeSubscription;
  Timer? _refreshDebounceTimer;

  NotifikasiCubit() : super(const NotifikasiInitial());

  // Load notifikasi list
  Future<void> loadNotifikasi({
    bool onlyUnread = false,
    bool refresh = false,
  }) async {
    if (!refresh && state is NotifikasiListLoaded) {
      return;
    }

    emit(const NotifikasiLoading());

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
    emit(const NotifikasiLoading());

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

  // Get unread count - updates state without replacing list
  Future<void> getUnreadCount() async {
    try {
      await _repository.getUnreadCount();
      // Only emit if state is already loaded, update the list in place
      if (state is NotifikasiListLoaded) {
        // No need to emit, just keep the count for reference
        // The unread count is computed from the list anyway
      }
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

  // Reset hasNewData flag after animation completes
  void resetHasNewData() {
    if (state is NotifikasiListLoaded) {
      final currentState = state as NotifikasiListLoaded;
      emit(currentState.copyWith(hasNewData: false));
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

  // Subscribe to realtime updates - only refresh when there are new notifications
  void subscribeToRealtimeUpdates() {
    _realtimeSubscription?.cancel();
    _realtimeSubscription = _repository.subscribeToNotifikasi().listen(
      (newNotifikasiList) {
        _logger.i('New notifications detected: ${newNotifikasiList.length} unread');

        // Debounce rapid updates
        _refreshDebounceTimer?.cancel();
        _refreshDebounceTimer = Timer(const Duration(milliseconds: 500), () {
          // Only refresh UI if there are actually new notifications
          if (newNotifikasiList.isNotEmpty) {
            _handleNewNotifikasi(newNotifikasiList);
          }
          getUnreadCount();
        });
      },
      onError: (error) {
        _logger.e('Error in notifikasi subscription: $error');
      },
    );
  }

  // Handle new notifications - merge with existing list
  void _handleNewNotifikasi(List<NotifikasiModel> newNotifikasiList) {
    final currentState = state;
    if (currentState is! NotifikasiListLoaded) {
      // If not loaded yet, do full refresh
      refreshWithAnimation();
      return;
    }

    // Get current IDs
    final currentIds = currentState.notifikasiList.map((n) => n.id).toSet();

    // Filter only truly new notifications
    final trulyNew = newNotifikasiList.where((n) => !currentIds.contains(n.id)).toList();

    if (trulyNew.isNotEmpty) {
      _logger.i('Found ${trulyNew.length} new notifications');

      // Merge and sort by creation time (newest first)
      final mergedList = [...trulyNew, ...currentState.notifikasiList];
      mergedList.sort((a, b) => b.dibuatPada.compareTo(a.dibuatPada));

      emit(NotifikasiListLoaded(
        notifikasiList: mergedList,
        showUnreadOnly: currentState.showUnreadOnly,
        hasMore: currentState.hasMore,
        isLoadingMore: false,
        hasNewData: true,
      ));
    }
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
