import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/lampiran_model.dart';
import '../repositories/lampiran_repository.dart';

// States
abstract class LampiranState {}

class LampiranInitial extends LampiranState {}

class LampiranLoading extends LampiranState {}

class LampiranListLoaded extends LampiranState {
  final List<LampiranModel> lampiranList;

  LampiranListLoaded({required this.lampiranList});
}

class LampiranUploading extends LampiranState {
  final double progress;

  LampiranUploading({required this.progress});
}

class LampiranUploaded extends LampiranState {
  final LampiranModel lampiran;

  LampiranUploaded({required this.lampiran});
}

class LampiranDeleted extends LampiranState {
  final String lampiranId;

  LampiranDeleted({required this.lampiranId});
}

class LampiranError extends LampiranState {
  final String message;

  LampiranError({required this.message});
}

// Cubit
class LampiranCubit extends Cubit<LampiranState> {
  final LampiranRepository _repository = LampiranRepository();

  LampiranCubit() : super(LampiranInitial());

  // Load lampiran by tiket ID
  Future<void> loadLampiran(String tiketId) async {
    emit(LampiranLoading());

    try {
      final lampiranList = await _repository.getLampiranByTiket(tiketId);
      emit(LampiranListLoaded(lampiranList: lampiranList));
    } catch (e) {
      emit(LampiranError(message: e.toString()));
    }
  }

  // Upload lampiran
  Future<void> uploadLampiran({
    required String tiketId,
    required File file,
    required String fileName,
  }) async {
    // Validate file first
    final fileSize = await file.length();
    if (!_repository.isValidFileType(fileName)) {
      emit(LampiranError(
        message: 'Format file tidak diizinkan. Format yang diizinkan: jpg, png, pdf, doc, docx',
      ));
      return;
    }
    if (!_repository.isValidFileSize(fileSize)) {
      emit(LampiranError(
        message: 'Ukuran file maksimal 10MB',
      ));
      return;
    }

    emit(LampiranUploading(progress: 0));

    try {
      final lampiran = await _repository.uploadLampiran(
        tiketId: tiketId,
        file: file,
        fileName: fileName,
        onProgress: (progress) {
          emit(LampiranUploading(progress: progress));
        },
      );

      emit(LampiranUploaded(lampiran: lampiran));

      // Reload list
      await loadLampiran(tiketId);
    } catch (e) {
      emit(LampiranError(message: e.toString()));
    }
  }

  // Delete lampiran
  Future<void> deleteLampiran(String lampiranId, String tiketId) async {
    try {
      await _repository.deleteLampiran(tiketId, lampiranId);
      emit(LampiranDeleted(lampiranId: lampiranId));

      // Reload list
      await loadLampiran(tiketId);
    } catch (e) {
      emit(LampiranError(message: e.toString()));
    }
  }

  // Validate file before upload
  String? validateFile(String fileName, int fileSize) {
    if (!_repository.isValidFileType(fileName)) {
      return 'Format file tidak diizinkan. Format yang diizinkan: jpg, png, pdf, doc, docx';
    }
    if (!_repository.isValidFileSize(fileSize)) {
      return 'Ukuran file maksimal 10MB';
    }
    return null;
  }
}
