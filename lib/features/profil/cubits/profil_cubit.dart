import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logger/logger.dart';
import '../models/profil_model.dart';
import '../repositories/profil_repository.dart';

// States
abstract class ProfilState {}

class ProfilInitial extends ProfilState {}

class ProfilLoading extends ProfilState {}

class ProfilLoaded extends ProfilState {
  final ProfilModel profil;

  ProfilLoaded({required this.profil});
}

class ProfilUpdated extends ProfilState {
  final ProfilModel profil;

  ProfilUpdated({required this.profil});
}

class PasswordUpdated extends ProfilState {}

class LoggedOut extends ProfilState {}

class ProfilError extends ProfilState {
  final String message;

  ProfilError({required this.message});
}

// Cubit
class ProfilCubit extends Cubit<ProfilState> {
  final ProfilRepository _repository = ProfilRepository();
  final Logger _logger = Logger();

  ProfilCubit() : super(ProfilInitial());

  // Load profil
  Future<void> loadProfil() async {
    _logger.i('[ProfilCubit] loadProfil called');
    emit(ProfilLoading());

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
    emit(ProfilLoading());

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
    emit(ProfilLoading());

    try {
      await _repository.updatePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      emit(PasswordUpdated());
    } catch (e) {
      emit(ProfilError(message: e.toString()));
    }
  }

  // Logout
  Future<void> logout() async {
    emit(ProfilLoading());

    try {
      await _repository.logout();
      emit(LoggedOut());
    } catch (e) {
      emit(ProfilError(message: e.toString()));
    }
  }
}
