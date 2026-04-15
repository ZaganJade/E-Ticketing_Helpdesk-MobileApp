import 'package:flutter/material.dart';
import '../../../core/config/app_config.dart';

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
    final ext = tipeFile.toLowerCase().replaceAll('.', ''); // Remove dot if present
    // Handle both file extensions and MIME types
    return ext == 'jpg' || ext == 'jpeg' || ext == 'png' || ext == 'gif' || ext == 'webp' ||
           ext.startsWith('image/');
  }

  bool get isPdf {
    final ext = tipeFile.toLowerCase().replaceAll('.', '');
    return ext == 'pdf' || tipeFile.toLowerCase() == 'application/pdf';
  }

  bool get isDoc {
    final ext = tipeFile.toLowerCase().replaceAll('.', '');
    final mime = tipeFile.toLowerCase();
    return ext == 'doc' || ext == 'docx' ||
           mime.startsWith('application/msword') ||
           mime.startsWith('application/vnd.openxmlformats-officedocument.wordprocessingml');
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
    // If pathFile is already a full URL, return it as is
    if (pathFile.startsWith('http://') || pathFile.startsWith('https://')) {
      return pathFile;
    }
    // Construct Supabase Storage URL for attachments
    // Format: https://<supabase-url>/storage/v1/object/public/<bucket>/<path>
    final supabaseUrl = AppConfig().supabaseUrl;
    final bucketName = 'Lampiran E-Ticket'; // Bucket name from your Supabase (with space)
    // URL encode the bucket name to handle spaces
    final encodedBucketName = Uri.encodeComponent(bucketName);
    // Remove trailing slash from supabaseUrl
    final cleanBaseUrl = supabaseUrl.endsWith('/') ? supabaseUrl.substring(0, supabaseUrl.length - 1) : supabaseUrl;
    // Ensure pathFile doesn't start with / to avoid double slashes
    final cleanPath = pathFile.startsWith('/') ? pathFile.substring(1) : pathFile;
    return '$cleanBaseUrl/storage/v1/object/public/$encodedBucketName/$cleanPath';
  }
}
