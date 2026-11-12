import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chiniot_power_hse/features/cpl_system/cubit/cpl_system_cubit.dart';
import 'package:chiniot_power_hse/features/cpl_system/models/cpl_models.dart';
import 'package:chiniot_power_hse/features/screens/dashboard_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Dynamic Dashboard and User Lifecycle Widget Tests', () {
    testWidgets('Dashboard dynamically displays Bilal Khan profile, BK avatar initials, and live counters', (tester) async {
      final cubit = CplSystemCubit();

      // 1. Register a new user
      await cubit.signup(
        empId: 'CPL-EMP-2001',
        fullName: 'Bilal Khan',
        cnic: '33202-9876543-1',
        shift: 'Shift B: Evening (14:00 - 22:00)',
        role: 'Plant Worker',
        pin: '2001',
      );

      // Verify pending registration
      expect(cubit.state.pendingUsers.any((u) => u.empId == 'CPL-EMP-2001' && u.status == 'Pending'), isTrue);

      // 2. Admin approves the user
      await cubit.updateUserApproval('CPL-EMP-2001', 'Approved');
      expect(cubit.state.pendingUsers.any((u) => u.empId == 'CPL-EMP-2001' && u.status == 'Approved'), isTrue);
      expect(cubit.state.roster.any((w) => w.empId == 'CPL-EMP-2001'), isTrue);

      // 3. Newly approved user logs in
      await cubit.login(
        empId: 'CPL-EMP-2001',
        shift: 'Shift B: Evening (14:00 - 22:00)',
        role: 'Plant Worker',
        pin: '2001',
      );

      expect(cubit.state.currentUser.name, equals('Bilal Khan'));
      expect(cubit.state.currentUser.empId, equals('CPL-EMP-2001'));
      expect(cubit.state.currentUser.role, equals('Plant Worker'));

      // 4. Render DashboardScreen
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CplSystemCubit>.value(
            value: cubit,
            child: const Scaffold(body: DashboardScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Dynamic Profile and Avatar Initials
      expect(find.text('BK'), findsOneWidget); // Initials for Bilal Khan (NOT 'MT'!)
      expect(find.text('MT'), findsNothing); // Hardcoded 'MT' must NOT exist
      expect(find.text('Bilal Khan'), findsOneWidget);
      expect(find.text('CPL-EMP-2001'), findsOneWidget);
      expect(find.textContaining('Plant Worker'), findsWidgets);

      // Verify zero hardcoded mock values on dashboard
      expect(find.text('218'), findsNothing); // Hardcoded safe work days removed
      expect(find.text('97.2%'), findsNothing); // Hardcoded compliance removed
      expect(find.text('148/148 PPE Verified'), findsNothing); // Hardcoded PPE verified removed
    });

    testWidgets('Dashboard dynamically displays Zeeshan Ahmed profile and ZA avatar initials', (tester) async {
      final cubit = CplSystemCubit();

      await cubit.login(
        empId: 'CPL-EMP-1088',
        shift: 'Shift A: Morning (06:00 - 14:00)',
        role: 'Plant Worker',
        pin: '1088',
      );

      expect(cubit.state.currentUser.name, equals('Zeeshan Ahmed'));
      expect(cubit.state.currentUser.empId, equals('CPL-EMP-1088'));

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<CplSystemCubit>.value(
            value: cubit,
            child: const Scaffold(body: DashboardScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('ZA'), findsOneWidget); // Initials for Zeeshan Ahmed
      expect(find.text('MT'), findsNothing);
      expect(find.text('Zeeshan Ahmed'), findsOneWidget);
      expect(find.text('CPL-EMP-1088'), findsOneWidget);
    });
  });
}

