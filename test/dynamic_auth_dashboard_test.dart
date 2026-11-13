import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiniot_power_hse/features/cpl_system/cubit/cpl_system_cubit.dart';
import 'package:chiniot_power_hse/features/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dynamic Registration, Auth Validation & Home Dashboard Tests', () {
    testWidgets('Seamless registration -> login -> Home Dashboard renders CPL-EMP-2050 and live metrics', (tester) async {
      final cubit = CplSystemCubit();

      // 1. Register brand-new Employee ID CPL-EMP-2050
      final signupOk = await cubit.signup(
        empId: 'cpl-emp-2050',
        fullName: 'Hamza Ali',
        cnic: '33202-9876543-1',
        shift: 'Shift C: Night',
        role: 'Safety Officer',
        password: 'pass2050',
        assignedZone: '132kV Grid Switchyard',
      );

      expect(signupOk, isTrue);
      expect(cubit.state.lastAuthError, isNull);
      // Immediately approved (no lockout)
      expect(
        cubit.state.pendingUsers.any((u) => u.empId == 'CPL-EMP-2050' && u.status == 'Approved'),
        isTrue,
      );
      expect(cubit.state.roster.any((w) => w.empId == 'CPL-EMP-2050'), isTrue);

      // 2. Reject wrong password cleanly with error message
      final badLogin = await cubit.login(
        empId: 'cpl-emp-2050',
        shift: 'Shift C: Night',
        role: 'Safety Officer',
        password: 'wrongpassword',
      );
      expect(badLogin, isFalse);
      expect(cubit.state.lastAuthError, isNotNull);

      // 3. Login with case-insensitive Employee ID and exact password
      final goodLogin = await cubit.login(
        empId: 'cpl-emp-2050',
        shift: 'Shift C: Night',
        role: 'Safety Officer',
        password: 'pass2050',
      );
      expect(goodLogin, isTrue);
      expect(cubit.state.lastAuthError, isNull);
      expect(cubit.state.currentUser.empId, equals('CPL-EMP-2050'));
      expect(cubit.state.currentUser.name, equals('Hamza Ali'));
      expect(cubit.state.currentUser.role, equals('Safety Officer'));
      expect(cubit.state.currentUser.zone, equals('132kV Grid Switchyard'));
      expect(cubit.state.currentUser.shift, equals('Shift C: Night'));

      // 4. Render Home Dashboard
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CplSystemCubit>.value(
            value: cubit,
            child: const Scaffold(body: DashboardScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Dynamic Employee Identity Card checks
      expect(find.text('UNIT-1 ONLINE'), findsOneWidget);
      expect(find.text('HA'), findsOneWidget); // Initials for Hamza Ali
      expect(find.text('Hamza Ali'), findsOneWidget);
      expect(find.text('CPL-EMP-2050'), findsOneWidget);
      expect(find.text('Safety Officer • 132kV Grid Switchyard'), findsOneWidget);
      expect(find.text('Shift C: Night'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);

      // Hardcoded cards removed
      expect(find.text('591'), findsNothing);
      expect(find.text('623'), findsNothing);
      expect(find.text('218'), findsNothing);
      expect(find.text('97.2%'), findsNothing);
      expect(find.text('148/148 PPE Verified'), findsNothing);
      expect(find.text('MT'), findsNothing);

      // Live Operational Metrics Grid & Activity Feed present
      expect(find.text('Open Hazards'), findsOneWidget);
      expect(find.text('Shift Checklist'), findsOneWidget);
      expect(find.text('Active PTW / LOTO'), findsOneWidget);
      expect(find.text('On-Duty Roster'), findsOneWidget);
      expect(find.text('RECENT LIVE ACTIVITY'), findsOneWidget);

      // 5. Logout clears user session completely & returns to AuthScreen (index 0)
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      expect(cubit.state.activeScreenIndex, equals(0));
      expect(cubit.state.isAuthenticated, isFalse);
      expect(cubit.state.currentUser.empId, isEmpty);
      expect(cubit.state.currentUser.name, isEmpty);

      // 6. Attempting to navigate to Dashboard while logged out is blocked
      cubit.setScreenIndex(1);
      expect(cubit.state.activeScreenIndex, equals(0));
      expect(cubit.state.lastAuthError, contains('Please sign in'));

      // 7. Dashboard no longer shows previous user or pre-stored user details after logout
      await tester.pumpAndSettle();
      expect(find.text('CPL-EMP-2050'), findsNothing);
      expect(find.text('Hamza Ali'), findsNothing);
      expect(find.text('CPL-EMP-1001'), findsNothing);
      expect(find.text('Engr. Tariq Khan'), findsNothing);
      expect(find.text('NOT SIGNED IN'), findsOneWidget);
      expect(find.text('Not Signed In'), findsOneWidget);
    });

    testWidgets('Shows All Plant Zones Clear emerald banner when hazards list is empty', (tester) async {
      final cubit = CplSystemCubit();
      cubit.emit(cubit.state.copyWith(hazards: const []));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CplSystemCubit>.value(
            value: cubit,
            child: const Scaffold(body: DashboardScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('All Plant Zones Clear — No Active Hazards'), findsOneWidget);
    });
  });
}
