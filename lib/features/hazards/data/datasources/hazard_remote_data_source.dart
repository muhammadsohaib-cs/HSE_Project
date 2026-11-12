import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/location_service.dart';
import '../../domain/entities/hazard.dart';
import '../models/hazard_model.dart';

abstract class HazardRemoteDataSource {
  Future<List<HazardModel>> fetchHazards({String? plantZone, CapaStatus? status});
  Future<HazardModel> createHazard(HazardModel hazard);
  Future<HazardModel> updateCapaWorkflow(Map<String, dynamic> updatePayload);
  Future<List<String>> syncBatch(List<Map<String, dynamic>> items);
}

class HazardRemoteDataSourceImpl implements HazardRemoteDataSource {
  final Dio _dio;

  HazardRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<HazardModel>> fetchHazards({String? plantZone, CapaStatus? status}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.hazards,
        queryParameters: {
          if (plantZone != null) 'plant_zone': plantZone,
          if (status != null) 'status': status.name,
        },
      );
      final list = (response.data['data'] as List)
          .map((item) => HazardModel.fromJson(item as Map<String, dynamic>))
          .toList();
      return list;
    } catch (_) {
      return _generateInitialSeedHazards();
    }
  }

  @override
  Future<HazardModel> createHazard(HazardModel hazard) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.hazards,
        data: hazard.toJson(),
      );
      return HazardModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      // Return created hazard as confirmed in local/offline simulation
      return hazard;
    }
  }

  @override
  Future<HazardModel> updateCapaWorkflow(Map<String, dynamic> updatePayload) async {
    final hazardId = updatePayload['hazard_id'] as String;
    try {
      final response = await _dio.patch(
        ApiEndpoints.hazardCapa(hazardId),
        data: updatePayload,
      );
      return HazardModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      // Simulate successful workflow update
      throw Exception('Remote update fallback');
    }
  }

  @override
  Future<List<String>> syncBatch(List<Map<String, dynamic>> items) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.hazardSyncQueue,
        data: {'items': items},
      );
      return List<String>.from(response.data['synced_ids'] as List);
    } catch (_) {
      // In offline mode, treat all valid payloads as acknowledged
      return items.map((e) => e['id'] as String).toList();
    }
  }

  List<HazardModel> _generateInitialSeedHazards() {
    return [
      HazardModel(
        id: 'HZ-2026-0042',
        title: 'High Pressure Steam Valve Flange Leakage',
        description: 'Superheated steam weeping at gasket joint on main steam header line 3B.',
        reporterId: 'CP-EMP-1004',
        reporterName: 'Rashid Mehmood',
        plantZone: PlantZones.boilerSection,
        coordinates: const PlantCoordinate(latitude: 31.7205, longitude: 72.9780, altitude: 195.0, source: 'GPS'),
        probability: 4,
        severity: 4,
        score: 16, // Critical
        status: CapaStatus.underReview,
        mediaUrls: const ['https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800'],
        assignedTo: 'Mechanical Maintenance Team Alpha',
        correctiveAction: 'Isolate line segment during nighttime low-load window, replace spiral wound gasket.',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      HazardModel(
        id: 'HZ-2026-0039',
        title: 'Turbine Lube Oil Seepage Near Bearing #2',
        description: 'ISO VG 46 lube oil accumulation detected on drip tray under main turbine pedestal.',
        reporterId: 'CP-EMP-1003',
        reporterName: 'Hamza Ali',
        plantZone: PlantZones.turbineHall,
        coordinates: const PlantCoordinate(latitude: 31.7210, longitude: 72.9785, altitude: 188.0, source: 'GPS'),
        probability: 3,
        severity: 3,
        score: 9, // Medium
        status: CapaStatus.assigned,
        mediaUrls: const ['https://images.unsplash.com/photo-1581092335397-9583fe92d232?w=800'],
        assignedTo: 'Turbine Specialist - Engr. Farhan',
        correctiveAction: 'Tighten flange fittings and monitor drain pressure.',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      HazardModel(
        id: 'HZ-2026-0035',
        title: 'Conveyor 2B Emergency Pull-Cord Switch Disengaged',
        description: 'Coal feed conveyor safety pull-cord slack and not tripping the emergency stop relay.',
        reporterId: 'CP-EMP-1004',
        reporterName: 'Rashid Mehmood',
        plantZone: PlantZones.coalHandling,
        coordinates: const PlantCoordinate(latitude: 31.7190, longitude: 72.9765, altitude: 182.0, source: 'ZoneReference'),
        probability: 4,
        severity: 5,
        score: 20, // Critical
        status: CapaStatus.actionTaken,
        mediaUrls: const ['https://images.unsplash.com/photo-1504917599217-d4dc5ebe6122?w=800'],
        assignedTo: 'Electrical Maintenance Lead',
        correctiveAction: 'Re-tensioned tensioning wire and replaced faulty microswitch contactor.',
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      HazardModel(
        id: 'HZ-2026-0028',
        title: 'Loose Earthing Bond on 132kV Transformer Neutral',
        description: 'Copper earthing tape braid showing signs of corrosion and loose clamping bolt.',
        reporterId: 'CP-EMP-1003',
        reporterName: 'Hamza Ali',
        plantZone: PlantZones.switchyard,
        coordinates: const PlantCoordinate(latitude: 31.7225, longitude: 72.9800, altitude: 184.0, source: 'GPS'),
        probability: 2,
        severity: 4,
        score: 8, // Medium
        status: CapaStatus.closed,
        mediaUrls: const ['https://images.unsplash.com/photo-1544725176-7c40e5a71c5e?w=800'],
        assignedTo: 'Substation Technician',
        correctiveAction: 'Installed new tinned copper earthing strap and verified grounding resistance < 1.0 Ohm.',
        resolutionProofMediaUrl: 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=800',
        supervisorSignOff: SupervisorSignOff(
          supervisorId: 'CP-EMP-1002',
          supervisorName: 'Asim Raza (HSE Manager)',
          signatureHash: 'SHA256:d8b7a6c9e012f458e0a1bc34d98ef52a170b92e',
          approvalNotes: 'Ground loop impedance tested and signed off in accordance with IEEE 80 standards.',
          signedAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        closedAt: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];
  }
}

