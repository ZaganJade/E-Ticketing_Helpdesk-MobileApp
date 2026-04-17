import '../../../../core/services/date_service.dart';

class TiketModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String status;
  final String dibuatOleh;
  final String? ditugaskanKepada;
  final DateTime dibuatPada;
  final String? pembuatNama;
  final String? penanggungJawabNama;

  TiketModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.dibuatOleh,
    this.ditugaskanKepada,
    required this.dibuatPada,
    this.pembuatNama,
    this.penanggungJawabNama,
  });

  factory TiketModel.fromJson(Map<String, dynamic> json) {
    final pengguna = json['pengguna'] as Map<String, dynamic>?;
    final penanggungJawab = json['penanggung_jawab'] as Map<String, dynamic>?;
    final dateTime = DateTime.parse(json['dibuat_pada'] as String);

    return TiketModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String,
      status: json['status'] as String,
      dibuatOleh: json['dibuat_oleh'] as String,
      ditugaskanKepada: json['ditugaskan_kepada'] as String?,
      dibuatPada: dateTime, // Store as-is, will be converted to Jakarta time when displayed
      pembuatNama: pengguna?['nama'] as String?,
      penanggungJawabNama: penanggungJawab?['nama'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': status,
      'dibuat_oleh': dibuatOleh,
      'ditugaskan_kepada': ditugaskanKepada,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'pembuat_nama': pembuatNama,
      'penanggung_jawab_nama': penanggungJawabNama,
    };
  }

  TiketModel copyWith({
    String? id,
    String? judul,
    String? deskripsi,
    String? status,
    String? dibuatOleh,
    String? ditugaskanKepada,
    DateTime? dibuatPada,
    String? pembuatNama,
    String? penanggungJawabNama,
  }) {
    return TiketModel(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      dibuatOleh: dibuatOleh ?? this.dibuatOleh,
      ditugaskanKepada: ditugaskanKepada ?? this.ditugaskanKepada,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      pembuatNama: pembuatNama ?? this.pembuatNama,
      penanggungJawabNama: penanggungJawabNama ?? this.penanggungJawabNama,
    );
  }

  String get statusLabel {
    switch (status.toUpperCase()) {
      case 'TERBUKA':
        return 'Terbuka';
      case 'DIPROSES':
        return 'Diproses';
      case 'SELESAI':
        return 'Selesai';
      default:
        return status;
    }
  }

  bool get isTerbuka => status.toUpperCase() == 'TERBUKA';
  bool get isDiproses => status.toUpperCase() == 'DIPROSES';
  bool get isSelesai => status.toUpperCase() == 'SELESAI';
}
