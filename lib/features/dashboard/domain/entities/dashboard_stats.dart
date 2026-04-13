import 'package:equatable/equatable.dart';

import '../../../tiket/domain/entities/tiket.dart';
import 'tiket_status_stats.dart';

/// Entity representing overall dashboard statistics
class DashboardStats extends Equatable {
  final int totalTiket;
  final TiketStatusStats statusStats;
  final List<Tiket> tiketTerbaru;
  final int totalPengguna;
  final int totalHelpdesk;
  final int totalAdmin;

  const DashboardStats({
    required this.totalTiket,
    required this.statusStats,
    required this.tiketTerbaru,
    this.totalPengguna = 0,
    this.totalHelpdesk = 0,
    this.totalAdmin = 0,
  });

  @override
  List<Object?> get props => [
        totalTiket,
        statusStats,
        tiketTerbaru,
        totalPengguna,
        totalHelpdesk,
        totalAdmin,
      ];

  DashboardStats copyWith({
    int? totalTiket,
    TiketStatusStats? statusStats,
    List<Tiket>? tiketTerbaru,
    int? totalPengguna,
    int? totalHelpdesk,
    int? totalAdmin,
  }) {
    return DashboardStats(
      totalTiket: totalTiket ?? this.totalTiket,
      statusStats: statusStats ?? this.statusStats,
      tiketTerbaru: tiketTerbaru ?? this.tiketTerbaru,
      totalPengguna: totalPengguna ?? this.totalPengguna,
      totalHelpdesk: totalHelpdesk ?? this.totalHelpdesk,
      totalAdmin: totalAdmin ?? this.totalAdmin,
    );
  }
}
