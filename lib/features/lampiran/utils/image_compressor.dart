import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageCompressor {
  static const int maxWidth = 1920;
  static const int maxHeight = 1080;
  static const int quality = 85;
  static const int maxFileSize = 5 * 1024 * 1024; // 5MB after compression

  /// Compress image file before upload
  /// Returns compressed file path or original if compression fails
  static Future<File> compressImage(File file) async {
    try {
      final fileName = path.basename(file.path);
      final ext = path.extension(fileName).toLowerCase();

      // Only compress image files
      if (!['.jpg', '.jpeg', '.png'].contains(ext)) {
        return file;
      }

      // Check if file is already small enough
      final fileSize = await file.length();
      if (fileSize < 500 * 1024) { // Less than 500KB
        return file;
      }

      // Get temp directory
      final tempDir = await getTemporaryDirectory();
      final targetPath = path.join(
        tempDir.path,
        'compressed_${DateTime.now().millisecondsSinceEpoch}$ext',
      );

      // Determine format
      CompressFormat format;
      if (ext == '.png') {
        format = CompressFormat.png;
      } else {
        format = CompressFormat.jpeg;
      }

      // Compress image
      final result = await FlutterImageCompress.compressWithFile(
        file.absolute.path,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
        format: format,
      );

      if (result == null) {
        return file;
      }

      // Write compressed data to temp file
      final compressedFile = File(targetPath);
      await compressedFile.writeAsBytes(result);

      // Verify compressed file size
      final compressedSize = await compressedFile.length();

      // If compression didn't help much, return original
      if (compressedSize > fileSize * 0.9) {
        await compressedFile.delete();
        return file;
      }

      return compressedFile;
    } catch (e) {
      // Return original file if compression fails
      return file;
    }
  }

  /// Compress image bytes
  static Future<Uint8List?> compressImageBytes(
    Uint8List bytes, {
    int quality = 85,
    int maxWidth = 1920,
    int maxHeight = 1080,
  }) async {
    try {
      return await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: maxWidth,
        minHeight: maxHeight,
        quality: quality,
      );
    } catch (e) {
      return null;
    }
  }

  /// Get compressed file info
  static Future<Map<String, dynamic>> getCompressionInfo(File original, File compressed) async {
    final originalSize = await original.length();
    final compressedSize = await compressed.length();
    final savings = originalSize - compressedSize;
    final savingsPercent = (savings / originalSize) * 100;

    return {
      'originalSize': originalSize,
      'compressedSize': compressedSize,
      'savings': savings,
      'savingsPercent': savingsPercent.toStringAsFixed(1),
    };
  }
}
