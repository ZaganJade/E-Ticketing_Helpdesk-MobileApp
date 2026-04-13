import 'package:logger/logger.dart';
import '../../../core/services/api_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../models/profil_model.dart';

class ProfilRepository {
  final ApiService _apiService = getIt<ApiService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final Logger _logger = Logger();

  /// Get current user profile from backend API
  Future<ProfilModel> getProfil() async {
    try {
      _logger.i('[ProfilRepository] Getting current user...');

      // Get current user from auth repository
      final user = await _authRepository.getCurrentUser();
      _logger.i('[ProfilRepository] getCurrentUser returned: ${user?.id}, nama: ${user?.nama}');

      if (user == null) throw Exception('User tidak terautentikasi');

      // Return ProfilModel directly from user data
      // Since getCurrentUser() already fetches complete user data from /auth/me
      final profil = ProfilModel(
        id: user.id,
        nama: user.nama,
        email: user.email,
        peran: user.peran.name,
        dibuatPada: user.dibuatPada,
      );

      _logger.i('[ProfilRepository] Profil created: ${profil.nama}, ${profil.email}');
      return profil;
    } catch (e) {
      _logger.e('[ProfilRepository] Error getting profil: $e');
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  /// Update nama via backend API
  Future<ProfilModel> updateNama(String nama) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      // Call backend API to update nama
      final response = await _apiService.patch(
        '/auth/me',
        data: {'nama': nama},
      );

      final data = response.data;
      if (data == null) throw Exception('Gagal mengupdate nama');

      // Return updated profil
      return ProfilModel(
        id: user.id,
        nama: nama,
        email: user.email,
        peran: user.peran.name,
        dibuatPada: user.dibuatPada,
      );
    } catch (e) {
      throw Exception('Gagal mengupdate nama: $e');
    }
  }

  /// Update password via backend API
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      // Call backend API to update password
      await _apiService.post(
        '/auth/password',
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw Exception('Gagal mengupdate password: $e');
    }
  }

  /// Logout via AuthRepository
  Future<void> logout() async {
    try {
      await _authRepository.logout();
    } catch (e) {
      throw Exception('Gagal logout: $e');
    }
  }

  /// Get app version
  String get appVersion => '1.0.0';

  /// Get app name
  String get appName => 'E-Ticketing Helpdesk';
}
