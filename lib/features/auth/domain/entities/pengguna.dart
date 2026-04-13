import 'package:equatable/equatable.dart';

/// Entity representing a user (Pengguna) in the domain layer
class Pengguna extends Equatable {
  final String id;
  final String nama;
  final String email;
  final Peran peran;
  final DateTime dibuatPada;

  const Pengguna({
    required this.id,
    required this.nama,
    required this.email,
    required this.peran,
    required this.dibuatPada,
  });

  @override
  List<Object?> get props => [id, nama, email, peran, dibuatPada];

  /// Create a copy of this Pengguna with modified fields
  Pengguna copyWith({
    String? id,
    String? nama,
    String? email,
    Peran? peran,
    DateTime? dibuatPada,
  }) {
    return Pengguna(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      peran: peran ?? this.peran,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
}

/// User roles in the system
enum Peran {
  pengguna,
  helpdesk,
  admin;

  String get displayName {
    switch (this) {
      case Peran.pengguna:
        return 'Pengguna';
      case Peran.helpdesk:
        return 'Helpdesk';
      case Peran.admin:
        return 'Admin';
    }
  }

  static Peran fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pengguna':
        return Peran.pengguna;
      case 'helpdesk':
        return Peran.helpdesk;
      case 'admin':
        return Peran.admin;
      default:
        return Peran.pengguna;
    }
  }
}
