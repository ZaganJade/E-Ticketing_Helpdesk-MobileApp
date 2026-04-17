import 'package:dartz/dartz.dart';

import '../../../../core/services/api_service.dart';
import '../../../tiket/data/models/tiket_model.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/helpdesk_dashboard_stats.dart';
import '../../domain/repositories/helpdesk_dashboard_repository.dart';

class HelpdeskDashboardRepositoryImpl implements HelpdeskDashboardRepository {
  final ApiService _apiService;

  HelpdeskDashboardRepositoryImpl({
    required ApiService apiService,
  }) : _apiService = apiService;

  @override
  Future<Either<HelpdeskDashboardFailure, HelpdeskDashboardStats>>
      getHelpdeskDashboardStats() async {
    try {
      final response = await _apiService.get('/helpdesk/dashboard');

      final data = response.data;
      if (data == null) {
        return Left(HelpdeskUnknownFailure('Data tidak ditemukan'));
      }

      final dashboardData = data['data'] ?? data;

      final tiketTerbaruData = dashboardData['tiket_terbaru'] as List?;
      final tiketTerbaru = <Tiket>[];
      if (tiketTerbaruData != null) {
        for (final item in tiketTerbaruData) {
          tiketTerbaru.add(TiketModel.fromJson(item as Map<String, dynamic>));
        }
      }

      return Right(HelpdeskDashboardStats(
        totalTiketDitangani:
            dashboardData['total_ditangani'] as int? ?? 0,
        tiketTerbuka: dashboardData['tiket_terbuka'] as int? ?? 0,
        tiketSaya: dashboardData['tiket_saya'] as int? ?? 0,
        tiketTerbaru: tiketTerbaru,
        rataRataWaktuSelesai:
            (dashboardData['rata_rata_jam'] as num?)?.toDouble() ?? 0.0,
      ));
    } catch (e) {
      return Left(HelpdeskUnknownFailure('Gagal mengambil data dashboard: $e'));
    }
  }

  @override
  Future<Either<HelpdeskDashboardFailure, List<Tiket>>> getTiketTerbuka() async {
    try {
      final response = await _apiService.get('/helpdesk/tiket/terbuka');

      final data = response.data;
      if (data == null) {
        return Right([]);
      }

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return Right([]);
      }

      return Right(tiketList
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return Left(HelpdeskUnknownFailure('Gagal mengambil tiket terbuka: $e'));
    }
  }

  @override
  Future<Either<HelpdeskDashboardFailure, List<Tiket>>> getTiketSaya() async {
    try {
      final response = await _apiService.get('/helpdesk/tiket/saya');

      final data = response.data;
      if (data == null) {
        return Right([]);
      }

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return Right([]);
      }

      return Right(tiketList
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return Left(HelpdeskUnknownFailure('Gagal mengambil tiket saya: $e'));
    }
  }

  @override
  Future<Either<HelpdeskDashboardFailure, Tiket>> ambilTiket(
    String tiketId,
  ) async {
    try {
      final response = await _apiService.post(
        '/helpdesk/tiket/$tiketId/ambil',
        data: {},
      );

      final data = response.data;
      if (data == null) {
        return Left(HelpdeskUnknownFailure('Gagal mengambil tiket'));
      }

      final tiketData = data['data'] ?? data;
      return Right(TiketModel.fromJson(tiketData as Map<String, dynamic>));
    } catch (e) {
      return Left(HelpdeskUnknownFailure('Gagal mengambil tiket: $e'));
    }
  }

  @override
  Future<Either<HelpdeskDashboardFailure, List<Tiket>>> getRecentTiket({
    int limit = 5,
  }) async {
    try {
      final response = await _apiService.get(
        '/helpdesk/tiket/recent',
        queryParameters: {'limit': limit},
      );

      final data = response.data;
      if (data == null) {
        return Right([]);
      }

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return Right([]);
      }

      return Right(tiketList
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return Left(HelpdeskUnknownFailure('Gagal mengambil tiket terbaru: $e'));
    }
  }

  @override
  Future<Either<HelpdeskDashboardFailure, Map<String, dynamic>>>
      getHelpdeskPerformance() async {
    try {
      final response = await _apiService.get('/helpdesk/performance');

      final data = response.data;
      if (data == null) {
        return Left(HelpdeskUnknownFailure('Data tidak ditemukan'));
      }

      final perfData = data['data'] ?? data;
      return Right(Map<String, dynamic>.from(perfData));
    } catch (e) {
      return Left(HelpdeskUnknownFailure('Gagal mengambil performa: $e'));
    }
  }
}
