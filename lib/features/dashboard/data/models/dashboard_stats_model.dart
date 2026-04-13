import '../../../tiket/data/models/tiket_model.dart';
import '../../../tiket/domain/entities/tiket.dart';
import '../../domain/entities/dashboard_stats.dart';
import '../../domain/entities/tiket_status_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.totalTiket,
    required super.statusStats,
    required super.tiketTerbaru,
    super.totalPengguna,
    super.totalHelpdesk,
    super.totalAdmin,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    final statusData = json['status_stats'] as Map<String, dynamic>?;
    final tiketList = (json['tiket_terbaru'] as List<dynamic>? ?? [])
        .map((t) => TiketModel.fromJson(t as Map<String, dynamic>))
        .toList();

    return DashboardStatsModel(
      totalTiket: json['total_tiket'] as int? ?? 0,
      statusStats: TiketStatusStats(
        terbuka: statusData?['terbuka'] as int? ?? 0,
        diproses: statusData?['diproses'] as int? ?? 0,
        selesai: statusData?['selesai'] as int? ?? 0,
      ),
      tiketTerbaru: tiketList,
      totalPengguna: json['total_pengguna'] as int? ?? 0,
      totalHelpdesk: json['total_helpdesk'] as int? ?? 0,
      totalAdmin: json['total_admin'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_tiket': totalTiket,
      'status_stats': {
        'terbuka': statusStats.terbuka,
        'diproses': statusStats.diproses,
        'selesai': statusStats.selesai,
      },
      'tiket_terbaru': tiketTerbaru.map((t) => (t as TiketModel).toJson()).toList(),
      'total_pengguna': totalPengguna,
      'total_helpdesk': totalHelpdesk,
      'total_admin': totalAdmin,
    };
  }
}
