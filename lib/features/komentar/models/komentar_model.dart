class KomentarModel {
  final String id;
  final String tiketId;
  final String penulisId;
  final String isiPesan;
  final DateTime dibuatPada;
  final String? penulisNama;
  final String? penulisPeran;

  KomentarModel({
    required this.id,
    required this.tiketId,
    required this.penulisId,
    required this.isiPesan,
    required this.dibuatPada,
    this.penulisNama,
    this.penulisPeran,
  });

  factory KomentarModel.fromJson(Map<String, dynamic> json) {
    final pengguna = json['pengguna'] as Map<String, dynamic>?;

    return KomentarModel(
      id: json['id'] as String,
      tiketId: json['tiket_id'] as String,
      penulisId: json['penulis_id'] as String,
      isiPesan: json['isi_pesan'] as String,
      dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
      penulisNama: pengguna?['nama'] as String?,
      penulisPeran: pengguna?['peran'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tiket_id': tiketId,
      'penulis_id': penulisId,
      'isi_pesan': isiPesan,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'penulis_nama': penulisNama,
      'penulis_peran': penulisPeran,
    };
  }
}
