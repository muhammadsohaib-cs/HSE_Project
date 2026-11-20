import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:chiniot_power_hse/features/cpl_system/cubit/cpl_system_cubit.dart';
import 'package:chiniot_power_hse/features/screens/analytics_screen.dart';
import 'package:chiniot_power_hse/features/screens/dashboard_screen.dart';
import 'package:chiniot_power_hse/features/screens/hazard_report_screen.dart';
import 'package:chiniot_power_hse/features/screens/risk_matrix_screen.dart';
import 'package:chiniot_power_hse/features/screens/checklist_screen.dart';
import 'package:chiniot_power_hse/features/screens/ptw_screen.dart';
import 'package:chiniot_power_hse/features/screens/alarm_center_screen.dart';
import 'package:chiniot_power_hse/features/screens/training_screen.dart';
import 'package:chiniot_power_hse/features/screens/roster_screen.dart';
import 'package:chiniot_power_hse/features/screens/admin_panel_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnalyticsScreen & Full Navigation Render Smoke Tests', () {
    testWidgets('AnalyticsScreen renders KPIs, 6M/1Y charts, and departmental breakdowns with zero errors', (tester) async {
      final cubit = CplSystemCubit();
      await cubit.login(
        empId: '3648',
        shift: 'General Shift (08:00 - 17:00)',
        role: 'HSE Manager',
        pin: '3648',
      );

      await tester.pumpWidget(
        shad.Theme(
          data: shad.ThemeData(
            colorScheme: shad.ColorSchemes.lightZinc,
            radius: 0.5,
          ),
          child: MaterialApp(
            home: BlocProvider<CplSystemCubit>.value(
              value: cubit,
              child: const AnalyticsScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Safety Analytics & Reports'), findsOneWidget);
      expect(find.text('82.5%'), findsOneWidget);
      expect(find.text('84,730'), findsOneWidget);
      expect(find.text('Hazard Reduction Velocity'), findsOneWidget);
      expect(find.text('Departmental Near-Miss Breakdown (CPL-NM 2026 • 389 Cases)'), findsOneWidget);
      expect(find.text('Departmental Working Hours (Oct 2026 • 84,730 Total Hrs)'), findsOneWidget);

      // Toggle reporting window 6M <-> 1Y
      await tester.tap(find.text('1Y'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Jan'), findsOneWidget);

      await cubit.close();
    });

    testWidgets('All 10 sidebar screens render cleanly at Desktop 1440x900 with zero exceptions', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final cubit = CplSystemCubit();
      await cubit.login(
        empId: '3648',
        shift: 'General Shift (08:00 - 17:00)',
        role: 'HSE Manager',
        pin: '3648',
      );

      final screens = <String, Widget>{
        'DashboardScreen': const Scaffold(body: DashboardScreen()),
        'HazardReportScreen': const HazardReportScreen(),
        'RiskMatrixScreen': const RiskMatrixScreen(),
        'ChecklistScreen': const ChecklistScreen(),
        'PtwScreen': const PtwScreen(),
        'AlarmCenterScreen': const AlarmCenterScreen(),
        'TrainingScreen': const TrainingScreen(),
        'RosterScreen': const RosterScreen(),
        'AnalyticsScreen': const AnalyticsScreen(),
        'AdminPanelScreen': const AdminPanelScreen(),
      };

      for (final entry in screens.entries) {
        await tester.pumpWidget(
          shad.Theme(
            data: shad.ThemeData(
              colorScheme: shad.ColorSchemes.lightZinc,
              radius: 0.5,
            ),
            child: MaterialApp(
              home: BlocProvider<CplSystemCubit>.value(
                value: cubit,
                child: entry.value,
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 200));
        expect(tester.takeException(), isNull, reason: '${entry.key} threw an exception when rendering!');
      }

      await cubit.close();
    });
  });
}
