import 'dart:io';

import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/api_service.dart';
import '../../../features/auth/domain/repositories/auth_repository.dart';
import '../../../core/di/injection.dart';
import '../models/tiket_model.dart';

class TiketRepository {
  final ApiService _apiService = getIt<ApiService>();
  final AuthRepository _authRepository = getIt<AuthRepository>();

  // Get list of tiket with pagination and filters
  Future<List<TiketModel>> getTiketList({
    String? status,
    String? search,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (status != null && status != 'semua') {
        queryParams['status'] = status;
      }

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }

      final response = await _apiService.get(
        '/tikets',
        queryParameters: queryParams,
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
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar tiket: $e');
    }
  }

  // Get tiket detail by ID
  Future<TiketModel> getTiketDetail(String tiketId) async {
    try {
      final response = await _apiService.get('/tikets/$tiketId');

      final data = response.data;
      if (data == null) {
        throw Exception('Tiket tidak ditemukan');
      }

      final tiketData = data['data'] ?? data;
      return TiketModel.fromJson(tiketData as Map<String, dynamic>);
    } catch (e) {
      throw Exception('Gagal mengambil detail tiket: $e');
    }
  }

  // Create new tiket
  Future<TiketModel> createTiket({
    required String judul,
    required String deskripsi,
    List<PlatformFile>? lampiranFiles,
  }) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      if (kDebugMode) {
        print('🎫 Creating ticket: $judul');
        print('📎 Files to upload: ${lampiranFiles?.length ?? 0}');
      }

      // Create multipart form data
      final formData = FormData.fromMap({
        'judul': judul,
        'deskripsi': deskripsi,
      });

      // Add files to form
      if (lampiranFiles != null && lampiranFiles.isNotEmpty) {
        for (int i = 0; i < lampiranFiles.length; i++) {
          final file = lampiranFiles[i];
          final fileBytes = file.bytes;
          if (fileBytes == null) {
            throw Exception('File bytes is null for ${file.name}');
          }

          // Create temp file for multipart upload
          final tempDir = Directory.systemTemp;
          final tempPath = '${tempDir.path}/${file.name}';
          final tempFile = File(tempPath);
          await tempFile.writeAsBytes(fileBytes);

          if (kDebugMode) {
            print('📄 Adding file $i to form: ${file.name}');
            print('   Size: ${file.size} bytes');
          }

          formData.files.add(MapEntry(
            'files',
            await MultipartFile.fromFile(
              tempPath,
              filename: file.name,
            ),
          ));
        }
      }

      final response = await _apiService.post(
        '/tikets',
        data: formData,
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal membuat tiket');
      }

      final tiketData = data['data'] ?? data;
      final tiket = TiketModel.fromJson(tiketData as Map<String, dynamic>);

      if (kDebugMode) {
        print('✅ Ticket created: ${tiket.id}');
      }

      return tiket;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error creating ticket: $e');
      }
      throw Exception('Gagal membuat tiket: $e');
    }
  }

  // Update tiket status
  Future<TiketModel> updateTiketStatus(String tiketId, String status) async {
    try {
      final response = await _apiService.patch(
        '/tikets/$tiketId/status',
        data: {'status': status},
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal mengupdate status tiket');
      }

      // Refresh ticket data after status update
      return await getTiketDetail(tiketId);
    } catch (e) {
      throw Exception('Gagal mengupdate status tiket: $e');
    }
  }

  // Assign tiket to helpdesk
  Future<TiketModel> assignTiket(String tiketId, String? helpdeskId) async {
    try {
      final response = await _apiService.post(
        '/tikets/$tiketId/assign',
        data: helpdeskId != null ? {'helpdesk_id': helpdeskId} : {},
      );

      final data = response.data;
      if (data == null) {
        throw Exception('Gagal menugaskan tiket');
      }

      // Refresh ticket data after assignment
      return await getTiketDetail(tiketId);
    } catch (e) {
      throw Exception('Gagal menugaskan tiket: $e');
    }
  }

  // Get all tiket for helpdesk/admin
  Future<List<TiketModel>> getAllTiket({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };

      if (status != null && status != 'semua') {
        queryParams['status'] = status;
      }

      final response = await _apiService.get(
        '/tikets',
        queryParameters: queryParams,
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
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil daftar tiket: $e');
    }
  }

  // Get tiket statistics for dashboard
  Future<Map<String, int>> getTiketStats() async {
    try {
      final response = await _apiService.get('/dashboard/stats');

      final data = response.data;
      if (data == null) {
        return {'total': 0, 'terbuka': 0, 'diproses': 0, 'selesai': 0};
      }

      return {
        'total': data['total'] as int? ?? 0,
        'terbuka': data['terbuka'] as int? ?? 0,
        'diproses': data['diproses'] as int? ?? 0,
        'selesai': data['selesai'] as int? ?? 0,
      };
    } catch (e) {
      throw Exception('Gagal mengambil statistik tiket: $e');
    }
  }

  // Subscribe to tiket changes (realtime)
  // Note: Realtime requires Supabase, will be disabled if Supabase is unavailable
  Stream<List<Map<String, dynamic>>> subscribeToTiketChanges() {
    // Return empty stream since we're using Backend API
    // Realtime updates would need a different approach (WebSocket, polling, etc.)
    return Stream.empty();
  }

  // Get unassigned tiket (for helpdesk)
  Future<List<TiketModel>> getUnassignedTiket({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final response = await _apiService.get(
        '/tikets',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'status': 'TERBUKA',
          'ditugaskan_kepada': 'null',
        },
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
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil tiket yang belum ditugaskan: $e');
    }
  }

  // Get my assigned tiket (for helpdesk)
  Future<List<TiketModel>> getMyAssignedTiket({
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user == null) throw Exception('User tidak terautentikasi');

      final response = await _apiService.get(
        '/tikets',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          'ditugaskan_kepada': user.id,
          'status': 'DIPROSES',
        },
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
          .map((json) => TiketModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Gagal mengambil tiket yang ditugaskan: $e');
    }
  }
}
