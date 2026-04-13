import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../domain/entities/komentar.dart';
import '../../domain/repositories/komentar_repository.dart';
import '../models/komentar_model.dart';

/// Implementation of KomentarRepository using Backend API
class KomentarRepositoryImpl implements KomentarRepository {
  final ApiService _apiService;
  final Logger _logger;

  // Stream controllers for realtime updates (simulated via polling)
  final Map<String, StreamController<List<Komentar>>> _streamControllers = {};
  final Map<String, Timer> _pollingTimers = {};

  KomentarRepositoryImpl({
    required ApiService apiService,
    Logger? logger,
  })  : _apiService = apiService,
        _logger = logger ?? Logger();

  @override
  Future<Either<KomentarFailure, List<Komentar>>> getKomentarByTiketId(
    String tiketId,
  ) async {
    try {
      _logger.i('Fetching komentar for tiket: $tiketId');

      final response = await _apiService.get('/tikets/$tiketId/komentars');

      final data = response.data;
      if (data == null) {
        return const Right([]);
      }

      final List<dynamic> komentarList;
      if (data is List) {
        komentarList = data;
      } else if (data['data'] is List) {
        komentarList = data['data'] as List;
      } else {
        return const Right([]);
      }

      final komentars = komentarList
          .map((json) => KomentarModel.fromJson(json as Map<String, dynamic>))
          .toList();

      _logger.i('Fetched ${komentars.length} komentar');
      return Right(komentars);
    } on Exception catch (e) {
      _logger.e('Error fetching komentar: $e');
      return Left(UnknownKomentarFailure(e.toString()));
    }
  }

  @override
  Future<Either<KomentarFailure, Komentar>> addKomentar({
    required String tiketId,
    required String isiPesan,
  }) async {
    try {
      // Validate message is not empty
      if (isiPesan.trim().isEmpty) {
        return const Left(EmptyMessageFailure());
      }

      _logger.i('Adding komentar to tiket: $tiketId');

      // Backend extracts penulis_id from JWT token automatically
      // Only send isi_pesan in the request body
      final response = await _apiService.post(
        '/tikets/$tiketId/komentars',
        data: {
          'isi_pesan': isiPesan.trim(),
        },
      );

      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('Gagal menambahkan komentar'));
      }

      final komentarData = data['data'] ?? data;
      final komentar = KomentarModel.fromJson(komentarData as Map<String, dynamic>);

      _logger.i('Komentar added: ${komentar.id}');
      return Right(komentar);
    } on DioException catch (e) {
      _logger.e('DioError adding komentar: ${e.message}');
      if (e.response != null) {
        _logger.e('Response status: ${e.response?.statusCode}');
        _logger.e('Response data: ${e.response?.data}');
      }
      return Left(ServerFailure(e.response?.data?['error'] ?? 'Gagal menambahkan komentar'));
    } on Exception catch (e) {
      _logger.e('Error adding komentar: $e');
      return Left(UnknownKomentarFailure(e.toString()));
    }
  }

  @override
  Future<Either<KomentarFailure, void>> deleteKomentar(String komentarId) async {
    // Note: Backend doesn't have delete endpoint yet
    _logger.w('Delete komentar not implemented in Backend API');
    return const Left(ServerFailure('Fitur hapus komentar belum tersedia'));
  }

  @override
  Stream<List<Komentar>> subscribeToKomentarUpdates(String tiketId) {
    _logger.i('Subscribing to komentar updates for tiket: $tiketId (using polling)');

    // Unsubscribe from previous if exists
    unsubscribeFromKomentarUpdates();

    // Create stream controller
    final controller = StreamController<List<Komentar>>.broadcast();
    _streamControllers[tiketId] = controller;

    // Fetch initial data
    _fetchAndEmitKomentarList(tiketId);

    // Set up polling (every 5 seconds)
    _pollingTimers[tiketId] = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _fetchAndEmitKomentarList(tiketId),
    );

    return controller.stream;
  }

  String? _lastEmittedHash;

  Future<void> _fetchAndEmitKomentarList(String tiketId) async {
    try {
      final result = await getKomentarByTiketId(tiketId);
      result.fold(
        (failure) => _logger.e('Error in polling: ${failure.message}'),
        (komentarList) {
          final controller = _streamControllers[tiketId];
          if (controller != null && !controller.isClosed) {
            // Create a hash of IDs to detect duplicates
            final currentHash = komentarList.map((k) => k.id).join(',');
            if (currentHash != _lastEmittedHash) {
              _lastEmittedHash = currentHash;
              controller.add(komentarList);
            } else {
              _logger.d('Skipping duplicate emit - data unchanged');
            }
          }
        },
      );
    } catch (e) {
      _logger.e('Error in komentar polling: $e');
    }
  }

  @override
  void unsubscribeFromKomentarUpdates() {
    _logger.i('Unsubscribing from all komentar updates');

    // Cancel all polling timers
    for (final timer in _pollingTimers.values) {
      timer.cancel();
    }
    _pollingTimers.clear();

    // Close all stream controllers
    for (final controller in _streamControllers.values) {
      if (!controller.isClosed) {
        controller.close();
      }
    }
    _streamControllers.clear();
  }
}
