import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/domain/entities/pengguna.dart';

/// Role-based access control utilities
class RoleUtils {
  /// Get current user role from Supabase
  static Future<Peran?> getCurrentUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return null;

    try {
      final response = await Supabase.instance.client
          .from('pengguna')
          .select('peran')
          .eq('id', user.id)
          .single();

      return Peran.fromString(response['peran'] as String);
    } catch (e) {
      return null;
    }
  }

  /// Check if current user has specific role
  static Future<bool> hasRole(Peran role) async {
    final userRole = await getCurrentUserRole();
    return userRole == role;
  }

  /// Check if current user is admin
  static Future<bool> isAdmin() async {
    return hasRole(Peran.admin);
  }

  /// Check if current user is helpdesk
  static Future<bool> isHelpdesk() async {
    return hasRole(Peran.helpdesk);
  }

  /// Check if current user is helpdesk or admin
  static Future<bool> isStaff() async {
    final userRole = await getCurrentUserRole();
    return userRole == Peran.helpdesk || userRole == Peran.admin;
  }

  /// Check if user can access helpdesk features
  static Future<bool> canAccessHelpdeskFeatures() async {
    return isStaff();
  }

  /// Check if user can assign tiket
  static Future<bool> canAssignTiket() async {
    return isStaff();
  }

  /// Check if user can change tiket status
  static Future<bool> canChangeTiketStatus() async {
    return isStaff();
  }

  /// Check if user can delete lampiran (only admin or tiket creator)
  static Future<bool> canDeleteLampiran(String tiketCreatorId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    // Admin can always delete
    if (await isAdmin()) return true;

    // Creator can delete
    return user.id == tiketCreatorId;
  }

  /// Check if user can edit tiket (only creator when status is TERBUKA)
  static Future<bool> canEditTiket(String tiketCreatorId, String status) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return false;

    // Admin and helpdesk can edit anytime
    if (await isStaff()) return true;

    // Creator can edit only when status is TERBUKA
    return user.id == tiketCreatorId && status == 'TERBUKA';
  }

  /// Route guard for staff-only routes
  static Future<String?> staffRouteGuard(BuildContext context) async {
    if (!await isStaff()) {
      return '/dashboard'; // Redirect to dashboard if not staff
    }
    return null; // Allow access
  }

  /// Route guard for admin-only routes
  static Future<String?> adminRouteGuard(BuildContext context) async {
    if (!await isAdmin()) {
      return '/dashboard'; // Redirect to dashboard if not admin
    }
    return null; // Allow access
  }

  /// Show access denied dialog
  static void showAccessDenied(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Akses Ditolak'),
        content: const Text('Anda tidak memiliki izin untuk mengakses fitur ini.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Get role display name
  static String getRoleDisplayName(Peran role) {
    switch (role) {
      case Peran.admin:
        return 'Admin';
      case Peran.helpdesk:
        return 'Helpdesk';
      case Peran.pengguna:
        return 'Pengguna';
    }
  }

  /// Get role color
  static Color getRoleColor(Peran role) {
    switch (role) {
      case Peran.admin:
        return Colors.red;
      case Peran.helpdesk:
        return Colors.blue;
      case Peran.pengguna:
        return Colors.grey;
    }
  }
}

/// Extension untuk BuildContext role checking
extension RoleContextExtension on BuildContext {
  Future<bool> get isAdmin async => await RoleUtils.isAdmin();
  Future<bool> get isHelpdesk async => await RoleUtils.isHelpdesk();
  Future<bool> get isStaff async => await RoleUtils.isStaff();
}
