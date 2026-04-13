import 'package:equatable/equatable.dart';

/// Entity representing ticket statistics by status
class TiketStatusStats extends Equatable {
  final int terbuka;
  final int diproses;
  final int selesai;

  const TiketStatusStats({
    required this.terbuka,
    required this.diproses,
    required this.selesai,
  });

  int get total => terbuka + diproses + selesai;

  double get terbukaPercentage => total > 0 ? terbuka / total : 0;
  double get diprosesPercentage => total > 0 ? diproses / total : 0;
  double get selesaiPercentage => total > 0 ? selesai / total : 0;

  @override
  List<Object?> get props => [terbuka, diproses, selesai];

  TiketStatusStats copyWith({
    int? terbuka,
    int? diproses,
    int? selesai,
  }) {
    return TiketStatusStats(
      terbuka: terbuka ?? this.terbuka,
      diproses: diproses ?? this.diproses,
      selesai: selesai ?? this.selesai,
    );
  }
}
