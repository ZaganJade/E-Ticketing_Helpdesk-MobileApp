import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;
import '../../../core/services/api_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../models/lampiran_model.dart';

class LampiranRepository {
  final ApiService _apiService = getIt<ApiService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();
  static const int _maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> _allowedExtensions = [
    'jpg', 'jpeg', 'png', 'gif', 'webp',
    'pdf', 'doc', 'docx'
  ];

  // Validation
  bool isValidFileType(String fileName) {
    final ext = path.extension(fileName).toLowerCase().replaceFirst('.', '');
    return _allowedExtensions.contains(ext);
  }

  bool isValidFileSize(int fileSize) {
    return fileSize <= _maxFileSize;
  }

  String? getFileExtension(String fileName) {
    return path.extension(fileName).toLowerCase().replaceFirst('.', '');
  }

  // Get lampiran by tiket ID
  Future<List<LampiranModel>> getLampiranByTiket(String tiketId) async {
    try {
      final response = await _apiService.get('/tikets/$tiketId/lampirans');

      final data = response.data;
      if (data == null) return [];

      final List<dynamic> lampiranList;
      if (data is List) {
        lampiranList = data;
      } else if (data['data'] is List) {
        lampiranList = data['data'] as List;
      } else {
        return [];
      }

      return lampiranList
          .map((json) => LampiranModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil lampiran: $e');
    }
  }

  // Upload lampiran
  Future<LampiranModel> uploadLampiran({
    required String tiketId,
    required File file,
    required String fileName,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      // Validate file
      final fileSize = await file.length();
      if (!isValidFileSize(fileSize)) {
        throw Exception('Ukuran file maksimal 10MB');
      }
      if (!isValidFileType(fileName)) {
        throw Exception('Format file tidak diizinkan. Format yang diizinkan: jpg, png, pdf, doc, docx');
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          file.path,
          filename: fileName,
        ),
      });

      // Upload via API Service
      final dio = Dio();
      final token = await _apiService.getToken();

      final response = await dio.post(
        '${_apiService.baseUrl}/tikets/$tiketId/lampirans/upload',
        data: formData,
        options: Options(
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
          },
        ),
        onSendProgress: (sent, total) {
          if (onProgress != null && total > 0) {
            onProgress(sent / total);
          }
        },
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal mengupload lampiran');
      }

      final lampiranData = data['data'] ?? data;
      return LampiranModel.fromJson(lampiranData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal mengupload lampiran: $e');
    }
  }

  // Delete lampiran
  Future<void> deleteLampiran(String tiketId, String lampiranId) async {
    try {
      await _apiService.delete('/tikets/$tiketId/lampirans/$lampiranId');
    } catch (e) {
      throw Exception('Gagal menghapus lampiran: $e');
    }
  }

  // Download lampiran
  Future<String> downloadLampiran(String tiketId, LampiranModel lampiran) async {
    try {
      final response = await _apiService.get(
        '/tikets/$tiketId/lampirans/${lampiran.id}/download',
      );

      final data = response.data;
      if (data == null || data['download_url'] == null) {
        throw Exception('Gagal mendapatkan URL download');
      }

      return data['download_url'] as String;
    } catch (e) {
      throw Exception('Gagal mengunduh lampiran: $e');
    }
  }

  // Get download URL
  String getDownloadUrl(LampiranModel lampiran) {
    return lampiran.pathFile;
  }
}
