import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Dio interceptor for handling authentication with Supabase Auth
/// Uses Supabase JWT token for backend API authentication
class AuthInterceptor extends Interceptor {
  final SupabaseClient _supabaseClient;
  final Logger _logger;

  AuthInterceptor({
    required SupabaseClient supabaseClient,
    Logger? logger,
  })  : _supabaseClient = supabaseClient,
        _logger = logger ?? Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Get JWT token from Supabase Auth
    final session = _supabaseClient.auth.currentSession;
    final token = session?.accessToken;

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _logger.w('Received 401, token might be expired, attempting refresh');

      try {
        // Attempt to refresh the session using Supabase
        final refreshed = await _supabaseClient.auth.refreshSession();

        if (refreshed.session != null) {
          _logger.i('Session refreshed successfully, retrying request');

          // Retry the request with the new token
          final request = err.requestOptions;
          request.headers['Authorization'] = 'Bearer ${refreshed.session!.accessToken}';

          final response = await Dio().fetch(request);
          return handler.resolve(response);
        } else {
          _logger.e('Session refresh failed, no active session');
        }
      } catch (e) {
        _logger.e('Failed to refresh session: $e');
      }
    }

    handler.next(err);
  }
}
