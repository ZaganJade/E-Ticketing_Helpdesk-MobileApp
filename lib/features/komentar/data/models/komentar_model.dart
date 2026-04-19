import '../../../auth/domain/entities/pengguna.dart';
import '../../domain/entities/komentar.dart';

/// Data model for Komentar from Supabase
class KomentarModel extends Komentar {
  const KomentarModel({
    required super.id,
    required super.tiketId,
    required super.penulisId,
    required super.namaPenulis,
    required super.peranPenulis,
    required super.isiPesan,
    required super.dibuatPada,
  });

  /// Create KomentarModel from Backend API JSON
  /// Backend returns flat fields: penulis_nama, penulis_peran
  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    // Handle null or missing penulis_nama with better fallback
    final penulisNama = json['penulis_nama'] as String?;
    final penulisPeran = json['penulis_peran'] as String?;

    String finalNama = 'Unknown';
    Peran finalPeran = Peran.pengguna;

    if (penulisNama != null && penulisNama.isNotEmpty && penulisNama != 'Unknown') {
      finalNama = penulisNama;
    } else if (json['pengguna'] is Map) {
      // Try to get from nested pengguna object
      final pengguna = json['pengguna'] as Map<String, dynamic>;
      finalNama = pengguna['nama'] as String? ?? 'Unknown';
      finalPeran = Peran.fromString(pengguna['peran'] as String? ?? 'pengguna');
    } else {
      // Use email if available
      finalNama = json['email'] as String? ?? 'Unknown';
    }

    if (penulisPeran != null && penulisPeran.isNotEmpty) {
      try {
        finalPeran = Peran.fromString(penulisPeran);
      } catch (e) {
        // Keep default if parsing fails
      }
    }

    return KomentarModel(
      id: json['id'] as String,
      tiketId: json['tiket_id'] as String,
      penulisId: json['penulis_id'] as String,
      namaPenulis: finalNama,
      peranPenulis: finalPeran,
      isiPesan: json['isi_pesan'] as String,
      dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
    );
  }

  /// Create from Backend API response (same as fromJson for backend)
  factory KomentarModel.fromRealtimePayload(
    Map<String, dynamic> payload,
    Map<String, dynamic>? penggunaData,
  ) {
    // Backend returns flat fields, ignore penggunaData
    return KomentarModel(
      id: payload['id'] as String,
      tiketId: payload['tiket_id'] as String,
      penulisId: payload['penulis_id'] as String,
      namaPenulis: payload['penulis_nama'] as String? ?? 'Unknown',
      peranPenulis: Peran.fromString(payload['penulis_peran'] as String? ?? 'pengguna'),
      isiPesan: payload['isi_pesan'] as String,
      dibuatPada: DateTime.parse(payload['dibuat_pada'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tiket_id': tiketId,
      'penulis_id': penulisId,
      'isi_pesan': isiPesan,
      'dibuat_pada': dibuatPada.toIso8601String(),
    };
  }

  /// Convert to JSON for insert (without id and timestamp)
  Map<String, dynamic> toInsertJson() {
    return {
      'tiket_id': tiketId,
      'penulis_id': penulisId,
      'isi_pesan': isiPesan,
    };
  }

  /// Create a copy with modified fields
  @override
  KomentarModel copyWith({
    String? id,
    String? tiketId,
    String? penulisId,
    String? namaPenulis,
    Peran? peranPenulis,
    String? isiPesan,
    DateTime? dibuatPada,
  }) {
    return KomentarModel(
      id: id ?? this.id,
      tiketId: tiketId ?? this.tiketId,
      penulisId: penulisId ?? this.penulisId,
      namaPenulis: namaPenulis ?? this.namaPenulis,
      peranPenulis: peranPenulis ?? this.peranPenulis,
      isiPesan: isiPesan ?? this.isiPesan,
      dibuatPada: dibuatPada ?? this.dibuatPada,
    );
  }
}
