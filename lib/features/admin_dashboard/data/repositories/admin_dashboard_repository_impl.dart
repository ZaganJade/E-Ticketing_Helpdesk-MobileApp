import 'package:dartz/dartz.dart';

import '../../../../core/services/api_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../tiket/data/models/tiket_model.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/helpdesk_availability.dart';
import '../../domain/repositories/admin_dashboard_repository.dart';

class AdminDashboardRepositoryImpl implements AdminDashboardRepository {
  final ApiService _apiService;

  AdminDashboardRepositoryImpl({
    required ApiService apiService,
    required AuthRepository authRepository,
  }) : _apiService = apiService;

  List<Tiket> _parseTiketList(dynamic data) {
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
        .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Either<AdminDashboardFailure, AdminDashboardStats>>
      getAdminDashboardStats() async {
    try {
      final response = await _apiService.get('/dashboard/stats');
      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Data tidak ditemukan'));
      }

      final terbuka = data['terbuka'] as int? ?? 0;
      final diproses = data['diproses'] as int? ?? 0;
      final selesai = data['selesai'] as int? ?? 0;
      final total = data['total'] as int? ?? (terbuka + diproses + selesai);

      return Right(AdminDashboardStats(
        userStats: const UserStatsByRole(pengguna: 0, helpdesk: 0, admin: 0),
        helpdeskPerformances: const [],
        totalTiket: total,
        tiketTerbuka: terbuka,
        tiketDiproses: diproses,
        tiketSelesai: selesai,
      ));
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil data dashboard: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getUserStatsByRole() async {
    return const Right({'pengguna': 0, 'helpdesk': 0, 'admin': 0, 'total': 0});
  }

  @override
  Future<Either<AdminDashboardFailure, List<HelpdeskPerformance>>>
      getHelpdeskPerformance() async {
    return const Right([]);
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
        '/tikets',
        queryParameters: queryParams,
      );
      return Right(_parseTiketList(response.data));
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil daftar tiket: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, List<Tiket>>> getPoolTickets({
    int limit = 50,
  }) async {
    return getAllTickets(status: 'TERBUKA', limit: limit);
  }

  @override
  Future<Either<AdminDashboardFailure, List<Tiket>>> getDiprosesTickets({
    int limit = 50,
  }) async {
    return getAllTickets(status: 'DIPROSES', limit: limit);
  }

  @override
  Future<Either<AdminDashboardFailure, List<HelpdeskAvailability>>>
      getAvailableHelpdesks() async {
    try {
      final response = await _apiService.get('/helpdesks');
      final data = response.data;
      if (data == null) return const Right([]);

      final List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data['data'] is List) {
        list = data['data'] as List;
      } else {
        return const Right([]);
      }

      return Right(list
          .map((json) =>
              HelpdeskAvailability.fromJson(json as Map<String, dynamic>))
          .toList());
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil daftar helpdesk: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, Tiket>> assignTicket(
    String tiketId,
    String helpdeskId,
  ) async {
    try {
      await _apiService.post(
        '/tikets/$tiketId/assign',
        data: {'helpdesk_id': helpdeskId},
      );
      final detail = await _apiService.get('/tikets/$tiketId');
      final tiketData = detail.data?['data'] ?? detail.data;
      return Right(TiketModel.fromJson(tiketData as Map<String, dynamic>));
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal menugaskan tiket: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, void>> unassignTicket(
    String tiketId,
  ) async {
    try {
      await _apiService.post('/tikets/$tiketId/unassign', data: {});
      return const Right(null);
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal menarik tiket ke pool: $e'));
    }
  }

  @override
  Future<Either<AdminDashboardFailure, List<Tiket>>> getRecentTickets({
    int limit = 10,
  }) async {
    return getAllTickets(limit: limit);
  }

  @override
  Future<Either<AdminDashboardFailure, Tiket>> reassignTicket(
    String tiketId,
    String? helpdeskId,
  ) async {
    if (helpdeskId == null || helpdeskId.isEmpty) {
      return Left(AdminUnknownFailure('Helpdesk wajib dipilih'));
    }
    return assignTicket(tiketId, helpdeskId);
  }

  @override
  Future<Either<AdminDashboardFailure, Map<String, int>>>
      getTicketStatsByStatus() async {
    try {
      final response = await _apiService.get('/dashboard/stats');
      final data = response.data;
      if (data == null) {
        return Left(AdminUnknownFailure('Data tidak ditemukan'));
      }
      return Right({
        'TERBUKA': data['terbuka'] ?? 0,
        'DIPROSES': data['diproses'] ?? 0,
        'SELESAI': data['selesai'] ?? 0,
      });
    } catch (e) {
      return Left(AdminUnknownFailure('Gagal mengambil statistik tiket: $e'));
    }
  }
}
