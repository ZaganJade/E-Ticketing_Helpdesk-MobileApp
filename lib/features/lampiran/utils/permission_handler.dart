import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;

class LampiranPermissionHandler {
  /// Request storage permission for download
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        // Android 13+ (API 33+)
        // For downloads, we don't need special permissions if using app's private storage
        // But for saving to Downloads folder:
        if (sdkInt >= 34) {
          // Android 14+ needs special handling
          final photos = await ph.Permission.photos.request();
          return photos.isGranted;
        }
        return true;
      } else {
        // Android 12 and below
        final status = await ph.Permission.storage.request();
        return status.isGranted;
      }
    } else if (Platform.isIOS) {
      // iOS doesn't need explicit storage permission
      return true;
    }
    return false;
  }

  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  /// Request photos/gallery permission
  static Future<bool> requestPhotosPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        // Android 13+ uses READ_MEDIA_IMAGES
        final photos = await ph.Permission.photos.request();
        return photos.isGranted;
      } else {
        // Older Android uses storage permission
        final storage = await ph.Permission.storage.request();
        return storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await ph.Permission.photos.request();
      return photos.isGranted;
    }
    return false;
  }

  /// Check if permission is permanently denied
  static Future<bool> isPermanentlyDenied(ph.Permission permission) async {
    final status = await permission.status;
    return status.isPermanentlyDenied;
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await ph.openAppSettings();
  }

  /// Show permission rationale dialog
  static Future<bool> showPermissionRationale(
    BuildContext context, {
    required String title,
    required String message,
    required String permissionName,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Tolak'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Izinkan'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  /// Request all permissions needed for lampiran feature
  static Future<Map<String, bool>> requestAllPermissions() async {
    return {
      'storage': await requestStoragePermission(),
      'camera': await requestCameraPermission(),
      'photos': await requestPhotosPermission(),
    };
  }

  /// Get Android SDK version
  static Future<int> _getAndroidSdkInt() async {
    // This would normally use a platform channel
    // For now, return a default value
    return 30;
  }

  /// Check if we can pick files
  static Future<bool> canPickFiles() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        // On Android 13+, we can pick files without permission
        return true;
      }

      // On older Android, we need storage permission
      final storage = await ph.Permission.storage.status;
      return storage.isGranted;
    }

    // On iOS, we can pick files from gallery without permission
    return true;
  }
}

/// Permission status extension
extension PermissionStatusExtension on ph.PermissionStatus {
  String get label {
    switch (this) {
      case ph.PermissionStatus.granted:
        return 'Diizinkan';
      case ph.PermissionStatus.denied:
        return 'Ditolak';
      case ph.PermissionStatus.permanentlyDenied:
        return 'Ditolak Permanen';
      case ph.PermissionStatus.restricted:
        return 'Dibatasi';
      case ph.PermissionStatus.limited:
        return 'Terbatas';
      case ph.PermissionStatus.provisional:
        return 'Sementara';
    }
  }
}
