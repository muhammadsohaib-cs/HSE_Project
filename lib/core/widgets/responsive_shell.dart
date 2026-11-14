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
      case 0:
        return const AuthScreen();
      case 1:
        return const DashboardScreen();
      case 2:
        return const HazardReportScreen();
      case 3:
        return const RiskMatrixScreen();
      case 4:
        return const ChecklistScreen();
      case 5:
        return const PtwScreen();
      case 6:
        return const AlarmCenterScreen();
      case 7:
        return const TrainingScreen();
      case 8:
        return const RosterScreen();
      case 9:
        return const AnalyticsScreen();
      case 10:
        return const AdminPanelScreen();
      default:
        return const DashboardScreen();
    }
  }

  static const List<Map<String, dynamic>> _modules = [
    {'title': 'Plant Dashboard', 'ur': 'پلانٹ ہوم ڈیش بورڈ', 'icon': Icons.dashboard_outlined, 'index': 1},
    {'title': 'Hazard & Near-Miss Report', 'ur': 'خطرہ و نیئر مس رپورٹ', 'icon': Icons.report_problem_outlined, 'index': 2},
    {'title': '5×5 Risk Matrix & CAPA', 'ur': '5×5 رسک میٹرکس اور CAPA', 'icon': Icons.grid_view_outlined, 'index': 3},
    {'title': 'Daily Safety Checklist', 'ur': 'روزانہ حفاظتی چیک لسٹ', 'icon': Icons.checklist_rtl_outlined, 'index': 4},
    {'title': 'Permit to Work & LOTO', 'ur': 'پرمٹ ٹو ورک اور LOTO', 'icon': Icons.lock_clock_outlined, 'index': 5},
    {'title': 'Emergency Siren Dispatch', 'ur': 'ایمرجنسی سائرن سینٹر', 'icon': Icons.campaign_outlined, 'index': 6},
    {'title': 'HSE Training & QR Pass', 'ur': 'سیفٹی ٹریننگ اور کیو آر', 'icon': Icons.school_outlined, 'index': 7},
    {'title': 'Shift Roster & PPE Roll', 'ur': 'ٹیم روسٹر اور پی پی ای', 'icon': Icons.groups_outlined, 'index': 8},
    {'title': 'Safety Analytics & Reports', 'ur': 'اینالیٹکس اور پی ڈی ایف', 'icon': Icons.bar_chart_outlined, 'index': 9},
    {'title': 'Admin & Manager Control', 'ur': 'ایڈمن اور مینیجر پینل', 'icon': Icons.admin_panel_settings_outlined, 'index': 10},
  ];

  Widget _buildHamburgerDrawer(BuildContext context, CplSystemState state, bool isUr) {
    final user = state.currentUser;
    final activeIdx = state.activeScreenIndex;

    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Drawer Header with CPL Branding & User Profile
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: CplColors.slate900,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CplBrandLogo(
                    height: 30,
                    isDark: true,
                    showSubtitle: true,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: CplColors.safety500,
                        child: Text(
                          user.name.isNotEmpty ? user.name[0].toUpperCase() : 'C',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${user.empId} • ${user.role}',
                              style: const TextStyle(color: CplColors.slate300, fontSize: 11, fontFamily: 'monospace'),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Navigation Modules List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _modules.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
                itemBuilder: (ctx, idx) {
                  final item = _modules[idx];
                  final targetIdx = item['index'] as int;
                  final isSelected = activeIdx == targetIdx;

                  return ListTile(
                    dense: true,
                    selected: isSelected,
                    selectedTileColor: CplColors.safety50,
                    leading: Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: isSelected ? CplColors.safety500 : CplColors.slate700,
                    ),
                    title: Text(
                      isUr ? item['ur'] as String : item['title'] as String,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 13,
                        color: isSelected ? CplColors.safety600 : CplColors.slate800,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 16, color: CplColors.slate400),
                    onTap: () {
                      Navigator.pop(ctx);
                      context.read<CplSystemCubit>().setScreenIndex(targetIdx);
                    },
                  );
                },
              ),
            ),

            // Sign Out Footer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: CplColors.slate200)),
              ),
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.read<CplSystemCubit>().logout();
                },
                icon: const Icon(Icons.logout, size: 16, color: CplColors.red600),
                label: Text(
                  isUr ? 'لاگ آؤٹ کریں' : 'Sign Out',
                  style: const TextStyle(color: CplColors.red600, fontWeight: FontWeight.bold),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: CplColors.red600),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Desktop / Laptop screen breakpoint
        if (constraints.maxWidth >= 900) {
          return const DesktopCommandCenter();
        }

        // Mobile & Tablet Layout with Hamburger Drawer + Top Nav + Bottom Bar
        return BlocBuilder<CplSystemCubit, CplSystemState>(
          builder: (context, state) {
            final isUr = state.isUrdu;
            final activeIdx = state.activeScreenIndex;
            final user = state.currentUser;
            final isAuth = state.isAuthenticated;

            return Directionality(
              textDirection: isUr ? TextDirection.rtl : TextDirection.ltr,
              child: Scaffold(
                backgroundColor: CplColors.slate50,
                resizeToAvoidBottomInset: true,
                drawer: isAuth ? _buildHamburgerDrawer(context, state, isUr) : null,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(60),
                  child: Builder(
                    builder: (scaffoldCtx) => Container(
                      color: CplColors.slate900,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 6,
                        left: 8,
                        right: 12,
                        bottom: 8,
                      ),
                      child: Row(
                        children: [
                          if (isAuth)
                            IconButton(
                              icon: const Icon(Icons.menu, color: Colors.white, size: 22),
                              tooltip: isUr ? 'مینو' : 'Open Navigation Menu',
                              onPressed: () => Scaffold.of(scaffoldCtx).openDrawer(),
                            ),
                          const CplBrandLogo(
                            height: 26,
                            isDark: true,
                            showSubtitle: false,
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha((0.1 * 255).round()),
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
                          if (isAuth)
                            Text(
                              user.empId,
                              style: const TextStyle(
                                color: CplColors.slate300,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'monospace',
                              ),
                            ),
                          const SizedBox(width: 8),
                          InkWell(
                            onTap: () => context.read<CplSystemCubit>().toggleLanguage(),
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: CplColors.safety500.withAlpha((0.2 * 255).round()),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: CplColors.safety500.withAlpha((0.5 * 255).round())),
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
                ),
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
                      child: isAuth
                          ? _getScreenByIndex(activeIdx)
                          : const AuthScreen(),
                    ),
                  ],
                ),
                floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
                floatingActionButton: isAuth
                    ? FloatingActionButton(
                        onPressed: () {
                          context.read<CplSystemCubit>().setScreenIndex(2);
                        },
                        backgroundColor: CplColors.safety500,
                        elevation: 4,
                        child: const Icon(Icons.add, size: 30, color: Colors.white),
                      )
                    : null,
                bottomNavigationBar: isAuth
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
                              _buildBottomNavItem(
                                context,
                                icon: Icons.home,
                                label: isUr ? 'ہوم' : 'Home',
                                isSelected: activeIdx == 1,
                                onTap: () => context.read<CplSystemCubit>().setScreenIndex(1),
                              ),
                              _buildBottomNavItem(
                                context,
                                icon: Icons.checklist,
                                label: isUr ? 'آڈٹ' : 'Audit',
                                isSelected: activeIdx == 4,
                                onTap: () => context.read<CplSystemCubit>().setScreenIndex(4),
                              ),
                              const SizedBox(width: 44),
                              _buildBottomNavItem(
                                context,
                                icon: Icons.lock_clock,
                                label: isUr ? 'پرمٹ' : 'PTW',
                                isSelected: activeIdx == 5,
                                onTap: () => context.read<CplSystemCubit>().setScreenIndex(5),
                              ),
                              Builder(
                                builder: (scaffoldCtx) => _buildBottomNavItem(
                                  context,
                                  icon: Icons.menu,
                                  label: isUr ? 'مینو' : 'Menu',
                                  isSelected: activeIdx > 5 || activeIdx == 0 || activeIdx == 3,
                                  onTap: () => Scaffold.of(scaffoldCtx).openDrawer(),
                                ),
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
