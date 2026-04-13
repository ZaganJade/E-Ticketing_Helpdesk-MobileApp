import '../../domain/entities/tiket.dart';

class TiketModel extends Tiket {
  const TiketModel({
    required super.id,
    required super.judul,
    required super.deskripsi,
    required super.status,
    required super.dibuatOleh,
    super.namaPembuat,
    super.ditugaskanKepada,
    super.namaPenanggungJawab,
    required super.dibuatPada,
    super.diperbaruiPada,
  });

  factory TiketModel.fromJson(Map<String, dynamic> json) {
    final penggunaData = json['pengguna'] as Map<String, dynamic>?;
    final penanggungJawabData = json['penanggung_jawab'] as Map<String, dynamic>?;

    return TiketModel(
      id: json['id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String,
      status: StatusTiket.fromString(json['status'] as String),
      dibuatOleh: json['dibuat_oleh'] as String,
      namaPembuat: penggunaData?['nama'] as String?,
      ditugaskanKepada: json['ditugaskan_kepada'] as String?,
      namaPenanggungJawab: penanggungJawabData?['nama'] as String?,
      dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
      diperbaruiPada: json['diperbarui_pada'] != null
          ? DateTime.parse(json['diperbarui_pada'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': status.name.toUpperCase(),
      'dibuat_oleh': dibuatOleh,
      'ditugaskan_kepada': ditugaskanKepada,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'diperbarui_pada': diperbaruiPada?.toIso8601String(),
    };
  }

  TiketModel copyWithModel({
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
    return TiketModel(
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
