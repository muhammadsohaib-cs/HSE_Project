import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'platform_helper.dart';

class PlantMediaFile {
  final String path;
  final String name;
  final int? sizeBytes;
  final DateTime capturedAt;

  PlantMediaFile({
    required this.path,
    required this.name,
    this.sizeBytes,
    DateTime? capturedAt,
  }) : capturedAt = capturedAt ?? DateTime.now();
}

class MediaService {
  final ImagePicker _picker = ImagePicker();

  /// Captures photo via camera on mobile; falls back to gallery/file dialog on desktop
  Future<PlantMediaFile?> capturePhoto() async {
    try {
      if (PlatformHelper.isDesktop) {
        // Desktop workstations pick files from disk
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
      return null;
    }
  }

  /// Picks photo from gallery or local filesystem
  Future<PlantMediaFile?> pickPhoto() async {
    try {
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

