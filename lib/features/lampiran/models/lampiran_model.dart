import 'package:flutter/material.dart';

class LampiranModel {
  final String id;
  final String tiketId;
  final String namaFile;
  final String pathFile;
  final int ukuran;
  final String tipeFile;
  final DateTime dibuatPada;

  LampiranModel({
    required this.id,
    required this.tiketId,
    required this.namaFile,
    required this.pathFile,
    required this.ukuran,
    required this.tipeFile,
    required this.dibuatPada,
  });

  factory LampiranModel.fromJson(Map<String, dynamic> json) {
    return LampiranModel(
      id: json['id'] as String,
      tiketId: json['tiket_id'] as String,
      namaFile: json['nama_file'] as String,
      pathFile: json['path_file'] as String,
      ukuran: json['ukuran'] as int,
      tipeFile: json['tipe_file'] as String,
      dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tiket_id': tiketId,
      'nama_file': namaFile,
      'path_file': pathFile,
      'ukuran': ukuran,
      'tipe_file': tipeFile,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }

  bool get isImage {
    final ext = tipeFile.toLowerCase();
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'gif' || ext == 'webp';
  }

  bool get isPdf {
    return tipeFile.toLowerCase() == 'pdf';
  }

  bool get isDoc {
    final ext = tipeFile.toLowerCase();
    return ext == 'doc' || ext == 'docx';
  }

  String get formattedSize {
    if (ukuran < 1024) {
      return '$ukuran B';
    } else if (ukuran < 1024 * 1024) {
      return '${(ukuran / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(ukuran / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  IconData get iconData {
    if (isImage) return Icons.image;
    if (isPdf) return Icons.picture_as_pdf;
    if (isDoc) return Icons.description;
    return Icons.insert_drive_file;
  }

  String get fullUrl {
    // This would be constructed from Supabase Storage URL
    return pathFile;
  }
}
