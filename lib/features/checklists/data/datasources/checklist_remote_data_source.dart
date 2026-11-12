import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../domain/entities/checklist.dart';
import '../models/checklist_model.dart';

abstract class ChecklistRemoteDataSource {
  Future<List<ChecklistTemplateModel>> fetchTemplates();
  Future<List<ChecklistAuditModel>> fetchAudits({String? plantUnit, String? shiftType});
  Future<ChecklistAuditModel> submitAudit(ChecklistAuditModel audit);
}

class ChecklistRemoteDataSourceImpl implements ChecklistRemoteDataSource {
  final Dio _dio;

  ChecklistRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<ChecklistTemplateModel>> fetchTemplates() async {
    try {
      final response = await _dio.get(ApiEndpoints.checklistTemplates);
      return (response.data['data'] as List)
          .map((item) => ChecklistTemplateModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getSeedTemplates();
    }
  }

  @override
  Future<List<ChecklistAuditModel>> fetchAudits({String? plantUnit, String? shiftType}) async {
    try {
      final response = await _dio.get(
        ApiEndpoints.checklists,
        queryParameters: {
          if (plantUnit != null) 'plant_unit': plantUnit,
          if (shiftType != null) 'shift_type': shiftType,
        },
      );
      return (response.data['data'] as List)
          .map((item) => ChecklistAuditModel.fromJson(item as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return _getSeedAudits();
    }
  }

  @override
  Future<ChecklistAuditModel> submitAudit(ChecklistAuditModel audit) async {
    try {
      final response = await _dio.post(
        ApiEndpoints.checklists,
        data: audit.toJson(),
      );
      return ChecklistAuditModel.fromJson(response.data['data'] as Map<String, dynamic>);
    } catch (_) {
      return audit;
    }
  }

  List<ChecklistTemplateModel> _getSeedTemplates() {
    return [
      ChecklistTemplateModel(
        id: 'TPL-BOILER-01',
        title: 'Boiler Unit 1 Shift Safety Inspection',
        plantUnit: PlantZones.boilerSection,
        targetRole: 'Inspector',
        defaultItems: const [
          ChecklistItemModel(
            id: 'B-01',
            title: 'Steam Drum Level Gauge glass illuminator functioning and legible',
            category: 'Pressure & Water Level',
          ),
          ChecklistItemModel(
            id: 'B-02',
            title: 'Safety valve discharge piping clear of obstructions and drains open',
            category: 'Overpressure Protection',
          ),
          ChecklistItemModel(
            id: 'B-03',
            title: 'Furnace explosion doors and sight glasses intact with cooling air on',
            category: 'Combustion Chamber',
          ),
          ChecklistItemModel(
            id: 'B-04',
            title: 'Burner flame scanner optics clean and interlock verified operational',
            category: 'Burner Management System (BMS)',
          ),
          ChecklistItemModel(
            id: 'B-05',
            title: 'Blowdown valve gland packing free from steam or hot water leaks',
            category: 'Valves & Flanges',
          ),
        ],
      ),
      ChecklistTemplateModel(
        id: 'TPL-TURBINE-02',
        title: 'Steam Turbine Generator Operational Safety Audit',
        plantUnit: PlantZones.turbineHall,
        targetRole: 'Inspector',
        defaultItems: const [
          ChecklistItemModel(
            id: 'T-01',
            title: 'Emergency stop trip pushbuttons uninhibited and unobstructed',
            category: 'Emergency Tripping',
          ),
          ChecklistItemModel(
            id: 'T-02',
            title: 'Bearing oil feed pressure & return temperatures within nominal limits',
            category: 'Lube Oil System',
          ),
          ChecklistItemModel(
            id: 'T-03',
            title: 'Turbine casing insulation blankets securely fastened with zero thermal hotspots',
            category: 'Thermal Protection',
          ),
          ChecklistItemModel(
            id: 'T-04',
            title: 'Hydrogen cooling pressure & seal oil differential pressure in safe band',
            category: 'Generator Atmosphere',
          ),
        ],
      ),
      ChecklistTemplateModel(
        id: 'TPL-SWITCH-03',
        title: '132kV Switchyard Substation Daily Walkdown',
        plantUnit: PlantZones.switchyard,
        targetRole: 'Inspector',
        defaultItems: const [
          ChecklistItemModel(
            id: 'S-01',
            title: 'SF6 gas pressure gauges on all 132kV circuit breakers in green band',
            category: 'Switchgear Medium',
          ),
          ChecklistItemModel(
            id: 'S-02',
            title: 'High-voltage perimeter fencing locked and danger warning signs visible',
            category: 'Physical Security',
          ),
          ChecklistItemModel(
            id: 'S-03',
            title: 'Station transformer bund gravel clean of oil stains and rainwater drained',
            category: 'Environmental Containment',
          ),
        ],
      ),
      ChecklistTemplateModel(
        id: 'TPL-CHEM-04',
        title: 'Chemical & Acid Storage Hazardous Material Audit',
        plantUnit: PlantZones.chemicalStorage,
        targetRole: 'Inspector',
        defaultItems: const [
          ChecklistItemModel(
            id: 'C-01',
            title: 'Emergency eye-wash stations and safety deluge showers tested',
            category: 'Emergency Decontamination',
          ),
          ChecklistItemModel(
            id: 'C-02',
            title: 'Chemical neutralizer drums, spill kits, and absorbent pads fully stocked',
            category: 'Spill Preparedness',
          ),
          ChecklistItemModel(
            id: 'C-03',
            title: 'Acid/Caustic bulk tank secondary containment sump dry and isolation valves closed',
            category: 'Secondary Containment',
          ),
        ],
      ),
    ];
  }

  List<ChecklistAuditModel> _getSeedAudits() {
    return [
      ChecklistAuditModel(
        id: 'AUD-2026-108',
        templateId: 'TPL-BOILER-01',
        title: 'Boiler Unit 1 Shift Safety Inspection',
        plantUnit: PlantZones.boilerSection,
        shiftType: ShiftType.morning.label,
        inspectorId: 'CP-EMP-1003',
        inspectorName: 'Hamza Ali',
        completionRate: 100.0,
        isCompleted: true,
        auditDate: DateTime.now().subtract(const Duration(hours: 3)),
        items: const [
          ChecklistItemModel(
            id: 'B-01',
            title: 'Steam Drum Level Gauge glass illuminator functioning and legible',
            category: 'Pressure & Water Level',
            status: ChecklistItemStatus.pass,
          ),
          ChecklistItemModel(
            id: 'B-02',
            title: 'Safety valve discharge piping clear of obstructions and drains open',
            category: 'Overpressure Protection',
            status: ChecklistItemStatus.pass,
          ),
          ChecklistItemModel(
            id: 'B-03',
            title: 'Furnace explosion doors and sight glasses intact with cooling air on',
            category: 'Combustion Chamber',
            status: ChecklistItemStatus.fail,
            deviationNotes: 'Sight glass port #2 cracked; immediate replacement requested.',
          ),
          ChecklistItemModel(
            id: 'B-04',
            title: 'Burner flame scanner optics clean and interlock verified operational',
            category: 'Burner Management System (BMS)',
            status: ChecklistItemStatus.pass,
          ),
          ChecklistItemModel(
            id: 'B-05',
            title: 'Blowdown valve gland packing free from steam or hot water leaks',
            category: 'Valves & Flanges',
            status: ChecklistItemStatus.pass,
          ),
        ],
      ),
    ];
  }
}

