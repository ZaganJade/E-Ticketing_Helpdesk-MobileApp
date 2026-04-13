import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/app_config.dart';

/// Supabase Service
/// Provides centralized access to Supabase client and database tables
class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  static Future<void> initialize() async {
    // Initialize app config first
    await AppConfig.initialize();

    final config = AppConfig();

    await Supabase.initialize(
      url: config.supabaseUrl,
      anonKey: config.supabaseAnonKey,
      debug: kDebugMode,
    );

    if (kDebugMode) {
      print('✅ Supabase initialized successfully');
      print('   URL: ${config.supabaseUrl}');
      print('   App: ${config.appName} v${config.appVersion}');
    }
  }

  // Auth
  static GoTrueClient get auth => client.auth;

  // Database Tables
  static SupabaseQueryBuilder get penggunaTable => client.from('pengguna');
  static SupabaseQueryBuilder get tiketTable => client.from('tiket');
  static SupabaseQueryBuilder get komentarTable => client.from('komentar');
  static SupabaseQueryBuilder get notifikasiTable => client.from('notifikasi');
  static SupabaseQueryBuilder get lampiranTable => client.from('lampiran');

  // Storage
  static SupabaseStorageClient get storage => client.storage;

  /// Get bucket for lampiran tiket
  static String get lampiranBucketName => 'lampiran_tiket';

  /// Check if user is authenticated
  static bool get isAuthenticated => auth.currentUser != null;

  /// Get current user ID
  static String? get currentUserId => auth.currentUser?.id;
}
