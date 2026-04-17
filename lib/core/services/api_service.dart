import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide MultipartFile;
import '../../features/auth/data/services/auth_interceptor.dart';
import '../config/app_config.dart';

/// API Service for Golang Backend
/// Provides HTTP client with interceptors for auth, logging, and error handling
/// Uses Supabase Auth token for authentication
class ApiService {
  late final Dio _dio;
  final SupabaseClient _supabaseClient;
  final Logger _logger;

  ApiService({
    required SupabaseClient supabaseClient,
    required Logger logger,
  })  : _supabaseClient = supabaseClient,
        _logger = logger {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig().apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _setupInterceptors();
  }

  Dio get dio => _dio;

  /// Get the base URL for API requests
  String get baseUrl => AppConfig().apiBaseUrl;

  /// Get the current Supabase auth token
  String? getToken() {
    final session = _supabaseClient.auth.currentSession;
    return session?.accessToken;
  }

  void _setupInterceptors() {
    // Add AuthInterceptor for Supabase JWT token handling
    _dio.interceptors.add(
      AuthInterceptor(
        supabaseClient: _supabaseClient,
        logger: _logger,
      ),
    );

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (object) => _logger.d(object.toString()),
        ),
      );
    }
  }

  // HTTP Methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return _dio.put(path, data: data);
  }

  Future<Response> patch(String path, {dynamic data}) async {
    return _dio.patch(path, data: data);
  }

  Future<Response> delete(String path) async {
    return _dio.delete(path);
  }

  /// Upload file using multipart/form-data
  /// Used for uploading lampiran files to backend
  Future<Response> uploadFile(
    String path, {
    required String filePath, // The key name in multipart form (e.g., 'file')
    required File file,
  }) async {
    final formData = FormData.fromMap({
      filePath: await MultipartFile.fromFile(file.path),
    });

    return _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {
          'Content-Type': 'multipart/form-data',
        },
      ),
    );
  }
}
