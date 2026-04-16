import 'dart:io';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;
import '../../../core/services/api_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../models/profil_model.dart';

class ProfilRepository {
  final ApiService _apiService = getIt<ApiService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  final Logger _logger = Logger();
  final ImagePicker _imagePicker = ImagePicker();

  /// Allowed image formats for profile photo (hanya JPG dan PNG)
  static const List<String> _allowedImageExtensions = ['jpg', 'jpeg', 'png'];

  /// Max file size 5MB untuk foto profil
  static const int _maxFileSize = 5 * 1024 * 1024;

  /// Check if file extension is allowed
  bool isValidImageType(String fileName) {
    final ext = path.extension(fileName).toLowerCase().replaceFirst('.', '');
    return _allowedImageExtensions.contains(ext);
  }

  /// Check if file size is valid
  bool isValidFileSize(int fileSize) {
    return fileSize <= _maxFileSize;
  }

  /// Get allowed extensions as string for error messages
  String get allowedExtensions => _allowedImageExtensions.join(', ');

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

  /// Pick image from gallery dengan validasi JPG/PNG
  Future<XFile?> pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image == null) return null;

      // Validasi format file (hanya JPG/PNG)
      if (!isValidImageType(image.name)) {
        throw Exception(
          'Format file tidak didukung. Hanya file JPG, JPEG, dan PNG yang diizinkan.',
        );
      }

      // Validasi ukuran file
      final file = File(image.path);
      final fileSize = await file.length();
      if (!isValidFileSize(fileSize)) {
        throw Exception('Ukuran file maksimal 5MB');
      }

      return image;
    } catch (e) {
      _logger.e('[ProfilRepository] Error picking image: $e');
      rethrow;
    }
  }

  /// Upload foto profil dengan validasi JPG/PNG
  Future<ProfilModel> uploadFotoProfil(XFile imageFile) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      // Validasi ulang sebelum upload
      if (!isValidImageType(imageFile.name)) {
        throw Exception(
          'Format file tidak didukung. Hanya file JPG, JPEG, dan PNG yang diizinkan.',
        );
      }

      final file = File(imageFile.path);
      final fileSize = await file.length();
      if (!isValidFileSize(fileSize)) {
        throw Exception('Ukuran file maksimal 5MB');
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          imageFile.path,
          filename: imageFile.name,
        ),
      });

      // Upload via API Service
      final dio = Dio();
      final token = await _apiService.getToken();

      final response = await dio.post(
        '${_apiService.baseUrl}/auth/me/photo',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
      );

      final data = response.data;
      if (data == null || data['data'] == null) {
        throw Exception('Gagal mengupload foto profil');
      }

      // Return updated profil dengan foto_profil baru
      final responseData = data['data'] as Map<String, dynamic>;
      return ProfilModel(
        id: user.id,
        nama: responseData['nama'] ?? user.nama,
        email: user.email,
        peran: user.peran.name,
        dibuatPada: user.dibuatPada,
        fotoProfil: responseData['foto_profil'] as String?,
      );
    } catch (e) {
      _logger.e('[ProfilRepository] Error uploading photo: $e');
      throw Exception('Gagal mengupload foto profil: $e');
    }
  }

  /// Delete foto profil
  Future<ProfilModel> deleteFotoProfil() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      // Call API to delete photo
      await _apiService.delete('/auth/me/photo');

      // Return profil tanpa foto
      return ProfilModel(
        id: user.id,
        nama: user.nama,
        email: user.email,
        peran: user.peran.name,
        dibuatPada: user.dibuatPada,
        fotoProfil: null,
      );
    } catch (e) {
      _logger.e('[ProfilRepository] Error deleting photo: $e');
      throw Exception('Gagal menghapus foto profil: $e');
    }
  }
}
