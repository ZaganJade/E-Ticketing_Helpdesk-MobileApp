import 'package:equatable/equatable.dart';

/// User statistics breakdown by role
class UserStatsByRole extends Equatable {
  final int pengguna;
  final int helpdesk;
  final int admin;

  const UserStatsByRole({
    required this.pengguna,
    required this.helpdesk,
    required this.admin,
  });

  @override
  List<Object?> get props => [pengguna, helpdesk, admin];

  int get total => pengguna + helpdesk + admin;
}

/// Helpdesk performance metrics
class HelpdeskPerformance extends Equatable {
  final String helpdeskId;
  final String helpdeskNama;
  final int totalTiketDitugaskan;
  final int tiketSelesai;
  final double rataRataPenyelesaianJam;
  final double persentasePenyelesaian;

  const HelpdeskPerformance({
    required this.helpdeskId,
    required this.helpdeskNama,
    required this.totalTiketDitugaskan,
    required this.tiketSelesai,
    required this.rataRataPenyelesaianJam,
    required this.persentasePenyelesaian,
  });

  @override
  List<Object?> get props => [
        helpdeskId,
        helpdeskNama,
        totalTiketDitugaskan,
        tiketSelesai,
        rataRataPenyelesaianJam,
        persentasePenyelesaian,
      ];

  HelpdeskPerformance copyWith({
    String? helpdeskId,
    String? helpdeskNama,
    int? totalTiketDitugaskan,
    int? tiketSelesai,
    double? rataRataPenyelesaianJam,
    double? persentasePenyelesaian,
  }) {
    return HelpdeskPerformance(
      helpdeskId: helpdeskId ?? this.helpdeskId,
      helpdeskNama: helpdeskNama ?? this.helpdeskNama,
      totalTiketDitugaskan:
          totalTiketDitugaskan ?? this.totalTiketDitugaskan,
      tiketSelesai: tiketSelesai ?? this.tiketSelesai,
      rataRataPenyelesaianJam:
          rataRataPenyelesaianJam ?? this.rataRataPenyelesaianJam,
      persentasePenyelesaian:
          persentasePenyelesaian ?? this.persentasePenyelesaian,
    );
  }
}

/// Overall admin dashboard statistics
class AdminDashboardStats extends Equatable {
  final UserStatsByRole userStats;
  final List<HelpdeskPerformance> helpdeskPerformances;
  final int totalTiket;
  final int tiketTerbuka;
  final int tiketDiproses;
  final int tiketSelesai;

  const AdminDashboardStats({
    required this.userStats,
    required this.helpdeskPerformances,
    required this.totalTiket,
    required this.tiketTerbuka,
    required this.tiketDiproses,
    required this.tiketSelesai,
  });

  @override
  List<Object?> get props => [
        userStats,
        helpdeskPerformances,
        totalTiket,
        tiketTerbuka,
        tiketDiproses,
        tiketSelesai,
      ];

  /// Calculate completion percentage
  double get persentasePenyelesaian {
    if (totalTiket == 0) return 0.0;
    return (tiketSelesai / totalTiket) * 100;
  }

  /// Get top performing helpdesk
  HelpdeskPerformance? get topHelpdesk {
    if (helpdeskPerformances.isEmpty) return null;
    return helpdeskPerformances.reduce(
      (a, b) => a.persentasePenyelesaian >= b.persentasePenyelesaian ? a : b,
    );
  }

  AdminDashboardStats copyWith({
    UserStatsByRole? userStats,
    List<HelpdeskPerformance>? helpdeskPerformances,
    int? totalTiket,
    int? tiketTerbuka,
    int? tiketDiproses,
    int? tiketSelesai,
  }) {
    return AdminDashboardStats(
      userStats: userStats ?? this.userStats,
      helpdeskPerformances:
          helpdeskPerformances ?? this.helpdeskPerformances,
      totalTiket: totalTiket ?? this.totalTiket,
      tiketTerbuka: tiketTerbuka ?? this.tiketTerbuka,
      tiketDiproses: tiketDiproses ?? this.tiketDiproses,
      tiketSelesai: tiketSelesai ?? this.tiketSelesai,
    );
  }
}
