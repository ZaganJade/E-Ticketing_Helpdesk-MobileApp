import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Dio interceptor for handling authentication and token refresh
/// Uses JWT token from Backend API (Golang)
class AuthInterceptor extends Interceptor {
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;

  static const String _tokenKey = 'auth_token';

  AuthInterceptor({
    required FlutterSecureStorage secureStorage,
    Logger? logger,
  })  : _secureStorage = secureStorage,
        _logger = logger ?? Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get JWT token from secure storage
    final token = await _secureStorage.read(key: _tokenKey);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _logger.w('Received 401, token is invalid or expired');

      // Clear the invalid token
      await _secureStorage.delete(key: _tokenKey);

      // Note: Token refresh should be handled by AuthRepository
      // This interceptor just clears the invalid token
    }

    handler.next(err);
  }
}
