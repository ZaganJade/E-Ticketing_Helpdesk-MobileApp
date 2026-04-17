import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/date_service.dart';

enum NotifikasiTipe {
  statusChange,
  komentarBaru,
  tiketAssigned,
  tiketSelesai,
}

class NotifikasiModel {
  final String id;
  final String penggunaId;
  final NotifikasiTipe tipe;
  final String? referensiId;
  final String judul;
  final String pesan;
  final bool sudahDibaca;
  final DateTime dibuatPada;

  NotifikasiModel({
    required this.id,
    required this.penggunaId,
    required this.tipe,
    this.referensiId,
    required this.judul,
    required this.pesan,
    required this.sudahDibaca,
    required this.dibuatPada,
  });

  factory NotifikasiModel.fromJson(Map<String, dynamic> json) {
    final dateService = getIt<DateService>();
    return NotifikasiModel(
      id: json['id'] as String,
      penggunaId: json['pengguna_id'] as String,
      tipe: _parseTipe(json['tipe'] as String),
      referensiId: json['referensi_id'] as String?,
      judul: json['judul'] as String,
      pesan: json['pesan'] as String,
      sudahDibaca: json['sudah_dibaca'] as bool,
      dibuatPada: dateService.parseFromDatabase(json['dibuat_pada'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    final dateService = getIt<DateService>();
    return {
      'id': id,
      'pengguna_id': penggunaId,
      'tipe': _tipeToString(tipe),
      'referensi_id': referensiId,
      'judul': judul,
      'pesan': pesan,
      'sudah_dibaca': sudahDibaca,
      'dibuat_pada': dateService.formatForDatabase(dibuatPada),
    };
  }

  NotifikasiModel copyWith({
    String? id,
    String? penggunaId,
    NotifikasiTipe? tipe,
    String? referensiId,
    String? judul,
    String? pesan,
    bool? sudahDibaca,
    DateTime? dibuatPada,
  }) {
    return NotifikasiModel(
      id: id ?? this.id,
      penggunaId: penggunaId ?? this.penggunaId,
      tipe: tipe ?? this.tipe,
      referensiId: referensiId ?? this.referensiId,
      judul: judul ?? this.judul,
      pesan: pesan ?? this.pesan,
      sudahDibaca: sudahDibaca ?? this.sudahDibaca,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }

  static NotifikasiTipe _parseTipe(String tipe) {
    switch (tipe.toUpperCase()) {
      case 'STATUS_CHANGE':
        return NotifikasiTipe.statusChange;
      case 'KOMENTAR_BARU':
        return NotifikasiTipe.komentarBaru;
      case 'TIKET_ASSIGNED':
        return NotifikasiTipe.tiketAssigned;
      case 'TIKET_SELESAI':
        return NotifikasiTipe.tiketSelesai;
      default:
        return NotifikasiTipe.statusChange;
    }
  }

  static String _tipeToString(NotifikasiTipe tipe) {
    switch (tipe) {
      case NotifikasiTipe.statusChange:
        return 'STATUS_CHANGE';
      case NotifikasiTipe.komentarBaru:
        return 'KOMENTAR_BARU';
      case NotifikasiTipe.tiketAssigned:
        return 'TIKET_ASSIGNED';
      case NotifikasiTipe.tiketSelesai:
        return 'TIKET_SELESAI';
    }
  }

  (IconData, Color) getIconConfig() {
    switch (tipe) {
      case NotifikasiTipe.statusChange:
        return (Icons.sync, AppColors.statusDiproses);
      case NotifikasiTipe.komentarBaru:
        return (Icons.chat_bubble, AppColors.primary);
      case NotifikasiTipe.tiketAssigned:
        return (Icons.assignment_ind, AppColors.statusTerbuka);
      case NotifikasiTipe.tiketSelesai:
        return (Icons.check_circle, AppColors.statusSelesai);
    }
  }
}
