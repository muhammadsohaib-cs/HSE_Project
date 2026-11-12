import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'platform_helper.dart';

class PlantMediaFile {
  final String path;
  final String name;
  final int? sizeBytes;
  final DateTime capturedAt;
  final String watermark;

  PlantMediaFile({
    required this.path,
    required this.name,
    this.sizeBytes,
    DateTime? capturedAt,
    String? watermark,
  })  : capturedAt = capturedAt ?? DateTime.now(),
        watermark = watermark ??
            '31.7204° N, 72.9791° E • UNIT-1 62.4 MW • CPL HSE • ${DateTime.now().toIso8601String().substring(0, 19)}';
}

class MediaService {
  final ImagePicker _picker = ImagePicker();

  /// Captures photo via camera on mobile; falls back to file picker on desktop
  Future<PlantMediaFile?> capturePhoto() async {
    try {
      if (PlatformHelper.isDesktop) {
        return await pickPhoto();
      }

      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );

      if (file == null) return null;
      final bytes = await file.length();

      return PlantMediaFile(
        path: file.path,
        name: file.name,
        sizeBytes: bytes,
      );
    } catch (e) {
      debugPrint('MediaService.capturePhoto error: $e');
      return await pickPhoto();
    }
  }

  /// Picks photo from gallery or local desktop filesystem via FilePicker
  Future<PlantMediaFile?> pickPhoto() async {
    try {
      if (PlatformHelper.isDesktop) {
        final result = await FilePicker.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        );
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          return PlantMediaFile(
            path: file.path ?? '',
            name: file.name,
            sizeBytes: file.size,
          );
        }
        return null;
      }

      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (file == null) return null;
      final bytes = await file.length();

      return PlantMediaFile(
        path: file.path,
        name: file.name,
        sizeBytes: bytes,
      );
    } catch (e) {
      debugPrint('MediaService.pickPhoto error: $e');
      return null;
    }
  }
}

