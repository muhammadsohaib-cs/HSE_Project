import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/cpl_theme.dart';
import '../utils/pdf_generator.dart';
import '../widgets/cpl_brand_logo.dart';
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

class DesktopCommandCenter extends StatelessWidget {
  const DesktopCommandCenter({super.key});

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

  final List<Map<String, dynamic>> _navItems = const [
    {'title': '01. Staff Login', 'ur': 'لاگ ان', 'icon': Icons.lock_person, 'index': 0},
    {'title': '02. Dashboard', 'ur': 'ڈیش بورڈ', 'icon': Icons.dashboard, 'index': 1},
    {'title': '03. Hazard Report', 'ur': 'خطرہ رپورٹ', 'icon': Icons.report_problem, 'index': 2},
    {'title': '04. 5×5 Risk Matrix', 'ur': 'رسک میٹرکس', 'icon': Icons.grid_view, 'index': 3},
    {'title': '05. Safety Checklist', 'ur': 'چیک لسٹ', 'icon': Icons.checklist, 'index': 4},
    {'title': '06. PTW & LOTO', 'ur': 'پرمٹ ٹو ورک', 'icon': Icons.lock_clock, 'index': 5},
    {'title': '07. Siren Dispatch', 'ur': 'سائرن الرٹ', 'icon': Icons.campaign, 'index': 6},
    {'title': '08. Training & QR', 'ur': 'سیفٹی ٹریننگ', 'icon': Icons.school, 'index': 7},
    {'title': '09. Team Roster', 'ur': 'روسٹر پی پی ای', 'icon': Icons.groups, 'index': 8},
    {'title': '10. Safety Analytics', 'ur': 'اینالیٹکس', 'icon': Icons.bar_chart, 'index': 9},
    {'title': '11. Admin Panel', 'ur': 'ایڈمن کنٹرول', 'icon': Icons.admin_panel_settings, 'index': 10},
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final activeIdx = state.activeScreenIndex;
        final user = state.currentUser;

        return Directionality(
          textDirection: isUr ? TextDirection.rtl : TextDirection.ltr,
          child: Scaffold(
            backgroundColor: CplColors.slate50,
            body: Row(
            children: [
              // Persistent Left Sidebar (NavigationRail / Drawer)
              Container(
                width: 250,
                color: CplColors.slate900,
                child: Column(
                  children: [
                    // Brand Header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: CplColors.slate800)),
                      ),
                      child: const CplBrandLogo(
                        height: 36,
                        isDark: true,
                        showSubtitle: true,
                      ),
                    ),
                    // Navigation List
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        children: _navItems.map((item) {
                          final idx = item['index'] as int;
                          final isSelected = activeIdx == idx;

                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected ? CplColors.safety500 : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: ListTile(
                                dense: true,
                                leading: Icon(
                                  item['icon'] as IconData,
                                  color: isSelected ? Colors.white : CplColors.slate400,
                                  size: 18,
                                ),
                                title: Text(
                                  isUr ? item['ur'] as String : item['title'] as String,
                                  style: TextStyle(
                                    color: isSelected ? Colors.white : CplColors.slate300,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    fontSize: 12.5,
                                  ),
                                ),
                                onTap: () {
                                  context.read<CplSystemCubit>().setScreenIndex(idx);
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Current User Pill
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        border: Border(top: BorderSide(color: CplColors.slate800)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: state.isAuthenticated ? CplColors.safety500 : CplColors.slate700,
                            child: Text(
                              state.isAuthenticated && user.empId.length >= 2
                                  ? user.empId.substring(user.empId.length - 2)
                                  : '--',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  state.isAuthenticated ? user.name : (isUr ? 'لاگ ان نہیں ہے' : 'Not Signed In'),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  state.isAuthenticated
                                      ? '${user.empId} • ${user.role}'
                                      : (isUr ? 'براہ کرم لاگ ان کریں' : 'Sign in required'),
                                  style: const TextStyle(color: CplColors.slate400, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (state.isAuthenticated)
                            IconButton(
                              constraints: const BoxConstraints(),
                              padding: const EdgeInsets.all(4),
                              icon: const Icon(Icons.logout, size: 16, color: CplColors.red600),
                              tooltip: isUr ? 'لاگ آؤٹ' : 'Logout',
                              onPressed: () => context.read<CplSystemCubit>().logout(),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content Area
              Expanded(
                child: Column(
                  children: [
                    // Top Desktop Command Bar
                    Container(
                      height: 64,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        border: Border(bottom: BorderSide(color: CplColors.slate200)),
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            // Plant title & live coordinates
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: CplColors.emerald500,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'UNIT-1 62.4 MW • Co-Gen Online',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: CplColors.slate100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    '31.7204° N, 72.9791° E (Chiniot, Punjab)',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontFamily: 'monospace',
                                      color: CplColors.slate700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),

                            // Test Plant Siren CTA
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<CplSystemCubit>().triggerPlantAlarm('PLANT-WIDE SIREN TEST');
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Desktop Test Siren Active. Buzzer audio sounding.'),
                                    backgroundColor: CplColors.red600,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.warning, size: 16),
                              label: const Text('Test Plant Siren', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CplColors.red600,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 10),

                            // Export Master Report CTA
                            ElevatedButton.icon(
                              onPressed: () async {
                                final pdfBytes = await PdfReportGenerator.generateShiftTurnoverPdf(
                                  plantUnit: 'UNIT-1 62.4 MW Co-Gen',
                                  shiftType: state.currentUser.shift,
                                  outgoingSupervisor: state.currentUser.name,
                                  checklistsCompleted: state.checklistItems.length,
                                  hazardsIdentified: state.hazards.length,
                                  criticalAlarmsCount: state.activeAlarm != null ? 1 : 0,
                                  openItems: state.hazards
                                      .take(4)
                                      .map((h) => {'title': h.title, 'owner': h.reporter})
                                      .toList(),
                                );
                                final savedPath = await PdfReportGenerator.saveOrShareReport(
                                  pdfBytes,
                                  'CPL_NEPRA_ISO_Audit_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
                                );
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('NEPRA / ISO 45001 Master Audit Report Saved: $savedPath'),
                                      backgroundColor: CplColors.emerald500,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.download, size: 16),
                              label: const Text('Export Master Report', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CplColors.emerald500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Language Toggle Chip
                            InkWell(
                              onTap: () => context.read<CplSystemCubit>().toggleLanguage(),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: CplColors.slate100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: CplColors.slate200),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.language, size: 16, color: CplColors.slate700),
                                    const SizedBox(width: 6),
                                    Text(
                                      isUr ? 'اردو (UR)' : 'EN / اردو',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Persistent Top Offline Sync Banner for Desktop
                    if (state.pendingOfflineCount > 0)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                        color: CplColors.amber500,
                        child: Row(
                          children: [
                            const Icon(Icons.cloud_off, color: Colors.white, size: 16),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                isUr
                                    ? '${state.pendingOfflineCount} رپورٹس آف لائن ہیں — نیٹ ورک سگنل ملنے پر سنک ہو جائیں گی'
                                    : '${state.pendingOfflineCount} Reports Queued in Offline Storage — will auto-sync on connection',
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => context.read<CplSystemCubit>().syncOfflineNow(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: CplColors.slate900,
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                elevation: 0,
                              ),
                              child: Text(
                                isUr ? 'ابھی سنک کریں' : 'Sync Now',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Top 4-Column Live KPI Strip (only shown when authenticated)
                    if (state.isAuthenticated)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        decoration: const BoxDecoration(
                          color: CplColors.slate100,
                          border: Border(bottom: BorderSide(color: CplColors.slate200)),
                        ),
                        child: Row(
                          children: [
                            _buildKpiCard(
                              '${state.hazards.where((h) => h.status.toLowerCase() != 'resolved' && h.status.toLowerCase() != 'closed').length} Open Hazards',
                              '${state.hazards.where((h) => h.severity.toLowerCase() == 'critical' && h.status.toLowerCase() != 'resolved').length} Critical Active',
                              Icons.warning_amber_rounded,
                              CplColors.safety500,
                            ),
                            const SizedBox(width: 12),
                            _buildKpiCard(
                              '${state.roster.where((w) => w.isFullPpe).length} / ${state.roster.length} On-Duty Roster',
                              'PPE Verified Staff',
                              Icons.people,
                              CplColors.emerald500,
                            ),
                            const SizedBox(width: 12),
                            _buildKpiCard(
                              '${state.permits.where((p) => p.status.toLowerCase() == 'active').length} Active PTW & LOTO',
                              '${state.permits.where((p) => p.status.toLowerCase() == 'pending').length} Pending Approval',
                              Icons.lock_clock,
                              CplColors.corporateNavy,
                            ),
                            const SizedBox(width: 12),
                            _buildKpiCard(
                              '${state.checklistItems.where((c) => c.status.toLowerCase() == 'pass').length}/${state.checklistItems.length} Shift Checklist',
                              state.checklistZone,
                              Icons.fact_check_outlined,
                              const Color(0xFF8B5CF6),
                            ),
                          ],
                        ),
                      ),

                    // Main View Area (Enforce AuthScreen when logged out)
                    Expanded(
                      child: !state.isAuthenticated
                          ? const AuthScreen()
                          : _getScreenByIndex(activeIdx),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      },
    );
  }

  Widget _buildKpiCard(String title, String subtitle, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CplColors.slate200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 10.5, color: CplColors.slate600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

