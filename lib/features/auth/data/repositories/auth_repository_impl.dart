import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/pengguna.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/pengguna_model.dart';

/// Implementation of AuthRepository using Supabase Auth SDK
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  final Logger _logger;

  // Cache for user data to avoid repeated database queries
  PenggunaModel? _cachedUser;

  AuthRepositoryImpl({
    required SupabaseClient supabaseClient,
    Logger? logger,
  })  : _supabaseClient = supabaseClient,
        _logger = logger ?? Logger();

  @override
  Future<Either<AuthFailure, Pengguna>> login({
    required String email,
    required String password,
  }) async {
    try {
      _logger.i('Attempting login via Supabase Auth for email: $email');

      // Use Supabase Auth SDK for login
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = response.user;
      if (user == null) {
        return const Left(InvalidCredentialsFailure());
      }

      // Fetch additional user data from pengguna table
      final pengguna = await _fetchUserData(user.id);

      // Update Supabase Auth user metadata with nama and peran
      // This ensures fallback to auth metadata works correctly
      await _supabaseClient.auth.updateUser(
        UserAttributes(
          data: {
            'nama': pengguna.nama,
            'peran': pengguna.peran.toString(),
          },
        ),
      );
      _logger.i('Updated auth metadata: nama=${pengguna.nama}, peran=${pengguna.peran}');

      // Cache the user data
      _cachedUser = pengguna;

      _logger.i('Login successful for user: ${pengguna.id}, role: ${pengguna.peran}');
      return Right(pengguna);
    } on AuthException catch (e) {
      _logger.e('AuthException during login: ${e.message}');
      return Left(_mapAuthException(e));
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
      _logger.i('Attempting registration via Supabase Auth for email: $email');

      // Use Supabase Auth SDK for registration
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'nama': nama,
          'peran': 'pengguna',
        },
      );

      final user = response.user;
      if (user == null) {
        return const Left(ServerFailure('Gagal membuat akun'));
      }

      // Create user data locally (webhook will sync to backend)
      final pengguna = PenggunaModel(
        id: user.id,
        nama: nama,
        email: email,
        peran: Peran.pengguna,
        dibuatPada: DateTime.now(),
        fotoProfil: null,
      );

      _logger.i('Registration successful for user: ${pengguna.id}');
      return Right(pengguna);
    } on AuthException catch (e) {
      _logger.e('AuthException during registration: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e) {
      _logger.e('Unexpected error during registration: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Either<AuthFailure, void>> logout() async {
    try {
      _logger.i('Attempting logout via Supabase Auth');

      // Use Supabase Auth SDK for logout
      await _supabaseClient.auth.signOut();

      // Clear cache
      _cachedUser = null;

      _logger.i('Logout successful');
      return const Right(null);
    } on AuthException catch (e) {
      _logger.e('AuthException during logout: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e) {
      _logger.e('Unexpected error during logout: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Future<Pengguna?> getCurrentUser() async {
    try {
      final session = _supabaseClient.auth.currentSession;
      if (session == null) {
        _cachedUser = null;
        return null;
      }

      final user = _supabaseClient.auth.currentUser;
      if (user == null) {
        _cachedUser = null;
        return null;
      }

      // Return cached user if available and matches current user
      if (_cachedUser != null && _cachedUser!.id == user.id) {
        _logger.d('Returning cached user: ${_cachedUser!.nama}, role: ${_cachedUser!.peran}');
        return _cachedUser;
      }

      // Fetch user data from pengguna table
      _logger.i('Cache miss, fetching user data from database');
      final userData = await _fetchUserData(user.id);
      _cachedUser = userData;

      return userData;
    } catch (e) {
      _logger.e('Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final session = _supabaseClient.auth.currentSession;
    return session != null;
  }

  @override
  Future<Either<AuthFailure, void>> refreshSession() async {
    try {
      _logger.i('Refreshing Supabase session');

      final response = await _supabaseClient.auth.refreshSession();
      if (response.session == null) {
        return const Left(SessionExpiredFailure());
      }

      _logger.i('Session refreshed successfully');
      return const Right(null);
    } on AuthException catch (e) {
      _logger.e('AuthException during refresh: ${e.message}');
      return Left(_mapAuthException(e));
    } catch (e) {
      _logger.e('Unexpected error during refresh: $e');
      return Left(UnknownAuthFailure(e.toString()));
    }
  }

  @override
  Stream<Pengguna?> get authStateChanges {
    return _supabaseClient.auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;

      final user = session.user;
      if (user == null) return null;

      return await _fetchUserData(user.id);
    });
  }

  /// Fetch user data from pengguna table
  Future<PenggunaModel> _fetchUserData(String userId) async {
    try {
      _logger.i('Fetching user data from pengguna table for user: $userId');
      final response = await _supabaseClient
          .from('pengguna')
          .select()
          .eq('id', userId)
          .maybeSingle();

      _logger.i('Pengguna table query result: ${response != null ? "found" : "not found"}');

      // If no user data in pengguna table yet, return default from auth metadata
      if (response == null) {
        _logger.w('User not found in pengguna table, falling back to auth metadata');
        final authUser = _supabaseClient.auth.currentUser;
        final metadataNama = authUser?.userMetadata?['nama'] as String?;
        final metadataPeran = authUser?.userMetadata?['peran'] as String?;

        _logger.i('Auth metadata - nama: $metadataNama, peran: $metadataPeran');

        return PenggunaModel(
          id: userId,
          nama: metadataNama ?? authUser?.email ?? 'Unknown User',
          email: authUser?.email ?? '',
          peran: Peran.fromString(metadataPeran ?? 'pengguna'),
          dibuatPada: DateTime.now(),
          fotoProfil: authUser?.userMetadata?['foto_profil'] as String?,
        );
      }

      _logger.i('Successfully fetched user from pengguna table: nama=${response['nama']}, peran=${response['peran']}');
      return PenggunaModel.fromJson(response);
    } catch (e) {
      _logger.e('Error fetching user data from pengguna table: $e');
      // Return a default user if database fetch fails
      final authUser = _supabaseClient.auth.currentUser;
      final metadataNama = authUser?.userMetadata?['nama'] as String?;
      final metadataPeran = authUser?.userMetadata?['peran'] as String?;

      _logger.i('Fallback to auth metadata - nama: $metadataNama, peran: $metadataPeran');

      return PenggunaModel(
        id: userId,
        nama: metadataNama ?? authUser?.email ?? 'Unknown User',
        email: authUser?.email ?? '',
        peran: Peran.fromString(metadataPeran ?? 'pengguna'),
        dibuatPada: DateTime.now(),
        fotoProfil: authUser?.userMetadata?['foto_profil'] as String?,
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
}
