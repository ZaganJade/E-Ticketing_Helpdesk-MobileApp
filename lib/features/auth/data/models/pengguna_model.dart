import '../../domain/entities/pengguna.dart';

/// Data model for Pengguna (User) from Supabase
class PenggunaModel extends Pengguna {
  const PenggunaModel({
    required super.id,
    required super.nama,
    required super.email,
    required super.peran,
    required super.dibuatPada,
    super.fotoProfil,
  });

  /// Create PenggunaModel from JSON (handles both Indonesian and English field names)
  factory PenggunaModel.fromJson(Map<String, dynamic> json) {
    // Handle field name variations (Indonesian vs English)
    final nama = json['nama']?.toString() ??
        json['name']?.toString() ??
        json['full_name']?.toString() ??
        '';

    final peranStr = json['peran']?.toString() ??
        json['role']?.toString() ??
        'pengguna';

    final dibuatPadaStr = json['dibuat_pada']?.toString() ??
        json['created_at']?.toString() ??
        json['dibuat']?.toString();

    final fotoProfil = json['foto_profil']?.toString();

    return PenggunaModel(
      id: json['id']?.toString() ?? '',
      nama: nama,
      email: json['email']?.toString() ?? '',
      peran: Peran.fromString(peranStr),
      dibuatPada: dibuatPadaStr != null
          ? DateTime.tryParse(dibuatPadaStr) ?? DateTime.now()
          : DateTime.now(),
      fotoProfil: fotoProfil,
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'peran': peran.name,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'foto_profil': fotoProfil,
    };
  }

  /// Create from Supabase Auth user metadata
  factory PenggunaModel.fromSupabaseAuth(
    String userId,
    String email,
    Map<String, dynamic> userMetadata,
  ) {
    return PenggunaModel(
      id: userId,
      nama: userMetadata['nama'] as String? ?? '',
      email: email,
      peran: Peran.fromString(userMetadata['peran'] as String? ?? 'pengguna'),
      dibuatPada: DateTime.now(),
      fotoProfil: userMetadata['foto_profil'] as String?,
    );
  }

  /// Create a copy with modified fields
  @override
  PenggunaModel copyWith({
    String? id,
    String? nama,
    String? email,
    Peran? peran,
    DateTime? dibuatPada,
    String? fotoProfil,
  }) {
    return PenggunaModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      peran: peran ?? this.peran,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }
}
