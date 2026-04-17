import 'package:dartz/dartz.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../tiket/data/models/tiket_model.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final ApiService _apiService;

  AdminDashboardRepositoryImpl({
    required ApiService apiService,
    required AuthRepository authRepository,
  }) : _apiService = apiService;

  @override
  Future<Either<AdminDashboardFailure, AdminDashboardStats>>
      getAdminDashboardStats() async {
    try {
      final response = await _apiService.get('/admin/dashboard');

      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Data tidak ditemukan'));
      }

      final dashboardData = data['data'] ?? data;

      final userStats = UserStatsByRole(
        pengguna: dashboardData['user_stats']?['pengguna'] ?? 0,
        helpdesk: dashboardData['user_stats']?['helpdesk'] ?? 0,
        admin: dashboardData['user_stats']?['admin'] ?? 0,
      );

      final performances = <HelpdeskPerformance>[];
      final performancesData = dashboardData['helpdesk_performance'] as List?;
      if (performancesData != null) {
        for (final item in performancesData) {
          performances.add(HelpdeskPerformance(
            helpdeskId: item['helpdesk_id']?.toString() ?? '',
            helpdeskNama: item['helpdesk_nama'] ?? 'Unknown',
            totalTiketDitugaskan: item['total_ditugaskan'] ?? 0,
            tiketSelesai: item['selesai'] ?? 0,
            rataRataPenyelesaianJam:
                (item['rata_rata_jam'] as num? ?? 0).toDouble(),
            persentasePenyelesaian:
                (item['persentase'] as num? ?? 0).toDouble(),
          ));
        }
      }

      return Right(AdminDashboardStats(
        userStats: userStats,
        helpdeskPerformances: performances,
        totalTiket: dashboardData['total_tiket'] ?? 0,
        tiketTerbuka: dashboardData['tiket_terbuka'] ?? 0,
        tiketDiproses: dashboardData['tiket_diproses'] ?? 0,
        tiketSelesai: dashboardData['tiket_selesai'] ?? 0,
      ));
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil data dashboard: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getUserStatsByRole() async {
    try {
      final response = await _apiService.get('/admin/users/stats');

      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Data tidak ditemukan'));
      }

      final stats = data['data'] ?? data;
      return Right({
        'pengguna': stats['pengguna'] ?? 0,
        'helpdesk': stats['helpdesk'] ?? 0,
        'admin': stats['admin'] ?? 0,
        'total': stats['total'] ?? 0,
      });
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil statistik pengguna: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, List<HelpdeskPerformance>>>
      getHelpdeskPerformance() async {
    try {
      final response = await _apiService.get('/admin/helpdesk/performance');

      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Data tidak ditemukan'));
      }

      final performancesData = data['data'] as List?;
      if (performancesData == null) {
        return Right([]);
      }

      final performances = <HelpdeskPerformance>[];
      for (final item in performancesData) {
        performances.add(HelpdeskPerformance(
          helpdeskId: item['helpdesk_id']?.toString() ?? '',
          helpdeskNama: item['helpdesk_nama'] ?? 'Unknown',
          totalTiketDitugaskan: item['total_ditugaskan'] ?? 0,
          tiketSelesai: item['selesai'] ?? 0,
          rataRataPenyelesaianJam:
              (item['rata_rata_jam'] as num? ?? 0).toDouble(),
          persentasePenyelesaian:
              (item['persentase'] as num? ?? 0).toDouble(),
        ));
      }

      return Right(performances);
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil performa helpdesk: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, List<Tiket>>> getAllTickets({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        '/admin/tikets',
        queryParameters: queryParams,
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
      return Left(AdminUnknownFailure('Gagal mengambil daftar tiket: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, List<Tiket>>> getRecentTickets({
    int limit = 10,
  }) async {
    try {
      final response = await _apiService.get(
        '/admin/tikets/recent',
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
      return Left(AdminUnknownFailure('Gagal mengambil tiket terbaru: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, Tiket>> reassignTicket(
    String tiketId,
    String? helpdeskId,
  ) async {
    try {
      final response = await _apiService.post(
        '/admin/tikets/$tiketId/assign',
        data: helpdeskId != null ? {'helpdesk_id': helpdeskId} : {},
      );

      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Gagal menugaskan ulang tiket'));
      }

      final tiketData = data['data'] ?? data;
      return Right(TiketModel.fromJson(tiketData as Map<String, dynamic>));
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal menugaskan ulang tiket: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getTicketStatsByStatus() async {
    try {
      final response = await _apiService.get('/admin/tikets/stats');

      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Data tidak ditemukan'));
      }

      final stats = data['data'] ?? data;
      return Right({
        'TERBUKA': stats['terbuka'] ?? 0,
        'DIPROSES': stats['diproses'] ?? 0,
        'SELESAI': stats['selesai'] ?? 0,
      });
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil statistik tiket: $e'));
    }
  }
}
