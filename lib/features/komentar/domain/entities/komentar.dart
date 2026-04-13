import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/pengguna.dart';

/// Entity representing a comment (Komentar) in the domain layer
class Komentar extends Equatable {
  final String id;
  final String tiketId;
  final String penulisId;
  final String namaPenulis;
  final Peran peranPenulis;
  final String isiPesan;
  final DateTime dibuatPada;

  const Komentar({
    required this.id,
    required this.tiketId,
    required this.penulisId,
    required this.namaPenulis,
    required this.peranPenulis,
    required this.isiPesan,
    required this.dibuatPada,
  });

  @override
  List<Object?> get props => [
        id,
        tiketId,
        penulisId,
        namaPenulis,
        peranPenulis,
        isiPesan,
        dibuatPada,
      ];

  /// Create a copy of this Komentar with modified fields
  Komentar copyWith({
    String? id,
    String? tiketId,
    String? penulisId,
    String? namaPenulis,
    Peran? peranPenulis,
    String? isiPesan,
    DateTime? dibuatPada,
  }) {
    return Komentar(
      id: id ?? this.id,
      tiketId: tiketId ?? this.tiketId,
      penulisId: penulisId ?? this.penulisId,
      namaPenulis: namaPenulis ?? this.namaPenulis,
      peranPenulis: peranPenulis ?? this.peranPenulis,
      isiPesan: isiPesan ?? this.isiPesan,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }

  /// Get badge text based on writer's role
  String get badgeText => peranPenulis.displayName;

  /// Check if this komentar is from helpdesk or admin
  bool get isFromStaff =>
      peranPenulis == Peran.helpdesk || peranPenulis == Peran.admin;

  /// Check if this komentar is from ticket creator (regular user)
  bool get isFromPengguna => peranPenulis == Peran.pengguna;
}
