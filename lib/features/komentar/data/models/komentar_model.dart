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

  /// Create KomentarModel from Supabase JSON
  /// Expects joined data with pengguna information
  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    // Handle nested pengguna object from join
    final penggunaData = json['pengguna'] as Map<String, dynamic>?;

    return KomentarModel(
      id: json['id'] as String,
      tiketId: json['tiket_id'] as String,
      penulisId: json['penulis_id'] as String,
      namaPenulis: penggunaData?['nama'] as String? ?? 'Unknown',
      peranPenulis: Peran.fromString(penggunaData?['peran'] as String? ?? 'pengguna'),
      isiPesan: json['isi_pesan'] as String,
      dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
    );
  }

  /// Create from Supabase realtime payload
  factory KomentarModel.fromRealtimePayload(
    Map<String, dynamic> payload,
    Map<String, dynamic>? penggunaData,
  ) {
    return KomentarModel(
      id: payload['id'] as String,
      tiketId: payload['tiket_id'] as String,
      penulisId: payload['penulis_id'] as String,
      namaPenulis: penggunaData?['nama'] as String? ?? 'Unknown',
      peranPenulis: Peran.fromString(penggunaData?['peran'] as String? ?? 'pengguna'),
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
