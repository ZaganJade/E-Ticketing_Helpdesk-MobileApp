import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import '../../features/auth/data/services/auth_interceptor.dart';
import '../config/app_config.dart';

/// API Service for Golang Backend
/// Provides HTTP client with interceptors for auth, logging, and error handling
class ApiService {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  ApiService({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
  })  : _secureStorage = secureStorage,
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

  /// Get the current auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  void _setupInterceptors() {
    // Add AuthInterceptor for JWT token handling
    _dio.interceptors.add(
      AuthInterceptor(
        secureStorage: _secureStorage,
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
}
