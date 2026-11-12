import 'package:flutter_test/flutter_test.dart';
import 'package:chiniot_power_hse/core/utils/risk_calculator.dart';
import 'package:chiniot_power_hse/core/storage/offline_sync_queue.dart';
import 'package:chiniot_power_hse/features/auth/domain/entities/user.dart';
import 'package:chiniot_power_hse/features/checklists/domain/entities/checklist.dart';
import 'package:chiniot_power_hse/features/cpl_system/cubit/cpl_system_state.dart';
import 'package:chiniot_power_hse/features/cpl_system/models/cpl_models.dart';

void main() {
  group('Employee ID Validation Tests (CP-EMP-XXXX)', () {
    test('Valid employee IDs format conform correctly', () {
      expect(User.isValidEmployeeId('CP-EMP-1001'), isTrue);
      expect(User.isValidEmployeeId('CP-EMP-0042'), isTrue);
      expect(User.isValidEmployeeId('CP-EMP-9999'), isTrue);
      expect(User.isValidEmployeeId('cp-emp-1002'), isTrue); // Case-insensitive handling
    });

    test('Invalid employee IDs are rejected', () {
      expect(User.isValidEmployeeId('EMP-1001'), isFalse);
      expect(User.isValidEmployeeId('CP-1001'), isFalse);
      expect(User.isValidEmployeeId('CP-EMP-123'), isFalse); // Only 3 digits
      expect(User.isValidEmployeeId('CP-EMP-12345'), isFalse); // 5 digits
      expect(User.isValidEmployeeId('CP-EMP-ABCD'), isFalse); // Non-numeric
      expect(User.isValidEmployeeId(''), isFalse);
    });
  });

  group('5x5 Risk Assessment Matrix Tests', () {
    test('Calculates quantitative score correctly', () {
      expect(RiskCalculator.calculateScore(1, 1), equals(1));
      expect(RiskCalculator.calculateScore(3, 3), equals(9));
      expect(RiskCalculator.calculateScore(4, 4), equals(16));
      expect(RiskCalculator.calculateScore(5, 5), equals(25));
    });

    test('Assigns accurate risk bands based on computed score', () {
      // Low: 1 - 4
      expect(RiskCalculator.getRiskBand(1), equals(RiskBand.low));
      expect(RiskCalculator.getRiskBand(4), equals(RiskBand.low));

      // Medium: 5 - 9
      expect(RiskCalculator.getRiskBand(5), equals(RiskBand.medium));
      expect(RiskCalculator.getRiskBand(9), equals(RiskBand.medium));

      // High: 10 - 14
      expect(RiskCalculator.getRiskBand(10), equals(RiskBand.high));
      expect(RiskCalculator.getRiskBand(14), equals(RiskBand.high));

      // Critical: 15 - 25
      expect(RiskCalculator.getRiskBand(15), equals(RiskBand.critical));
      expect(RiskCalculator.getRiskBand(25), equals(RiskBand.critical));
    });
  });

  group('Daily Safety Checklist Aggregation Tests', () {
    test('Computes pass, fail, na counts correctly', () {
      final audit = ChecklistAudit(
        id: 'AUD-TEST-001',
        templateId: 'TPL-TEST',
        title: 'Test Audit',
        plantUnit: 'Boiler Section',
        shiftType: 'Morning Shift',
        inspectorId: 'CP-EMP-1003',
        inspectorName: 'Inspector Ali',
        completionRate: 100.0,
        isCompleted: true,
        auditDate: DateTime(2026, 1, 1),
        items: [
          ChecklistItem(id: '1', title: 'Item 1', category: 'General', status: ChecklistItemStatus.pass),
          ChecklistItem(id: '2', title: 'Item 2', category: 'General', status: ChecklistItemStatus.pass),
          ChecklistItem(
            id: '3',
            title: 'Item 3',
            category: 'General',
            status: ChecklistItemStatus.fail,
            deviationNotes: 'Broken gauge',
          ),
          ChecklistItem(id: '4', title: 'Item 4', category: 'General', status: ChecklistItemStatus.na),
        ],
      );

      expect(audit.passCount, equals(2));
      expect(audit.failCount, equals(1));
      expect(audit.naCount, equals(1));
    });
  });

  group('Offline Sync Queue Item Serialization Tests', () {
    test('Serializes to and from JSON accurately', () {
      final now = DateTime(2026, 11, 12, 10, 30, 0);
      final item = SyncQueueItem(
        id: 'SYNC-001',
        actionType: 'CREATE_HAZARD',
        payload: {
          'title': 'High Pressure Steam Leak',
          'zone': 'Boiler House Unit-1',
          'score': 16,
        },
        queuedAt: now,
        retryCount: 1,
      );

      final json = item.toJson();
      expect(json['id'], equals('SYNC-001'));
      expect(json['actionType'], equals('CREATE_HAZARD'));
      expect(json['payload']['title'], equals('High Pressure Steam Leak'));
      expect(json['retryCount'], equals(1));

      final restored = SyncQueueItem.fromJson(json);
      expect(restored.id, equals(item.id));
      expect(restored.actionType, equals(item.actionType));
      expect(restored.payload['zone'], equals('Boiler House Unit-1'));
      expect(restored.queuedAt, equals(now));
      expect(restored.retryCount, equals(1));
    });
  });

  group('Role-Based Access Control (RBAC) Permission Tests', () {
    CplSystemState createStateForRole(String role) {
      return CplSystemState(
        language: 'en',
        activeScreenIndex: 0,
        currentUser: UserSession(
          empId: 'CPL-EMP-TEST',
          name: 'Test Staff',
          urduName: 'ٹیسٹ اسٹاف',
          role: role,
          shift: 'Shift A',
          cnic: '33202-0000000-0',
          zone: 'Boiler House Unit-1',
        ),
        zones: const [],
        hazards: const [],
        selectedLikelihood: 3,
        selectedSeverity: 4,
        capas: const [],
        checklistItems: const [],
        checklistZone: 'Boiler House Unit-1',
        checklistSigned: false,
        permits: const [],
        ptwFilter: 'All',
        emailLogs: const [],
        trainings: const [],
        qrCheckedIn: false,
        roster: const [],
        analyticsPeriod: '6M',
        pendingUsers: const [],
        emailRecipients: const [],
      );
    }

    test('Plant Worker has restricted access (cannot approve PTW or admin panel)', () {
      final state = createStateForRole('Plant Worker');
      expect(state.isManager, isFalse);
      expect(state.isInspector, isFalse);
      expect(state.canApprovePtw, isFalse);
      expect(state.canAccessAdminPanel, isFalse);
      expect(state.canSignOffCapa, isFalse);
    });

    test('Safety Officer / Inspector can sign off CAPA but cannot approve PTW/Admin', () {
      final state = createStateForRole('Safety Officer');
      expect(state.isManager, isFalse);
      expect(state.isInspector, isTrue);
      expect(state.canApprovePtw, isFalse);
      expect(state.canAccessAdminPanel, isFalse);
      expect(state.canSignOffCapa, isTrue);
    });

    test('HSE Manager has full authority (PTW approval, Admin panel, CAPA sign-off)', () {
      final state = createStateForRole('HSE Manager');
      expect(state.isManager, isTrue);
      expect(state.isInspector, isTrue);
      expect(state.canApprovePtw, isTrue);
      expect(state.canAccessAdminPanel, isTrue);
      expect(state.canSignOffCapa, isTrue);
    });
  });

  group('Audit Log Item Model Tests (NEPRA / ISO 45001)', () {
    test('Serializes to and from JSON accurately with GPS and timestamps', () {
      const log = AuditLogItem(
        id: 'LOG-999',
        actorId: 'CP-EMP-1001',
        actorRole: 'HSE Manager',
        action: 'APPROVE_PTW',
        targetResource: 'PTW-842',
        timestamp: '2026-11-12T14:00:00Z',
        coords: '31.7204° N, 72.9791° E',
        details: 'Approved Hot Work welding permit for Boiler Header.',
      );

      final json = log.toJson();
      expect(json['id'], equals('LOG-999'));
      expect(json['actorId'], equals('CP-EMP-1001'));
      expect(json['action'], equals('APPROVE_PTW'));
      expect(json['coords'], equals('31.7204° N, 72.9791° E'));

      final restored = AuditLogItem.fromJson(json);
      expect(restored.id, equals(log.id));
      expect(restored.targetResource, equals('PTW-842'));
      expect(restored.details, contains('Approved Hot Work'));
    });
  });
}

