import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin_dashboard/admin_dashboard.dart';
import '../../features/auth/auth.dart';
import '../../features/dashboard/dashboard.dart';
import '../../features/helpdesk_dashboard/helpdesk_dashboard.dart';
import '../../features/notifikasi/notifikasi.dart';
import '../../features/profil/profil.dart';
import '../../features/tiket/tiket.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/app_navbar.dart' show NavTab;
import '../utils/role_utils.dart';

/// App Router Configuration
/// Uses GoRouter for declarative routing with deep linking support
class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter get router => _router;

  /// Helper to check if user is staff (helpdesk or admin)
  static Future<bool> _isStaff() async {
    return await RoleUtils.isStaff();
  }

  static final _router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Splash Route
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginPage(),
        redirect: (context, state) {
          // Redirect to dashboard if already logged in
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            return '/dashboard';
          }
          return null;
        },
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterPage(),
        redirect: (context, state) {
          final authState = context.read<AuthCubit>().state;
          if (authState is Authenticated) {
            return '/dashboard';
          }
          return null;
        },
      ),

      // Shell Route for pages with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(
          currentTab: _getCurrentTab(state.uri.path),
          onTabChanged: (tab) => _onTabChanged(context, tab),
          body: child,
        ),
        routes: [
          // Dashboard
          GoRoute(
            path: '/dashboard',
            name: 'dashboard',
            builder: (context, state) {
              final authState = context.read<AuthCubit>().state;
              final user = authState is Authenticated ? authState.user : null;
              if (user?.peran == Peran.admin) {
                return const AdminDashboardPage();
              }
              if (user?.peran == Peran.helpdesk) {
                return const HelpdeskDashboardPage();
              }
              return const DashboardPage();
            },
          ),

          // Helpdesk Dashboard (Helpdesk only)
          GoRoute(
            path: '/helpdesk/dashboard',
            name: 'helpdesk-dashboard',
            redirect: (context, state) async {
              final authState = context.read<AuthCubit>().state;
              final user = authState is Authenticated ? authState.user : null;
              if (user?.peran != Peran.helpdesk) {
                return '/dashboard';
              }
              return null;
            },
            builder: (context, state) => const HelpdeskDashboardPage(),
          ),

          // Admin Dashboard (Admin only)
          GoRoute(
            path: '/admin/dashboard',
            name: 'admin-dashboard',
            redirect: (context, state) async {
              final authState = context.read<AuthCubit>().state;
              final user = authState is Authenticated ? authState.user : null;
              if (user?.peran != Peran.admin) {
                return '/dashboard';
              }
              return null;
            },
            builder: (context, state) => const AdminDashboardPage(),
          ),

          // Tiket Routes
          GoRoute(
            path: '/tiket',
            name: 'tiket-list',
            builder: (context, state) => const TiketListPage(),
            routes: [
              GoRoute(
                path: 'create',
                name: 'tiket-create',
                builder: (context, state) => const CreateTiketPage(),
              ),
              GoRoute(
                path: ':id',
                name: 'tiket-detail',
                builder: (context, state) {
                  final tiketId = state.pathParameters['id']!;
                  return TiketDetailPage(tiketId: tiketId);
                },
              ),
              // Staff-only route for managing all tikets
              GoRoute(
                path: 'admin',
                name: 'tiket-admin',
                redirect: (context, state) async {
                  // Only staff can access admin routes
                  if (!await _isStaff()) {
                    return '/tiket';
                  }
                  return null;
                },
                builder: (context, state) => const TiketListPage(),
              ),
            ],
          ),

          // Notifikasi
          GoRoute(
            path: '/notifikasi',
            name: 'notifikasi',
            builder: (context, state) => const NotifikasiListPage(),
          ),

          // Profil
          GoRoute(
            path: '/profil',
            name: 'profil',
            builder: (context, state) => const ProfilPage(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Try to read auth state from AuthCubit
      final authCubit = context.read<AuthCubit>();
      final isAuthenticated = authCubit.state is Authenticated;
      final currentAuthState = authCubit.state;

      final isLoggingIn = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/';

      debugPrint('[Router] Redirect check: location=${state.matchedLocation}, isAuthenticated=$isAuthenticated, authState=$currentAuthState');

      // Redirect to login if not authenticated and not on auth routes
      if (!isAuthenticated && !isLoggingIn) {
        debugPrint('[Router] Redirecting to /login');
        return '/login';
      }

      return null;
    },
  );

  static NavTab _getCurrentTab(String path) {
    if (path.startsWith('/dashboard')) return NavTab.dashboard;
    if (path.startsWith('/tiket')) return NavTab.tiket;
    if (path.startsWith('/notifikasi')) return NavTab.notifikasi;
    if (path.startsWith('/profil')) return NavTab.profil;
    return NavTab.dashboard;
  }

  static void _onTabChanged(BuildContext context, NavTab tab) {
    switch (tab) {
      case NavTab.dashboard:
        context.go('/dashboard');
        break;
      case NavTab.tiket:
        context.go('/tiket');
        break;
      case NavTab.notifikasi:
        context.go('/notifikasi');
        break;
      case NavTab.profil:
        context.go('/profil');
        break;
    }
  }
}

/// Navigation helpers extension
extension GoRouterExtension on BuildContext {
  void goToDashboard() => go('/dashboard');
  void goToLogin() => go('/login');
  void goToRegister() => go('/register');
  void goToTiketList() => go('/tiket');
  void goToTiketDetail(String id) => go('/tiket/$id');
  void goToCreateTiket() => push('/tiket/create');
  void goToNotifikasi() => go('/notifikasi');
  void goToProfil() => go('/profil');
}
