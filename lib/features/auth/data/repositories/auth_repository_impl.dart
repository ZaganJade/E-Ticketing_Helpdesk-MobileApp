import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/api_service.dart';
import '../../domain/entities/pengguna.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/pengguna_model.dart';

/// Implementation of AuthRepository using Golang Backend API
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final ApiService _apiService;

  static const String _tokenKey = 'auth_token';
  static const String _sessionKey = 'supabase_session';

  // Single broadcast stream controller for auth state changes
  StreamController<Pengguna?>? _authStateController;
  Timer? _pollingTimer;
  Pengguna? _lastUser;
  bool _hasEstablishedBaseline = false;
  int _listenerCount = 0;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    required FlutterSecureStorage secureStorage,
    required ApiService apiService,
    Logger? logger,
  })  : _supabaseClient = supabaseClient,
        _secureStorage = secureStorage,
        _apiService = apiService,
        _logger = logger ?? Logger();

  @override
  Future<Either<AuthFailure, Pengguna>> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting login via Backend API for email: $email');

      // Call Golang Backend API for login
      final response = await _apiService.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      final data = response.data;

      if (data == null || data['token'] == null) {
        return const Left(InvalidCredentialsFailure());
      }

      // Save token to secure storage
      final token = data['token'];
      await _secureStorage.write(key: _tokenKey, value: token);

      // Build user data from response - Go backend returns flat structure
      // user_id, nama, email, peran are at top level, not nested under 'user'
      final Map<String, dynamic> userJson = {
        'id': data['user_id'],
        'nama': data['nama'],
        'email': data['email'],
        'peran': data['peran'],
        'dibuat_pada': data['created_at'] ?? data['dibuat_pada'],
      };

      final userData = PenggunaModel.fromJson(userJson);

      // Validate we got a real user
      if (userData.id.isEmpty) {
        return const Left(ServerFailure('Login succeeded but user data is incomplete'));
      }

      _logger.i('Login successful for user: ${userData.id}');
      return Right(userData);
    } on DioException catch (e) {
      _logger.e('DioException during login: ${e.message}');
      return Left(_mapDioException(e));
    } catch (e) {
      _logger.e('Unexpected error during login: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, Pengguna>> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting registration via Backend API for email: $email');

      // Call Golang Backend API for register
      final response = await _apiService.post('/auth/register', data: {
        'nama': nama,
        'email': email,
        'password': password,
      });

      final data = response.data;
      if (data == null) {
        return const Left(ServerFailure('Gagal membuat akun'));
      }

      // Parse user data from response - handle flat structure
      final Map<String, dynamic> userJson;
      if (data['user'] != null) {
        final rawUser = data['user'] as Map<dynamic, dynamic>;
        userJson = rawUser.map((k, v) => MapEntry(k.toString(), v));
      } else {
        userJson = {
          'id': data['user_id'] ?? data['id'],
          'nama': data['nama'],
          'email': data['email'],
          'peran': data['peran'],
          'dibuat_pada': data['created_at'] ?? data['dibuat_pada'],
        };
      }
      final userData = PenggunaModel.fromJson(userJson);

      _logger.i('Registration successful for user: ${userData.id}');
      return Right(userData);
    } on DioException catch (e) {
      _logger.e('DioException during registration: ${e.message}');
      return Left(_mapDioException(e));
    } catch (e) {
      _logger.e('Unexpected error during registration: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      _logger.i('Attempting logout via Backend API');

      // Stop polling immediately to prevent race condition
      _stopPolling();
      _lastUser = null;

      // Call backend logout endpoint (optional, depends on your backend)
      try {
        await _apiService.post('/auth/logout');
      } catch (_) {
        // Ignore backend logout errors, still clear local storage
      }

      // Clear local token
      await _secureStorage.delete(key: _tokenKey);
      await _secureStorage.delete(key: _sessionKey);

      // Notify auth state listeners that user has logged out
      _authStateController?.add(null);

      _logger.i('Logout successful');
      return const Right(null);
    } catch (e) {
      _logger.e('Unexpected error during logout: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Pengguna?> getCurrentUser() async {
    try {
      final token = await _secureStorage.read(key: _tokenKey);
      if (token == null) return null;

      // Fetch current user from backend API
      final response = await _apiService.get('/auth/me');
      final data = response.data;

      _logger.i('/auth/me response: $data');

      if (data == null) return null;

      // Handle both flat and nested response structures
      Map<String, dynamic> userJson;
      if (data['user'] != null) {
        // Nested structure: { user: { id, nama, ... } }
        final rawUser = data['user'] as Map<dynamic, dynamic>;
        userJson = rawUser.map((k, v) => MapEntry(k.toString(), v));
      } else if (data['id'] != null || data['user_id'] != null) {
        // Flat structure: { id, nama, email, peran, ... }
        userJson = {
          'id': data['id'] ?? data['user_id'],
          'nama': data['nama'] ?? data['name'],
          'email': data['email'],
          'peran': data['peran'] ?? data['role'],
          'dibuat_pada': data['created_at'] ?? data['dibuat_pada'],
        };
      } else {
        return null;
      }

      final user = PenggunaModel.fromJson(userJson);
      // Treat user with empty ID as unauthenticated
      if (user.id.isEmpty) return null;

      return user;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token expired or invalid
        await _secureStorage.delete(key: _tokenKey);
      }
      _logger.e('Error getting current user: $e');
      return null;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await _secureStorage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  @override
  Future<Either<AuthFailure, void>> refreshSession() async {
    try {
      _logger.i('Attempting to refresh token via Backend API');

      // Call backend refresh endpoint
      final response = await _apiService.post('/auth/refresh');

      final data = response.data;
      if (data == null || data['token'] == null) {
        return const Left(SessionExpiredFailure());
      }

      // Save new token
      final token = data['token'];
      await _secureStorage.write(key: _tokenKey, value: token);

      _logger.i('Token refreshed successfully');
      return const Right(null);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _secureStorage.delete(key: _tokenKey);
        return const Left(SessionExpiredFailure());
      }
      _logger.e('DioException during refresh: ${e.message}');
      return Left(_mapDioException(e));
    } catch (e) {
      _logger.e('Unexpected error during refresh: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Stream<Pengguna?> get authStateChanges {
    // Create single broadcast stream controller on first access
    _authStateController ??= StreamController<Pengguna?>.broadcast(
      onListen: () {
        _listenerCount++;
        _startPolling();
      },
      onCancel: () {
        _listenerCount--;
        if (_listenerCount <= 0) {
          _stopPolling();
        }
      },
    );
    return _authStateController!.stream;
  }

  /// Start polling when first listener subscribes
  void _startPolling() {
    if (_pollingTimer != null) return; // Already polling

    _logger.i('Starting auth state polling ($_listenerCount listeners)');

    // Poll every 30 seconds (reduced from 5 seconds to minimize server load)
    _pollingTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final user = await getCurrentUser();

      // Only emit if user actually changed
      if (user?.id != _lastUser?.id) {
        if (_hasEstablishedBaseline || user != null) {
          _authStateController?.add(user);
        }
        _hasEstablishedBaseline = true;
        _lastUser = user;
      }
    });

    // Do initial check immediately only on first listener
    if (_listenerCount == 1) {
      _performInitialCheck();
    }
  }

  /// Perform initial auth check
  Future<void> _performInitialCheck() async {
    final user = await getCurrentUser();
    _hasEstablishedBaseline = true;
    _lastUser = user;
    _authStateController?.add(user);
  }

  /// Stop polling when last listener cancels
  void _stopPolling() {
    _logger.i('Stopping auth state polling (no listeners)');
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  /// Fetch user data from pengguna table
  Future<PenggunaModel> _fetchUserData(String userId) async {
    try {
      final response = await _supabaseClient
          .from('pengguna')
          .select()
          .eq('id', userId)
          .single();

      return PenggunaModel.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching user data: $e');
      // Return a default user if database fetch fails
      final authUser = _supabaseClient.auth.currentUser;
      return PenggunaModel(
        id: userId,
        nama: authUser?.userMetadata?['nama'] ?? 'Pengguna',
        email: authUser?.email ?? '',
        peran: Peran.fromString(authUser?.userMetadata?['peran'] ?? 'pengguna'),
        dibuatPada: DateTime.now(),
      );
    }
  }

  /// Map Supabase AuthException to domain AuthFailure
  AuthFailure _mapAuthException(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('invalid login credentials') ||
        message.contains('invalid credentials')) {
      return const InvalidCredentialsFailure();
    }
    if (message.contains('user already registered') ||
        message.contains('already registered')) {
      return const EmailAlreadyRegisteredFailure();
    }
    if (message.contains('password')) {
      return const WeakPasswordFailure();
    }
    if (message.contains('email')) {
      return const InvalidEmailFailure();
    }
    if (message.contains('session expired') || message.contains('jwt')) {
      return const SessionExpiredFailure();
    }

    return UnknownAuthFailure(e.message);
  }

  /// Map DioException to domain AuthFailure
  AuthFailure _mapDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final message = e.message?.toLowerCase() ?? '';

    switch (statusCode) {
      case 400:
        if (message.contains('email already exists') ||
            message.contains('already registered')) {
          return const EmailAlreadyRegisteredFailure();
        }
        if (message.contains('password')) {
          return const WeakPasswordFailure();
        }
        return const InvalidCredentialsFailure();
      case 401:
        return const InvalidCredentialsFailure();
      case 404:
        return const ServerFailure('API endpoint not found');
      case 500:
      case 502:
      case 503:
        return const ServerFailure('Server error, please try again later');
      default:
        if (message.contains('connection') || message.contains('timeout')) {
          return const NetworkFailure();
        }
        return UnknownAuthFailure(e.message ?? 'Unknown error');
    }
  }

  /// Dispose resources - call this when repository is no longer needed
  void dispose() {
    _pollingTimer?.cancel();
    _authStateController?.close();
  }
}
