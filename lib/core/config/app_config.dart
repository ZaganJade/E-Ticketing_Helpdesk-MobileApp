import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// App Configuration
/// Loads environment variables and provides app-wide settings
class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  bool _initialized = false;

  /// Initialize configuration - call this before runApp
  static Future<void> initialize() async {
    // Load appropriate .env file based on flavor
    const envFile = String.fromEnvironment('ENV', defaultValue: '.env');
    await dotenv.load(fileName: envFile);
    _instance._initialized = true;
  }

  /// Verify config is loaded
  void _checkInitialized() {
    if (!_initialized) {
      throw Exception(
        'AppConfig not initialized. Call AppConfig.initialize() before accessing config values.',
      );
    }
  }

  // Supabase Configuration
  String get supabaseUrl {
    _checkInitialized();
    final url = dotenv.env['SUPABASE_URL'];
    if (url == null || url.isEmpty) {
      throw Exception('SUPABASE_URL not found in environment variables');
    }
    return url;
  }

  String get supabaseAnonKey {
    _checkInitialized();
    final key = dotenv.env['SUPABASE_ANON_KEY'];
    if (key == null || key.isEmpty) {
      throw Exception('SUPABASE_ANON_KEY not found in environment variables');
    }
    return key;
  }

  // Backend API Configuration
  String get apiBaseUrl {
    _checkInitialized();
    return dotenv.env['API_BASE_URL'] ?? 'http://localhost:8080/api';
  }

  // App Configuration
  String get appName {
    _checkInitialized();
    return dotenv.env['APP_NAME'] ?? 'E-Ticketing Helpdesk';
  }

  String get appVersion {
    _checkInitialized();
    return dotenv.env['APP_VERSION'] ?? '1.0.0';
  }

  /// Check if running in debug mode
  bool get isDebug => kDebugMode;

  /// Check if running in release mode
  bool get isRelease => kReleaseMode;

  /// Full app version string
  String get fullVersion => '$appVersion${isDebug ? " (Debug)" : ""}';
}

// Global config instance
final appConfig = AppConfig();
