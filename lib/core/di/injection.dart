import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/admin_dashboard/admin_dashboard.dart';
import '../../features/auth/auth.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/helpdesk_dashboard/helpdesk_dashboard.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/komentar/komentar.dart';
import '../../features/tiket/tiket.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';
import '../theme/theme_cubit.dart';

// Global service locator
final GetIt getIt = GetIt.instance;

/// Initialize dependency injection
/// Call this in main.dart before runApp
Future<void> initDependencies() async {
  // Logger
  getIt.registerLazySingleton<Logger>(() => Logger(
        printer: PrettyPrinter(
          methodCount: 2,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          printTime: true,
        ),
      ));

  // Secure Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock,
      ),
    ),
  );

  // Supabase
  getIt.registerLazySingleton<SupabaseClient>(
    () => SupabaseService.client,
  );

  // API Service (Golang Backend) - Uses Supabase token for auth
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(
      supabaseClient: getIt<SupabaseClient>(),
      logger: getIt<Logger>(),
    ),
  );

  // Auth Repository - Uses Supabase Auth SDK directly
  final authRepo = AuthRepositoryImpl(
    supabaseClient: getIt<SupabaseClient>(),
    logger: getIt<Logger>(),
  );
  getIt.registerSingleton<AuthRepository>(authRepo);

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(authRepository: getIt()),
  );

  // Theme Cubit - singleton to persist across the app
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(),
  );

  getIt.registerFactory<LoginCubit>(
    () => LoginCubit(authRepository: getIt()),
  );

  getIt.registerFactory<RegisterCubit>(
    () => RegisterCubit(authRepository: getIt()),
  );

  // ============================
  // Komentar Feature
  // ============================

  // Repository
  getIt.registerLazySingleton<KomentarRepository>(
    () => KomentarRepositoryImpl(
      apiService: getIt<ApiService>(),
      logger: getIt<Logger>(),
    ),
  );

  // Cubits
  getIt.registerFactory<KomentarCubit>(
    () => KomentarCubit(
      komentarRepository: getIt(),
      authRepository: getIt(),
    ),
  );

  getIt.registerFactory<KomentarInputCubit>(
    () => KomentarInputCubit(
      komentarRepository: getIt(),
    ),
  );

  // ============================
  // Dashboard Feature
  // ============================

  // Dashboard Repository - depends on ApiService and AuthRepository
  getIt.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      apiService: getIt<ApiService>(),
      authRepository: getIt<AuthRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  // Cubits
  getIt.registerFactory<DashboardCubit>(
    () => DashboardCubit(
      dashboardRepository: getIt(),
      apiService: getIt<ApiService>(),
    ),
  );

  // ============================
  // Tiket Feature
  // ============================

  // Repository
  getIt.registerLazySingleton<TiketRepository>(
    () => TiketRepository(),
  );

  // Cubits
  getIt.registerFactory<TiketCubit>(
    () => TiketCubit(tiketRepository: getIt()),
  );

  // ============================
  // Admin Dashboard Feature
  // ============================

  // Admin Dashboard Repository
  getIt.registerLazySingleton<AdminDashboardRepository>(
    () => AdminDashboardRepositoryImpl(
      apiService: getIt<ApiService>(),
      authRepository: getIt<AuthRepository>(),
    ),
  );

  // Admin Dashboard Cubit
  getIt.registerFactory<AdminDashboardCubit>(
    () => AdminDashboardCubit(
      repository: getIt<AdminDashboardRepository>(),
    ),
  );

  // ============================
  // Helpdesk Dashboard Feature
  // ============================

  // Helpdesk Dashboard Repository
  getIt.registerLazySingleton<HelpdeskDashboardRepository>(
    () => HelpdeskDashboardRepositoryImpl(
      apiService: getIt<ApiService>(),
    ),
  );

  // Helpdesk Dashboard Cubit
  getIt.registerFactory<HelpdeskDashboardCubit>(
    () => HelpdeskDashboardCubit(
      repository: getIt<HelpdeskDashboardRepository>(),
    ),
  );
}

/// Extension to get AuthRepository from BuildContext
extension AuthRepositoryExtension on BuildContext {
  AuthRepository get authRepository => getIt<AuthRepository>();
}
