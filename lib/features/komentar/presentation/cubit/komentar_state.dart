part of 'komentar_cubit.dart';

/// Base class for all komentar states
abstract class KomentarState extends Equatable {
  const KomentarState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class KomentarInitial extends KomentarState {
  const KomentarInitial();
}

/// Loading state
class KomentarLoading extends KomentarState {
  const KomentarLoading();
}

/// Loaded state with komentar list
class KomentarLoaded extends KomentarState {
  final List<Komentar> komentarList;
  final bool hasNewKomentar;
  final String? newKomentarId;

  const KomentarLoaded({
    required this.komentarList,
    this.hasNewKomentar = false,
    this.newKomentarId,
  });

  /// Check if list is empty
  bool get isEmpty => komentarList.isEmpty;

  /// Get komentar count
  int get count => komentarList.length;

  KomentarLoaded copyWith({
    List<Komentar>? komentarList,
    bool? hasNewKomentar,
    String? newKomentarId,
  }) {
    return KomentarLoaded(
      komentarList: komentarList ?? this.komentarList,
      hasNewKomentar: hasNewKomentar ?? this.hasNewKomentar,
      newKomentarId: newKomentarId,
    );
  }

  @override
  List<Object?> get props => [komentarList, hasNewKomentar, newKomentarId];
}

/// Error state
class KomentarError extends KomentarState {
  final String message;

  const KomentarError(this.message);

  @override
  List<Object?> get props => [message];
}
