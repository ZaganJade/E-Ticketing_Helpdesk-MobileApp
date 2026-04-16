class ProfilModel {
  final String id;
  final String nama;
  final String email;
  final String peran;
  final DateTime dibuatPada;
  final String? fotoProfil;

  ProfilModel({
    required this.id,
    required this.nama,
    required this.email,
    required this.peran,
    required this.dibuatPada,
    this.fotoProfil,
  });

  factory ProfilModel.fromJson(Map<String, dynamic> json) {
    return ProfilModel(
      id: json['id'] as String,
      nama: json['nama'] as String,
      email: json['email'] as String,
      peran: json['peran'] as String,
      dibuatPada: DateTime.parse(json['dibuat_pada'] as String),
      fotoProfil: json['foto_profil'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'email': email,
      'peran': peran,
      'dibuat_pada': dibuatPada.toIso8601String(),
      'foto_profil': fotoProfil,
    };
  }

  ProfilModel copyWith({
    String? id,
    String? nama,
    String? email,
    String? peran,
    DateTime? dibuatPada,
    String? fotoProfil,
  }) {
    return ProfilModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      peran: peran ?? this.peran,
      dibuatPada: dibuatPada ?? this.dibuatPada,
      fotoProfil: fotoProfil ?? this.fotoProfil,
    );
  }

  String get peranLabel {
    switch (peran.toLowerCase()) {
      case 'admin':
        return 'Admin';
      case 'helpdesk':
        return 'Helpdesk';
      case 'pengguna':
      default:
        return 'Pengguna';
    }
  }

  String get inisial {
    if (nama.isEmpty) return '?';
    final parts = nama.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat pagi';
    if (hour < 15) return 'Selamat siang';
    if (hour < 18) return 'Selamat sore';
    return 'Selamat malam';
  }
}
