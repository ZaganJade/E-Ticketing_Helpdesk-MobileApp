import 'package:dartz/dartz.dart';

import '../entities/komentar.dart';

/// Failure classes for komentar operations
abstract class KomentarFailure {
  final String message;
  const KomentarFailure(this.message);
}

class EmptyMessageFailure extends KomentarFailure {
  const EmptyMessageFailure() : super('Pesan tidak boleh kosong');
}

class TiketNotFoundFailure extends KomentarFailure {
  const TiketNotFoundFailure() : super('Tiket tidak ditemukan');
}

class ServerFailure extends KomentarFailure {
  const ServerFailure([String message = 'Terjadi kesalahan server']) : super(message);
}

class NetworkFailure extends KomentarFailure {
  const NetworkFailure() : super('Koneksi internet bermasalah');
}

class UnauthorizedFailure extends KomentarFailure {
  const UnauthorizedFailure() : super('Anda tidak memiliki akses');
}

class UnknownKomentarFailure extends KomentarFailure {
  const UnknownKomentarFailure([String message = 'Terjadi kesalahan']) : super(message);
}

/// Interface for komentar repository
abstract class KomentarRepository {
  /// Get all komentar for a specific tiket
  /// Returns list of komentar ordered by oldest first (chronological)
  Future<Either<KomentarFailure, List<Komentar>>> getKomentarByTiketId(String tiketId);

  /// Add a new komentar to a tiket
  /// Returns the newly created komentar if successful
  Future<Either<KomentarFailure, Komentar>> addKomentar({
    required String tiketId,
    required String isiPesan,
  });

  /// Delete a komentar (only by author or admin)
  Future<Either<KomentarFailure, void>> deleteKomentar(String komentarId);

  /// Subscribe to realtime komentar updates for a tiket
  /// Returns a stream of komentar changes
  Stream<List<Komentar>> subscribeToKomentarUpdates(String tiketId);

  /// Unsubscribe from realtime updates
  void unsubscribeFromKomentarUpdates();
}
