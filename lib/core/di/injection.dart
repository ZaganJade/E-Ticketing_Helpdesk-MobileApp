import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/auth.dart';
import '../../features/dashboard/domain/repositories/dashboard_repository.dart';
import '../../features/dashboard/data/repositories/dashboard_repository_impl.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/komentar/komentar.dart';
import '../../features/tiket/tiket.dart';
import '../services/api_service.dart';
import '../services/supabase_service.dart';

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

  // API Service (Golang Backend) - Register BEFORE repositories
  getIt.registerLazySingleton<ApiService>(
    () => ApiService(
      secureStorage: getIt(),
      logger: getIt(),
    ),
  );

  // Auth Repository - depends on ApiService (non-lazy to ensure availability)
  final authRepo = AuthRepositoryImpl(
    supabaseClient: getIt<SupabaseClient>(),
    secureStorage: getIt<FlutterSecureStorage>(),
    apiService: getIt<ApiService>(),
    logger: getIt<Logger>(),
  );
  getIt.registerSingleton<AuthRepository>(authRepo);

  // Cubits
  getIt.registerFactory<AuthCubit>(
    () => AuthCubit(authRepository: getIt()),
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
}

/// Extension to get AuthRepository from BuildContext
extension AuthRepositoryExtension on BuildContext {
  AuthRepository get authRepository => getIt<AuthRepository>();
}
