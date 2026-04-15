import 'dart:io';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart' as ph;
import 'package:device_info_plus/device_info_plus.dart';

class LampiranPermissionHandler {
  /// Request camera permission
  static Future<bool> requestCameraPermission() async {
    final status = await ph.Permission.camera.request();
    return status.isGranted;
  }

  /// Request photos/gallery permission for image picking
  static Future<bool> requestPhotosPermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        // Android 13+ (API 33+): Use READ_MEDIA_IMAGES
        final photos = await ph.Permission.photos.request();
        return photos.isGranted || photos.isLimited;
      } else {
        // Android 12 and below: Use storage permission
        final storage = await ph.Permission.storage.request();
        return storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await ph.Permission.photos.request();
      return photos.isGranted || photos.isLimited;
    }
    return false;
  }

  /// Request storage permission for download
  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final sdkInt = await _getAndroidSdkInt();

      if (sdkInt >= 33) {
        // Android 13+: Request photos permission for saving to gallery
        final photos = await ph.Permission.photos.request();
        if (photos.isGranted || photos.isLimited) {
          return true;
        }

        // Try media location as fallback
        final mediaLocation = await ph.Permission.accessMediaLocation.request();
        return mediaLocation.isGranted;
      } else {
        // Android 12 and below
        final storage = await ph.Permission.storage.request();
        return storage.isGranted;
      }
    } else if (Platform.isIOS) {
      final photos = await ph.Permission.photos.request();
      return photos.isGranted || photos.isLimited;
    }
    return false;
  }

  /// Request notification permission
  static Future<bool> requestNotificationPermission() async {
    final status = await ph.Permission.notification.request();
    return status.isGranted;
  }

  /// Check current permission status
  static Future<ph.PermissionStatus> checkPermission(ph.Permission permission) async {
    return await permission.status;
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
      'camera': await requestCameraPermission(),
      'photos': await requestPhotosPermission(),
      'storage': await requestStoragePermission(),
      'notifications': await requestNotificationPermission(),
    };
  }

  /// Get Android SDK version
  static Future<int> _getAndroidSdkInt() async {
    if (Platform.isAndroid) {
      final deviceInfo = DeviceInfoPlugin();
      final androidInfo = await deviceInfo.androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 30; // Default for non-Android
  }

  /// Check if we can pick files
  /// For Android 13+ no permission needed to pick files
  /// For older versions need storage permission
  static Future<bool> canPickFiles() async {
    if (Platform.isAndroid) {
      // Check photos permission status
      final photos = await ph.Permission.photos.status;
      if (photos.isGranted || photos.isLimited) {
        return true;
      }

      // Check storage permission status
      final storage = await ph.Permission.storage.status;
      return storage.isGranted;
    }

    // iOS
    final photos = await ph.Permission.photos.status;
    return photos.isGranted || photos.isLimited;
  }

  /// Get permission status map for debugging
  static Future<Map<String, String>> getPermissionStatusMap() async {
    final Map<String, String> status = {};

    status['camera'] = (await ph.Permission.camera.status).label;
    status['photos'] = (await ph.Permission.photos.status).label;
    status['storage'] = (await ph.Permission.storage.status).label;
    status['notification'] = (await ph.Permission.notification.status).label;
    status['manageExternalStorage'] = (await ph.Permission.manageExternalStorage.status).label;

    return status;
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
