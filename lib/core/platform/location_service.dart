import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../constants/plant_zones.dart';
import 'platform_helper.dart';

class PlantCoordinate {
  final double latitude;
  final double longitude;
  final double? altitude;
  final String source; // 'GPS' or 'ZoneReference' or 'Manual'

  const PlantCoordinate({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.source = 'GPS',
  });

  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'altitude': altitude,
    'source': source,
  };

  factory PlantCoordinate.fromJson(Map<String, dynamic> json) => PlantCoordinate(
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    altitude: json['altitude'] != null ? (json['altitude'] as num).toDouble() : null,
    source: json['source'] as String? ?? 'GPS',
  );

  @override
  String toString() => '$latitude, $longitude (${altitude != null ? "${altitude!.toStringAsFixed(1)}m, " : ""}$source)';
}

class LocationService {
  /// Default Chiniot Power Plant Center Coordinates
  static const double defaultLat = 31.7205;
  static const double defaultLng = 72.9780;

  /// Fetches current location with graceful fallback for Desktop & denied permissions
  static Future<PlantCoordinate> getCurrentCoordinates({String? plantZone}) async {
    // On desktop, GPS hardware is rarely present, use Zone reference coordinates
    if (PlatformHelper.isDesktop) {
      return _getZoneFallback(plantZone, source: 'DesktopZoneReference');
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return _getZoneFallback(plantZone, source: 'LocationServicesDisabled');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return _getZoneFallback(plantZone, source: 'PermissionDenied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return _getZoneFallback(plantZone, source: 'PermissionDeniedForever');
      }

      // Fetch precise device GPS
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return PlantCoordinate(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        source: 'NativeGPS',
      );
    } catch (e) {
      debugPrint('LocationService warning: $e. Falling back to plant zone coordinates.');
      return _getZoneFallback(plantZone, source: 'GPSHardwareException');
    }
  }

  static PlantCoordinate _getZoneFallback(String? plantZone, {required String source}) {
    if (plantZone != null && PlantZones.zoneCoordinates.containsKey(plantZone)) {
      final coords = PlantZones.zoneCoordinates[plantZone]!;
      return PlantCoordinate(
        latitude: coords.$1,
        longitude: coords.$2,
        altitude: 185.0, // Chiniot elevation approx 185m ASL
        source: source,
      );
    }
    return PlantCoordinate(
      latitude: defaultLat,
      longitude: defaultLng,
      altitude: 185.0,
      source: source,
    );
  }
}

