import '../../../core/services/api_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../models/notifikasi_model.dart';

class NotifikasiRepository {
  final ApiService _apiService = getIt<ApiService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();

  // Get notifikasi list for current user
  Future<List<NotifikasiModel>> getNotifikasiList({
    bool onlyUnread = false,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (onlyUnread) {
        queryParams['sudah_dibaca'] = 'false';
      }

      final response = await _apiService.get(
        '/notifikasis',
        queryParameters: queryParams,
      );

      final data = response.data;
      if (data == null) return [];

      final List<dynamic> notifikasiList;
      if (data is List) {
        notifikasiList = data;
      } else if (data['data'] is List) {
        notifikasiList = data['data'] as List;
      } else {
        return [];
      }

      return notifikasiList
          .map((json) => NotifikasiModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil notifikasi: $e');
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) return 0;

      final response = await _apiService.get(
        '/notifikasis',
        queryParameters: {
          'sudah_dibaca': 'false',
          'limit': 1,
        },
      );

      final data = response.data;
      if (data == null) return 0;

      // Get total count from response metadata if available
      if (data is Map && data['total'] != null) {
        return data['total'] as int;
      }

      // Otherwise count from data list
      final List<dynamic> notifikasiList;
      if (data is List) {
        notifikasiList = data;
      } else if (data['data'] is List) {
        notifikasiList = data['data'] as List;
      } else {
        return 0;
      }

      return notifikasiList.length;
    } catch (e) {
      return 0;
    }
  }

  // Mark single notifikasi as read
  Future<void> markAsRead(String notifikasiId) async {
    try {
      await _apiService.patch(
        '/notifikasis/$notifikasiId/read',
      );
    } catch (e) {
      throw Exception('Gagal menandai notifikasi: $e');
    }
  }

  // Mark all notifikasi as read
  Future<void> markAllAsRead() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      await _apiService.patch('/notifikasis/read-all');
    } catch (e) {
      throw Exception('Gagal menandai semua notifikasi: $e');
    }
  }

  // Delete notifikasi
  Future<void> deleteNotifikasi(String notifikasiId) async {
    // Note: Backend doesn't have delete endpoint yet
    throw Exception('Fitur hapus notifikasi belum tersedia');
  }

  // Subscribe to notifikasi changes (smart polling - only emit when there are new notifications)
  Stream<List<NotifikasiModel>> subscribeToNotifikasi() async* {
    DateTime? lastLatestTimestamp;

    await for (final notifikasiList in Stream.periodic(const Duration(seconds: 30)).asyncMap(
      (_) => getNotifikasiList(onlyUnread: true),
    )) {
      // Check if there are new notifications by comparing timestamps
      if (notifikasiList.isNotEmpty) {
        final latestNotifikasi = notifikasiList.first;
        final currentLatestTimestamp = latestNotifikasi.dibuatPada;

        // Only emit if this is the first check OR there are new notifications
        if (lastLatestTimestamp == null || currentLatestTimestamp.isAfter(lastLatestTimestamp)) {
          lastLatestTimestamp = currentLatestTimestamp;
          yield notifikasiList;
        }
      } else if (lastLatestTimestamp != null) {
        // If previously there were notifications but now empty, update timestamp
        lastLatestTimestamp = null;
        yield [];
      }
      // If no change, don't emit to avoid unnecessary rebuilds
    }
  }
}
