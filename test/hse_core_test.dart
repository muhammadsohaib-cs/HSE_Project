import 'package:flutter_test/flutter_test.dart';
import 'package:chiniot_power_hse/core/utils/risk_calculator.dart';
import 'package:chiniot_power_hse/features/auth/domain/entities/user.dart';
import 'package:chiniot_power_hse/features/checklists/domain/entities/checklist.dart';

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
}

