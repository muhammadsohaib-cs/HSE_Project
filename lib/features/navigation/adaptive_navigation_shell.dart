import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/app_colors.dart';
import '../../core/platform/platform_helper.dart';
import '../auth/presentation/cubit/auth_cubit.dart';
import '../auth/presentation/cubit/auth_state.dart';
import '../checklists/presentation/pages/checklists_page.dart';
import '../dashboard/presentation/pages/dashboard_page.dart';
import '../emergency_alarms/presentation/pages/alarm_dispatch_page.dart';
import '../hazards/presentation/pages/hazards_list_page.dart';
import '../training/presentation/pages/training_tracker_page.dart';

class AdaptiveNavigationShell extends StatefulWidget {
  const AdaptiveNavigationShell({super.key});

  @override
  State<AdaptiveNavigationShell> createState() => _AdaptiveNavigationShellState();
}

class _AdaptiveNavigationShellState extends State<AdaptiveNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    DashboardPage(),
    HazardsListPage(),
    ChecklistsPage(),
    AlarmDispatchPage(),
    TrainingTrackerPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktopLayout = PlatformHelper.isDesktop || width >= 900;
    final authState = context.watch<AuthCubit>().state;

    String userName = 'Plant Officer';
    String userRole = 'Field Worker';
    String empId = 'CP-EMP-XXXX';

    if (authState is Authenticated) {
      userName = authState.user.name;
      userRole = authState.user.role.title;
      empId = authState.user.employeeId;
    }

    if (isDesktopLayout) {
      return Scaffold(
        body: Row(
          children: [
            // Desktop Side Navigation Rail
            NavigationRail(
              selectedIndex: _currentIndex,
              extended: width >= 1200,
              minExtendedWidth: 220,
              onDestinationSelected: (index) {
                setState(() => _currentIndex = index);
              },
              leading: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight.withAlpha((0.2 * 255).round()),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.bolt, color: AppColors.primaryLight, size: 28),
                    ),
                    if (width >= 1200) ...[
                      const SizedBox(height: 8),
                      const Text(
                        'CHINIOT POWER',
                        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2),
                      ),
                      const Text(
                        'HSE Management',
                        style: TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ],
                ),
              ),
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (width >= 1200)
                          Container(
                            padding: const EdgeInsets.all(12),
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.borderDark),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '$userRole • $empId',
                                  style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.logout_rounded, color: AppColors.textSecondaryDark),
                          tooltip: 'Sign Out',
                          onPressed: () => context.read<AuthCubit>().logout(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primaryLight),
                  label: Text('Dashboard'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.report_problem_outlined),
                  selectedIcon: Icon(Icons.report_problem_rounded, color: AppColors.riskHigh),
                  label: Text('Hazards & CAPA'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.checklist_rtl_outlined),
                  selectedIcon: Icon(Icons.checklist_rtl_rounded, color: AppColors.riskLow),
                  label: Text('Checklists'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.campaign_outlined),
                  selectedIcon: Icon(Icons.campaign_rounded, color: AppColors.emergencyRed),
                  label: Text('Emergency Alarms'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.school_outlined),
                  selectedIcon: Icon(Icons.school_rounded, color: Colors.purpleAccent),
                  label: Text('Safety Training'),
                ),
              ],
            ),
            const VerticalDivider(thickness: 1, width: 1, color: AppColors.borderDark),

            // Main Active Page View
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
            ),
          ],
        ),
      );
    }

    // Mobile Layout: Bottom NavigationBar
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() => _currentIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard_rounded),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.report_problem_outlined),
            selectedIcon: Icon(Icons.report_problem_rounded),
            label: 'Hazards',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_rtl_outlined),
            selectedIcon: Icon(Icons.checklist_rtl_rounded),
            label: 'Checklists',
          ),
          NavigationDestination(
            icon: Icon(Icons.campaign_outlined),
            selectedIcon: Icon(Icons.campaign_rounded),
            label: 'Alarms',
          ),
          NavigationDestination(
            icon: Icon(Icons.school_outlined),
            selectedIcon: Icon(Icons.school_rounded),
            label: 'Training',
          ),
        ],
      ),
    );
  }
}

