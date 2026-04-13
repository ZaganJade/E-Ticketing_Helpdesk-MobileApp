import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import '../models/lampiran_model.dart';

class DownloadHelper {
  final Dio _dio = Dio();

  /// Check storage permission
  static Future<bool> checkStoragePermission() async {
    if (Platform.isAndroid) {
      // For Android 13+ (API 33+), we need different permissions
      final sdkInt = await _getAndroidSdkInt();
      if (sdkInt >= 33) {
        // Android 13+ uses READ_MEDIA_IMAGES, READ_MEDIA_VIDEO, READ_MEDIA_AUDIO
        final photos = await ph.Permission.photos.request();
        return photos.isGranted;
      } else {
        // For older Android
        final storage = await ph.Permission.storage.request();
        return storage.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit permission for app documents
      return true;
    }
    return false;
  }

  static Future<int> _getAndroidSdkInt() async {
    // This would normally use platform channel
    // For now, assume we need to request both
    return 30; // Default to Android 11
  }

  /// Download file with progress
  Future<String> downloadFile(
    LampiranModel lampiran, {
    void Function(int received, int total)? onProgress,
    void Function(String error)? onError,
  }) async {
    try {
      // Check permission
      final hasPermission = await checkStoragePermission();
      if (!hasPermission) {
        throw Exception('Izin penyimpanan ditolak');
      }

      // Get download directory
      Directory? downloadDir;
      if (Platform.isAndroid) {
        downloadDir = Directory('/storage/emulated/0/Download');
        if (!await downloadDir.exists()) {
          downloadDir = await getExternalStorageDirectory();
        }
      } else {
        downloadDir = await getApplicationDocumentsDirectory();
      }

      if (downloadDir == null) {
        throw Exception('Tidak dapat mengakses direktori download');
      }

      // Create unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFileName = lampiran.namaFile.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final fileName = '${timestamp}_$safeFileName';
      final savePath = '${downloadDir.path}/$fileName';

      // Download file
      await _dio.download(
        lampiran.pathFile,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      return savePath;
    } on DioException catch (e) {
      final error = 'Download gagal: ${e.message}';
      onError?.call(error);
      throw Exception(error);
    } catch (e) {
      final error = 'Download gagal: $e';
      onError?.call(error);
      throw Exception(error);
    }
  }

  /// Get file bytes for preview
  Future<List<int>> downloadBytes(
    String url, {
    void Function(int received, int total)? onProgress,
  }) async {
    try {
      final response = await _dio.get<List<int>>(
        url,
        options: Options(responseType: ResponseType.bytes),
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      return response.data ?? [];
    } catch (e) {
      throw Exception('Gagal mengunduh file: $e');
    }
  }

  /// Cancel download
  void cancelDownload() {
    _dio.close();
  }
}
