import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/cpl_theme.dart';
import '../utils/pdf_generator.dart';
import '../utils/csv_exporter.dart';
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: CplColors.slate800)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: CplColors.safety500,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CPL',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 16,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Chiniot Power',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  '62.4 MW Co-Gen HSE',
                                  style: TextStyle(color: CplColors.slate400, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                            backgroundColor: CplColors.safety500,
                            child: Text(
                              user.empId.substring(user.empId.length - 2),
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  user.role,
                                  style: const TextStyle(color: CplColors.slate400, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
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

                    // Top 4-Column KPI Strip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      decoration: BoxDecoration(
                        color: CplColors.slate100,
                        border: Border(bottom: BorderSide(color: CplColors.slate200)),
                      ),
                      child: Row(
                        children: [
                          _buildKpiCard('218 Safe Work Days', 'Zero LTI • 3.84M Man-Hours', Icons.security, CplColors.slate900),
                          const SizedBox(width: 12),
                          _buildKpiCard('148 / 148 Muster Roll', '100% Shift Accounted', Icons.people, CplColors.emerald500),
                          const SizedBox(width: 12),
                          _buildKpiCard('3 Active PTW & LOTO', '14 Safety Padlocks Live', Icons.lock_clock, CplColors.safety500),
                          const SizedBox(width: 12),
                          _buildKpiCard('96.2% CAPA Closure', '3 Open Corrective Actions', Icons.task_alt, const Color(0xFF8B5CF6)),
                        ],
                      ),
                    ),

                    // Main View Area (Active Screen or 3-Column Command Grid on Dashboard)
                    Expanded(
                      child: activeIdx == 1
                          ? _buildDesktop3ColumnGrid(context, state, isUr)
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

  Widget _buildDesktop3ColumnGrid(BuildContext context, CplSystemState state, bool isUr) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideDesktop = constraints.maxWidth >= 1400;
        final col1 = _buildStaffApprovalsCol(context, state);
        final col2 = _buildCheckpointsCol(context, state);
        final col3 = _buildLiveHazardsCol(context, state);

        if (isWideDesktop) {
          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: col1),
                  const SizedBox(width: 16),
                  Expanded(child: col2),
                  const SizedBox(width: 16),
                  Expanded(child: col3),
                ],
              ),
            ),
          );
        } else {
          // Standard Laptop Responsive 2-column + 1-row layout
          return Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: col1),
                      const SizedBox(width: 16),
                      Expanded(child: col2),
                    ],
                  ),
                  const SizedBox(height: 16),
                  col3,
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildStaffApprovalsCol(BuildContext context, CplSystemState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CplColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Staff ID Approvals',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CplColors.safety500.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.pendingUsers.where((u) => u.status == 'Pending').length} Pending',
                  style: const TextStyle(color: CplColors.safety500, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...state.pendingUsers.take(3).map((u) {
            final isPending = u.status == 'Pending';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CplColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CplColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(u.empId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace')),
                      Text(u.status, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: isPending ? CplColors.amber500 : CplColors.emerald500)),
                    ],
                  ),
                  Text(u.name, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  Text('${u.role} • ${u.shift}', style: TextStyle(fontSize: 11, color: CplColors.slate600)),
                  if (isPending) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<CplSystemCubit>().updateUserApproval(u.empId, 'Approved');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: CplColors.emerald500,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            elevation: 0,
                          ),
                          child: const Text('Approve', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCheckpointsCol(BuildContext context, CplSystemState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CplColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Shift Checkpoints',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CplColors.emerald500.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.checklistItems.length} Deployed',
                  style: const TextStyle(color: CplColors.emerald500, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...state.checklistItems.take(3).map((item) {
            final isFail = item.status == 'fail';
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isFail ? CplColors.red600.withOpacity(0.06) : CplColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isFail ? CplColors.red600.withOpacity(0.3) : CplColors.slate200,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Checkpoint #${item.id}', style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isFail ? CplColors.red600 : CplColors.emerald500,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          item.status.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(item.en, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                  Text(item.ur, style: TextStyle(fontSize: 11, color: CplColors.slate600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildLiveHazardsCol(BuildContext context, CplSystemState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CplColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Live Hazards & Gateway',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: CplColors.red600.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${state.hazards.length} Logged',
                  style: const TextStyle(color: CplColors.red600, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(height: 18),
          ...state.hazards.take(3).map((h) {
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: CplColors.slate50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: CplColors.slate200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(h.id, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace')),
                      Text(h.time, style: TextStyle(fontSize: 10.5, color: CplColors.slate600)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(h.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text('${h.zone} • ${h.reporter}', style: TextStyle(fontSize: 10.5, color: CplColors.slate600)),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

