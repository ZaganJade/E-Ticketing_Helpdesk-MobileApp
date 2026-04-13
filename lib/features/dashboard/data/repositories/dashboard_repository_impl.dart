import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/domain/entities/pengguna.dart';
import '../../../auth/domain/repositories/auth_repository.dart' hide ServerFailure;
import '../../../tiket/data/models/tiket_model.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/tiket_status_stats.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../models/dashboard_stats_model.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final ApiService _apiService;
  final AuthRepository _authRepository;
  final Logger _logger;

  DashboardRepositoryImpl({
    required ApiService apiService,
    required AuthRepository authRepository,
    Logger? logger,
  })  : _apiService = apiService,
        _authRepository = authRepository,
        _logger = logger ?? Logger();

  @override
  Future<Either<DashboardFailure, DashboardStats>> getDashboardStats() async {
    try {
      _logger.i('Fetching dashboard stats from Backend API');

      // Get current user from AuthRepository
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return const Left(UnauthorizedFailure());
      }

      // Fetch stats from Backend API
      final response = await _apiService.get('/dashboard/stats');
      final data = response.data;

      if (data == null) {
        return const Left(ServerFailure('Gagal mengambil statistik'));
      }

      // Parse stats from response
      final total = data['total'] as int? ?? 0;
      final terbuka = data['terbuka'] as int? ?? 0;
      final diproses = data['diproses'] as int? ?? 0;
      final selesai = data['selesai'] as int? ?? 0;

      // Fetch recent tickets from Backend API
      final recentTiket = await _fetchRecentTiket();

      final stats = DashboardStatsModel(
        totalTiket: total,
        statusStats: TiketStatusStats(
          terbuka: terbuka,
          diproses: diproses,
          selesai: selesai,
        ),
        tiketTerbaru: recentTiket,
      );

      return Right(stats);
    } on Exception catch (e) {
      _logger.e('Error fetching dashboard stats: $e');
      return Left(UnknownDashboardFailure(e.toString()));
    }
  }

  Future<List<TiketModel>> _fetchRecentTiket() async {
    try {
      final response = await _apiService.get(
        '/tikets',
        queryParameters: {'limit': 5, 'sort': 'dibuat_pada.desc'},
      );

      final data = response.data;
      if (data == null) return [];

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return [];
      }

      return tiketList
          .map((t) => TiketModel.fromJson(t as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _logger.e('Error fetching recent tickets: $e');
      return [];
    }
  }

  @override
  Future<Either<DashboardFailure, List<Tiket>>> getRecentTiket({int limit = 5}) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return const Left(UnauthorizedFailure());
      }

      final response = await _apiService.get(
        '/tikets',
        queryParameters: {'limit': limit, 'sort': 'dibuat_pada.desc'},
      );

      final data = response.data;
      if (data == null) {
        return const Right([]);
      }

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return const Right([]);
      }

      final tikets = tiketList
          .map((t) => TiketModel.fromJson(t as Map<String, dynamic>))
          .toList();

      return Right(tikets);
    } on Exception catch (e) {
      _logger.e('Error fetching recent tickets: $e');
      return Left(UnknownDashboardFailure(e.toString()));
    }
  }

  @override
  Future<Either<DashboardFailure, List<Tiket>>> getTiketTerbuka() async {
    try {
      final response = await _apiService.get(
        '/tikets',
        queryParameters: {
          'status': 'TERBUKA',
          'ditugaskan_kepada': 'null',
          'sort': 'dibuat_pada.asc',
        },
      );

      final data = response.data;
      if (data == null) {
        return const Right([]);
      }

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return const Right([]);
      }

      final tikets = tiketList
          .map((t) => TiketModel.fromJson(t as Map<String, dynamic>))
          .toList();

      return Right(tikets);
    } on Exception catch (e) {
      _logger.e('Error fetching open tickets: $e');
      return Left(UnknownDashboardFailure(e.toString()));
    }
  }

  @override
  Future<Either<DashboardFailure, List<Tiket>>> getTiketSaya() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return const Left(UnauthorizedFailure());
      }

      final response = await _apiService.get(
        '/tikets',
        queryParameters: {
          'ditugaskan_kepada': user.id,
          'status': 'DIPROSES',
          'sort': 'dibuat_pada.desc',
        },
      );

      final data = response.data;
      if (data == null) {
        return const Right([]);
      }

      final List<dynamic> tiketList;
      if (data is List) {
        tiketList = data;
      } else if (data['data'] is List) {
        tiketList = data['data'] as List;
      } else {
        return const Right([]);
      }

      final tikets = tiketList
          .map((t) => TiketModel.fromJson(t as Map<String, dynamic>))
          .toList();

      return Right(tikets);
    } on Exception catch (e) {
      _logger.e('Error fetching my tickets: $e');
      return Left(UnknownDashboardFailure(e.toString()));
    }
  }

  @override
  Future<Either<DashboardFailure, Tiket>> ambilTiket(String tiketId) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) {
        return const Left(UnauthorizedFailure());
      }

      final response = await _apiService.post(
        '/tikets/$tiketId/assign',
      );

      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('Gagal mengambil tiket'));
      }

      final tiketData = data['data'] ?? data;
      final tiket = TiketModel.fromJson(tiketData as Map<String, dynamic>);

      return Right(tiket);
    } on Exception catch (e) {
      _logger.e('Error assigning ticket: $e');
      return Left(UnknownDashboardFailure(e.toString()));
    }
  }

  @override
  Future<Either<DashboardFailure, Map<String, int>>> getUserStats() async {
    // This endpoint doesn't exist in the backend yet
    // Return empty stats for now
    _logger.w('getUserStats not implemented in Backend API');
    return const Right({});
  }
}
