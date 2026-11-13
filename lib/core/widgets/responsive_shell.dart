import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/cpl_theme.dart';
import 'cpl_brand_logo.dart';
import '../../features/cpl_system/cubit/cpl_system_cubit.dart';
import '../../features/cpl_system/cubit/cpl_system_state.dart';
import '../../features/screens/auth_screen.dart';
import '../../features/screens/dashboard_screen.dart';
import '../../features/screens/hazard_report_screen.dart';
import '../../features/screens/risk_matrix_screen.dart';
import '../../features/screens/checklist_screen.dart';
import '../../features/screens/ptw_screen.dart';
import '../../features/screens/alarm_center_screen.dart';
import '../../features/screens/training_screen.dart';
import '../../features/screens/roster_screen.dart';
import '../../features/screens/analytics_screen.dart';
import '../../features/screens/admin_panel_screen.dart';
import 'desktop_command_center.dart';

class ResponsiveShell extends StatelessWidget {
  const ResponsiveShell({super.key});

  Widget _getScreenByIndex(int index) {
    switch (index) {
      case 0: return const AuthScreen();
      case 1: return const DashboardScreen();
      case 2: return const HazardReportScreen();
      case 3: return const RiskMatrixScreen();
      case 4: return const ChecklistScreen();
      case 5: return const PtwScreen();
      case 6: return const AlarmCenterScreen();
      case 7: return const TrainingScreen();
      case 8: return const RosterScreen();
      case 9: return const AnalyticsScreen();
      case 10: return const AdminPanelScreen();
      default: return const DashboardScreen();
    }
  }

  void _showAllModulesDrawer(BuildContext context, bool isUr) {
    final modules = [
      {'title': '01. Staff Login & Reg', 'ur': 'لاگ ان اور رجسٹریشن', 'icon': Icons.lock_person, 'index': 0},
      {'title': '02. CPL Plant Dashboard', 'ur': 'پلانٹ ہوم ڈیش بورڈ', 'icon': Icons.dashboard, 'index': 1},
      {'title': '03. Hazard & Risk Report', 'ur': 'خطرہ و نقص رپورٹ', 'icon': Icons.report_problem, 'index': 2},
      {'title': '04. 5×5 Risk Matrix & CAPA', 'ur': '5×5 رسک میٹرکس', 'icon': Icons.grid_view, 'index': 3},
      {'title': '05. Safety Audit Checklist', 'ur': 'روزانہ حفاظتی چیک لسٹ', 'icon': Icons.checklist, 'index': 4},
      {'title': '06. Permit to Work & LOTO', 'ur': 'پرمٹ ٹو ورک اور LOTO', 'icon': Icons.lock_clock, 'index': 5},
      {'title': '07. Siren & Emergency Alert', 'ur': 'ایمرجنسی سائرن سینٹر', 'icon': Icons.campaign, 'index': 6},
      {'title': '08. Safety Training & QR Pass', 'ur': 'سیفٹی ٹریننگ اور کیو آر', 'icon': Icons.school, 'index': 7},
      {'title': '09. Team Roster & PPE Roll', 'ur': 'ٹیم روسٹر اور پی پی ای', 'icon': Icons.groups, 'index': 8},
      {'title': '10. Analytics & Executive Reports', 'ur': 'اینالیٹکس اور پی ڈی ایف', 'icon': Icons.bar_chart, 'index': 9},
      {'title': '11. Manager & Admin Panel', 'ur': 'ایڈمن اور مینیجر پینل', 'icon': Icons.admin_panel_settings, 'index': 10},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUr ? 'تمام 11 سیفٹی ماڈیولز' : 'All 11 CPL HSE Modules',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Chiniot Power Limited (62.4 MW)',
                        style: TextStyle(fontSize: 12, color: CplColors.slate600),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: modules.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final item = modules[idx];
                    final targetIdx = item['index'] as int;

                    return ListTile(
                      dense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: CplColors.slate100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'] as IconData, size: 20, color: CplColors.slate800),
                      ),
                      title: Text(
                        isUr ? item['ur'] as String : item['title'] as String,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: CplColors.slate400),
                      onTap: () {
                        Navigator.pop(ctx);
                        context.read<CplSystemCubit>().setScreenIndex(targetIdx);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Large screen breakpoint
        if (constraints.maxWidth >= 1024) {
          return const DesktopCommandCenter();
        }

        // Mobile & Tablet Layout
        return BlocBuilder<CplSystemCubit, CplSystemState>(
          builder: (context, state) {
            final isUr = state.isUrdu;
            final activeIdx = state.activeScreenIndex;
            final user = state.currentUser;

            return Directionality(
              textDirection: isUr ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: CplColors.slate50,
                resizeToAvoidBottomInset: true,
                // Mobile Top Header
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Container(
                    color: CplColors.slate900,
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 6,
                      left: 12,
                      right: 12,
                      bottom: 8,
                    ),
                    child: Row(
                      children: [
                        // CPL Official Brand Logo
                        const CplBrandLogo(
                          height: 26,
                          isDark: true,
                          showSubtitle: false,
                        ),
                        const SizedBox(width: 8),

                        // Live Status Pill
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: CplColors.emerald500,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'UNIT-1 62.4 MW',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),

                        // Employee ID Tag (or Not Signed In indicator)
                        Text(
                          state.isAuthenticated
                              ? user.empId
                              : (isUr ? 'لاگ ان درکار ہے' : 'SIGN IN REQUIRED'),
                          style: TextStyle(
                            color: state.isAuthenticated ? CplColors.slate300 : CplColors.amber500,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                        const SizedBox(width: 8),

                        // 1-Tap Bilingual Language Toggle Chip
                        InkWell(
                          onTap: () => context.read<CplSystemCubit>().toggleLanguage(),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: CplColors.safety500.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: CplColors.safety500.withOpacity(0.5)),
                            ),
                            child: Text(
                              isUr ? 'اردو' : 'EN',
                              style: const TextStyle(
                                color: CplColors.safety500,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Active Screen Body with Persistent Offline Sync Banner
                body: Column(
                  children: [
                    if (state.pendingOfflineCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        color: CplColors.amber500,
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isUr
                                    ? '${state.pendingOfflineCount} رپورٹس آف لائن ہیں — سگنل پر خودکار سنک ہوں گی'
                                    : '${state.pendingOfflineCount} Reports in Offline Queue — will auto-sync on signal',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            InkWell(
                              onTap: () => context.read<CplSystemCubit>().syncOfflineNow(),
                              borderRadius: BorderRadius.circular(6),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  isUr ? 'ابھی سنک کریں' : 'Sync Now',
                                  style: const TextStyle(
                                    color: CplColors.slate900,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: state.isAuthenticated
                          ? _getScreenByIndex(activeIdx)
                          : const AuthScreen(),
                    ),
                  ],
                ),

              // Raised Safety Amber Floating Action Button for Instant Hazard Reporting (only when signed in)
              floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
              floatingActionButton: state.isAuthenticated
                  ? FloatingActionButton(
                      onPressed: () {
                        context.read<CplSystemCubit>().setScreenIndex(2); // Screen 03: Hazard Report
                      },
                      backgroundColor: CplColors.safety500,
                      elevation: 4,
                      child: const Icon(Icons.add, size: 30, color: Colors.white),
                    )
                  : null,

              // Mobile Bottom Navigation Bar (hidden when logged out so unauthenticated users cannot jump to Dashboard)
              bottomNavigationBar: state.isAuthenticated
                  ? BottomAppBar(
                      shape: const CircularNotchedRectangle(),
                      notchMargin: 6,
                      color: Colors.white,
                      elevation: 10,
                      child: SizedBox(
                        height: 56,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // Home Tab
                            _buildBottomNavItem(
                              context,
                              icon: Icons.home,
                              label: isUr ? 'ہوم' : 'Home',
                              isSelected: activeIdx == 1,
                              onTap: () => context.read<CplSystemCubit>().setScreenIndex(1),
                            ),
                            // Audit Tab
                            _buildBottomNavItem(
                              context,
                              icon: Icons.checklist,
                              label: isUr ? 'آڈٹ' : 'Audit',
                              isSelected: activeIdx == 4,
                              onTap: () => context.read<CplSystemCubit>().setScreenIndex(4),
                            ),
                            const SizedBox(width: 44), // Space for centered raised FAB
                            // PTW Tab
                            _buildBottomNavItem(
                              context,
                              icon: Icons.lock_clock,
                              label: isUr ? 'پرمٹ' : 'PTW',
                              isSelected: activeIdx == 5,
                              onTap: () => context.read<CplSystemCubit>().setScreenIndex(5),
                            ),
                            // All (11) Modules Drawer Tab
                            _buildBottomNavItem(
                              context,
                              icon: Icons.grid_view,
                              label: isUr ? 'تمام (11)' : 'All (11)',
                              isSelected: activeIdx > 5 || activeIdx == 0 || activeIdx == 3,
                              onTap: () => _showAllModulesDrawer(context, isUr),
                            ),
                          ],
                        ),
                      ),
                    )
                  : null,
            ),
          );
        },
      );
    },
  );
  }

  Widget _buildBottomNavItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? CplColors.safety500 : CplColors.slate400,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? CplColors.safety500 : CplColors.slate600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

