import 'package:equatable/equatable.dart';

/// Helpdesk with busy/free status from GET /helpdesks
class HelpdeskAvailability extends Equatable {
  final String id;
  final String nama;
  final String email;
  final bool sibuk;

  const HelpdeskAvailability({
    required this.id,
    required this.nama,
    required this.email,
    required this.sibuk,
  });

  factory HelpdeskAvailability.fromJson(Map<String, dynamic> json) {
    return HelpdeskAvailability(
      id: json['id']?.toString() ?? '',
      nama: json['nama'] as String? ?? '',
      email: json['email'] as String? ?? '',
      sibuk: json['sibuk'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [id, nama, email, sibuk];
}
