import 'package:equatable/equatable.dart';

import '../../../tiket/domain/entities/tiket.dart';

/// Helpdesk dashboard statistics entity
class HelpdeskDashboardStats extends Equatable {
  final int totalTiketDitangani;
  final int tiketTerbuka;
  final int tiketSaya;
  final List<Tiket> tiketTerbaru;
  final double rataRataWaktuSelesai;

  const HelpdeskDashboardStats({
    required this.totalTiketDitangani,
    required this.tiketTerbuka,
    required this.tiketSaya,
    required this.tiketTerbaru,
    this.rataRataWaktuSelesai = 0.0,
  });

  @override
  List<Object?> get props => [
        totalTiketDitangani,
        tiketTerbuka,
        tiketSaya,
        tiketTerbaru,
        rataRataWaktuSelesai,
      ];

  HelpdeskDashboardStats copyWith({
    int? totalTiketDitangani,
    int? tiketTerbuka,
    int? tiketSaya,
    List<Tiket>? tiketTerbaru,
    double? rataRataWaktuSelesai,
  }) {
    return HelpdeskDashboardStats(
      totalTiketDitangani: totalTiketDitangani ?? this.totalTiketDitangani,
      tiketTerbuka: tiketTerbuka ?? this.tiketTerbuka,
      tiketSaya: tiketSaya ?? this.tiketSaya,
      tiketTerbaru: tiketTerbaru ?? this.tiketTerbaru,
      rataRataWaktuSelesai: rataRataWaktuSelesai ?? this.rataRataWaktuSelesai,
    );
  }
}
