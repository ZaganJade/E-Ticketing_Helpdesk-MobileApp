import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import '../models/profil_model.dart';
import '../repositories/profil_repository.dart';

// States
abstract class ProfilState extends Equatable {
  const ProfilState();

  @override
  List<Object?> get props => [];
}

class ProfilInitial extends ProfilState {
  const ProfilInitial();
}

class ProfilLoading extends ProfilState {
  const ProfilLoading();
}

class ProfilLoaded extends ProfilState {
  final ProfilModel profil;

  const ProfilLoaded({required this.profil});

  @override
  List<Object?> get props => [profil];
}

class ProfilUpdated extends ProfilState {
  final ProfilModel profil;

  const ProfilUpdated({required this.profil});

  @override
  List<Object?> get props => [profil];
}

class PasswordUpdated extends ProfilState {
  const PasswordUpdated();
}

class LoggedOut extends ProfilState {
  const LoggedOut();
}

class ProfilError extends ProfilState {
  final String message;

  const ProfilError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Cubit
class ProfilCubit extends Cubit<ProfilState> {
  final ProfilRepository _repository = ProfilRepository();
  final Logger _logger = Logger();

  ProfilCubit() : super(const ProfilInitial());

  // Load profil
  Future<void> loadProfil() async {
    _logger.i('[ProfilCubit] loadProfil called');
    emit(const ProfilLoading());

    try {
      final profil = await _repository.getProfil();
      _logger.i('[ProfilCubit] Profil loaded: ${profil.nama}');
      emit(ProfilLoaded(profil: profil));
    } catch (e) {
      _logger.e('[ProfilCubit] Error loading profil: $e');
      emit(ProfilError(message: e.toString()));
    }
  }

  // Update nama
  Future<void> updateNama(String nama) async {
    emit(const ProfilLoading());

    try {
      final profil = await _repository.updateNama(nama);
      emit(ProfilUpdated(profil: profil));
    } catch (e) {
      emit(ProfilError(message: e.toString()));
    }
  }

  // Update password
  Future<void> updatePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    emit(const ProfilLoading());

    try {
      await _repository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      emit(const PasswordUpdated());
    } catch (e) {
      emit(ProfilError(message: e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(const ProfilLoading());

    try {
      await _repository.logout();
      emit(const LoggedOut());
    } catch (e) {
      emit(ProfilError(message: e.toString()));
    }
  }
}
