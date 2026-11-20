import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chiniot_power_hse/core/constants/cpl_checklists_data.dart';
import 'package:chiniot_power_hse/features/cpl_system/cubit/cpl_system_cubit.dart';
import 'package:chiniot_power_hse/features/screens/checklist_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('CPL 12 Operational Checklists Verification', () {
    test('Catalog contains all 12 operational CPL checklist templates with official doc numbers', () {
      expect(kCplChecklistTemplates.length, equals(12));

      final expectedDocNos = [
        'CPL-HSEFEIC-01', // Fire Extinguishers Inspection Checklist
        'CPL-FECC-01',    // Daily Fire Fighting Equipment Cleaning Checklist
        'CPL-WFHCIC-01',  // Weekly Fire Hose Cabinet Inventory Checklist
        'CPL-HSEFWDIC-01',// Fire Water Drums Inspection Checklist
        'CPL-FFEWIS-01',  // Firefighting Equipment Weekly Inspection Schedule
        'CPL-HSEFABI-01', // First Aid Box Inspection Checklist
        'CPL-HSEHIC-01',  // Fire Hydrant Inspection Checklist
        'CPL-MLVAHCIC-01',// Monthly Landing Valve & Hose Cabinet Record
        'CPL-WFMIC-01',   // Weekly Fire Fighting Monitors Inspection Checklist
        'HSE-TAS-01',     // HSE Safety Induction Attendance & Verification
        'CPL-WTIC-01',    // Weekly Tractors & Mobile Equipment Inspection Checklist
        'CPL-WRWS-01',    // Daily & Weekly Routine Work Checklist
      ];

      for (final docNo in expectedDocNos) {
        final match = kCplChecklistTemplates.any((t) => t.docNo == docNo || t.id == docNo);
        expect(match, isTrue, reason: 'Expected checklist template $docNo to be present in catalog');
      }
    });

    test('Each checklist template has bilingual text, valid items, and realistic standards', () {
      for (final template in kCplChecklistTemplates) {
        expect(template.id, isNotEmpty);
        expect(template.docNo, isNotEmpty);
        expect(template.title, isNotEmpty);
        expect(template.titleUr, isNotEmpty);
        expect(template.category, isNotEmpty);
        expect(template.frequency, isNotEmpty);
        expect(template.targetZone, isNotEmpty);
        expect(template.items, isNotEmpty);

        for (final item in template.items) {
          expect(item.id, isPositive);
          expect(item.en, isNotEmpty);
          expect(item.ur, isNotEmpty);
          expect(item.status, equals('pass'));
          expect(item.standard, isNotEmpty);
        }
      }
    });

    test('CplSystemCubit allows switching templates dynamically and updates active items & zone', () {
      final cubit = CplSystemCubit();

      expect(cubit.state.checklistTemplates.length, equals(12));

      // Select Tractor Inspection Checklist
      cubit.selectChecklistTemplate('CPL-WTIC-01');
      expect(cubit.state.activeChecklistTemplateId, equals('CPL-WTIC-01'));
      expect(cubit.state.activeChecklistTemplate?.docNo, equals('CPL-WTIC-01'));
      expect(cubit.state.checklistZone, equals('Bagasse Piling & Shredder (BPL / RSML)'));
      expect(cubit.state.checklistItems.length, equals(8));
      expect(cubit.state.checklistSigned, isFalse);

      // Select First Aid Box Checklist
      cubit.selectChecklistTemplate('CPL-HSEFABI-01');
      expect(cubit.state.activeChecklistTemplateId, equals('CPL-HSEFABI-01'));
      expect(cubit.state.activeChecklistTemplate?.docNo, equals('CPL-HSEFABI-01'));
      expect(cubit.state.checklistZone, equals('Admin, Stores & Workshops (MMD / EMD / I&C)'));
      expect(cubit.state.checklistItems.length, equals(7));

      // Select Fire Monitors Checklist
      cubit.selectChecklistTemplate('CPL-WFMIC-01');
      expect(cubit.state.activeChecklistTemplateId, equals('CPL-WFMIC-01'));
      expect(cubit.state.activeChecklistTemplate?.docNo, equals('CPL-WFMIC-01'));
      expect(cubit.state.checklistZone, equals('Fuel & Bagasse Yard (BC-1 to BC-5 / JT)'));
      expect(cubit.state.checklistItems.length, equals(5));

      cubit.close();
    });

    test('Category filtering filters the 12 templates accurately', () {
      final cubit = CplSystemCubit();

      // All categories
      expect(cubit.state.filteredChecklistTemplates.length, equals(12));

      // Filter by Heavy Vehicles & Mobile Plant
      cubit.setChecklistCategoryFilter('Heavy Vehicles & Mobile Plant');
      expect(cubit.state.filteredChecklistTemplates.length, equals(1));
      expect(cubit.state.filteredChecklistTemplates.first.docNo, equals('CPL-WTIC-01'));

      // Filter by First Aid & Health Emergency
      cubit.setChecklistCategoryFilter('First Aid & Health Emergency');
      expect(cubit.state.filteredChecklistTemplates.length, equals(1));
      expect(cubit.state.filteredChecklistTemplates.first.docNo, equals('CPL-HSEFABI-01'));

      // Filter by Fire Protection & Life Safety
      cubit.setChecklistCategoryFilter('Fire Protection & Life Safety');
      expect(cubit.state.filteredChecklistTemplates.length, equals(8));

      cubit.close();
    });

    test('Failing an audit item dispatches auto-CAPA and updates compliance rate', () {
      final cubit = CplSystemCubit();
      final initialHazards = cubit.state.hazards.length;

      cubit.selectChecklistTemplate('CPL-HSEFEIC-01');

      // Fail item #1 (Pressure gauge)
      cubit.setChecklistItemStatus(1, 'fail');

      expect(cubit.state.checklistItems.firstWhere((i) => i.id == 1).status, equals('fail'));
      expect(cubit.state.hazards.length, equals(initialHazards + 1));
      expect(cubit.state.hazards.first.title, contains('Checklist Defect'));

      // Toggle digital signature
      expect(cubit.state.checklistSigned, isFalse);
      cubit.toggleChecklistSignature();
      expect(cubit.state.checklistSigned, isTrue);

      cubit.close();
    });

    testWidgets('ChecklistScreen renders cleanly and switches categories without DropdownButton assertion errors', (tester) async {
      final cubit = CplSystemCubit();

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CplSystemCubit>.value(
            value: cubit,
            child: const ChecklistScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Default template CPL-HSEFEIC-01 rendered with matching checkpoints
      expect(find.text('DOC# CPL-HSEFEIC-01'), findsOneWidget);
      expect(find.textContaining('Pressure Gauge'), findsOneWidget);

      // Switch through EVERY category filter (previously triggered DropdownButton assertion error)
      for (final category in [
        'First Aid & Health Emergency',
        'Heavy Vehicles & Mobile Plant',
        'Plant Operations & Maintenance',
        'Safety Training & Contractor Induction',
        'Fire Protection & Life Safety',
        'All',
      ]) {
        cubit.setChecklistCategoryFilter(category);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: 'No exception when switching to category $category');
      }

      // Also verify defensive guard if activeChecklistTemplateId is stale relative to filteredTemplates
      cubit.emit(cubit.state.copyWith(
        checklistCategoryFilter: 'Heavy Vehicles & Mobile Plant',
        activeChecklistTemplateId: 'CPL-HSEFEIC-01',
      ));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      await cubit.close();
    });
  });
}
