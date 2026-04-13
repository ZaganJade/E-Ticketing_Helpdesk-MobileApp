import 'package:equatable/equatable.dart';

enum StatusTiket {
  terbuka,
  diproses,
  selesai;

  String get displayName {
    switch (this) {
      case StatusTiket.terbuka:
        return 'Terbuka';
      case StatusTiket.diproses:
        return 'Diproses';
      case StatusTiket.selesai:
        return 'Selesai';
    }
  }

  static StatusTiket fromString(String value) {
    switch (value.toUpperCase()) {
      case 'TERBUKA':
        return StatusTiket.terbuka;
      case 'DIPROSES':
        return StatusTiket.diproses;
      case 'SELESAI':
        return StatusTiket.selesai;
      default:
        return StatusTiket.terbuka;
    }
  }
}

class Tiket extends Equatable {
  final String id;
  final String judul;
  final String deskripsi;
  final StatusTiket status;
  final String dibuatOleh;
  final String? namaPembuat;
  final String? ditugaskanKepada;
  final String? namaPenanggungJawab;
  final DateTime dibuatPada;
  final DateTime? diperbaruiPada;

  const Tiket({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.dibuatOleh,
    this.namaPembuat,
    this.ditugaskanKepada,
    this.namaPenanggungJawab,
    required this.dibuatPada,
    this.diperbaruiPada,
  });

  @override
  List<Object?> get props => [
        id,
        judul,
        deskripsi,
        status,
        dibuatOleh,
        namaPembuat,
        ditugaskanKepada,
        namaPenanggungJawab,
        dibuatPada,
        diperbaruiPada,
      ];

  Tiket copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    StatusTiket? status,
    String? dibuatOleh,
    String? namaPembuat,
    String? ditugaskanKepada,
    String? namaPenanggungJawab,
    DateTime? dibuatPada,
    DateTime? diperbaruiPada,
  }) {
    return Tiket(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      dibuatOleh: dibuatOleh ?? this.dibuatOleh,
      namaPembuat: namaPembuat ?? this.namaPembuat,
      ditugaskanKepada: ditugaskanKepada ?? this.ditugaskanKepada,
      namaPenanggungJawab: namaPenanggungJawab ?? this.namaPenanggungJawab,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }
}
