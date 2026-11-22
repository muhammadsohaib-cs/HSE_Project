import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import '../theme/cpl_theme.dart';
import '../utils/pdf_generator.dart';
import '../widgets/cpl_brand_logo.dart';
import '../widgets/cpl_user_avatar.dart';
import '../../features/cpl_system/cubit/cpl_system_cubit.dart';
import '../../features/cpl_system/cubit/cpl_system_state.dart';
import '../../features/cpl_system/models/cpl_models.dart';
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
import '../../features/screens/profile_screen.dart';

class DesktopCommandCenter extends StatefulWidget {
  const DesktopCommandCenter({super.key});

  @override
  State<DesktopCommandCenter> createState() => _DesktopCommandCenterState();
}

class _DesktopCommandCenterState extends State<DesktopCommandCenter> {
  bool _isSidebarExpanded = true;

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
      case 11:
        return const ProfileScreen();
      default:
        return const DashboardScreen();
    }
  }

  static const List<Map<String, dynamic>> _topNavLinks = [
    {'title': 'Dashboard', 'ur': 'ڈیش بورڈ', 'icon': LucideIcons.layoutDashboard, 'index': 1},
    {'title': 'Hazards', 'ur': 'خطرات', 'icon': LucideIcons.triangleAlert, 'index': 2},
    {'title': 'Risk & CAPA', 'ur': 'رسک میٹرکس', 'icon': LucideIcons.grid3x3, 'index': 3},
    {'title': 'Checklists', 'ur': 'چیک لسٹ', 'icon': LucideIcons.clipboardCheck, 'index': 4},
    {'title': 'PTW & LOTO', 'ur': 'ورک پرمٹ', 'icon': LucideIcons.lock, 'index': 5},
    {'title': 'Roster', 'ur': 'روسٹر', 'icon': LucideIcons.users, 'index': 8},
    {'title': 'Analytics', 'ur': 'اینالیٹکس', 'icon': LucideIcons.barChart3, 'index': 9},
  ];

  String _getUserInitials(String name) {
    final clean = name
        .replaceAll(RegExp(r'^(Engr\.|Dr\.|Mr\.|Ms\.|Mrs\.)\s*', caseSensitive: false), '')
        .trim();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'CP';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  static const List<Map<String, dynamic>> _drawerSections = [
    {
      'section': 'OVERVIEW & ANALYTICS',
      'sectionUr': 'عمومی جائزہ اور رپورٹس',
      'items': [
        {'title': 'Plant Dashboard', 'ur': 'پلانٹ ہوم ڈیش بورڈ', 'icon': LucideIcons.layoutDashboard, 'index': 1},
        {'title': 'Safety Analytics', 'ur': 'سیفٹی اینالیٹکس اور رپورٹس', 'icon': LucideIcons.barChart3, 'index': 9},
      ],
    },
    {
      'section': 'FIELD SAFETY & COMPLIANCE',
      'sectionUr': 'فیلڈ سیفٹی اور تعمیل',
      'items': [
        {'title': 'Hazard & Near-Miss', 'ur': 'خطرہ اور نیئر مس رپورٹ', 'icon': LucideIcons.triangleAlert, 'index': 2},
        {'title': '5×5 Risk & CAPA', 'ur': '5×5 رسک میٹرکس اور CAPA', 'icon': LucideIcons.grid3x3, 'index': 3},
        {'title': 'Daily Safety Checklist', 'ur': 'روزانہ حفاظتی چیک لسٹ', 'icon': LucideIcons.clipboardCheck, 'index': 4},
        {'title': 'Permit to Work & LOTO', 'ur': 'پرمٹ ٹو ورک اور LOTO', 'icon': LucideIcons.lock, 'index': 5},
      ],
    },
    {
      'section': 'WORKFORCE & EMERGENCY',
      'sectionUr': 'عملہ اور ایمرجنسی',
      'items': [
        {'title': 'Shift Roster & PPE', 'ur': 'ٹیم روسٹر اور پی پی ای', 'icon': LucideIcons.users, 'index': 8},
        {'title': 'HSE Training & QR', 'ur': 'سیفٹی ٹریننگ اور کیو آر', 'icon': LucideIcons.graduationCap, 'index': 7},
        {'title': 'Emergency Siren Center', 'ur': 'ایمرجنسی سائرن سینٹر', 'icon': LucideIcons.siren, 'index': 6},
      ],
    },
    {
      'section': 'ACCOUNT & GOVERNANCE',
      'sectionUr': 'پروفائل اور ایڈمن گورننس',
      'items': [
        {'title': 'My Profile & Security', 'ur': 'میرا پروفائل اور پاس ورڈ', 'icon': LucideIcons.userCog, 'index': 11},
        {'title': 'Admin Control Panel', 'ur': 'ایڈمن اور مینیجر پینل', 'icon': LucideIcons.shieldAlert, 'index': 10},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final activeIdx = state.activeScreenIndex;
        final isAuth = state.isAuthenticated;

        return shad.Theme(
          data: shad.ThemeData(
            colorScheme: shad.ColorSchemes.lightZinc,
            radius: 0.5,
          ),
          child: Directionality(
            textDirection: isUr ? TextDirection.rtl : TextDirection.ltr,
            child: Scaffold(
              backgroundColor: CplColors.slate100,
              body: Column(
                children: [
                // 1. Standard Professional Top Navigation Bar (Always visible)
                _buildTopNavbar(context, state, isUr, isAuth, activeIdx),

                // 2. Persistent Top Offline Sync Banner
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

                // 3. Body Workspace: Collapsible Hamburger Sidebar (when authenticated) + Main Content
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (isAuth)
                        _buildCollapsibleSidebar(context, state, isUr, activeIdx),

                      Expanded(
                        child: !isAuth
                            ? Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(maxWidth: 500),
                                  child: const AuthScreen(),
                                ),
                              )
                            : activeIdx == 1
                                ? _buildDesktopDashboard(context, state, isUr)
                                : Align(
                                    alignment: Alignment.topCenter,
                                    child: ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 1400),
                                      child: _getScreenByIndex(activeIdx),
                                    ),
                                  ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          ),
        );
      },
    );
  }

  Widget _buildTopNavbar(
    BuildContext context,
    CplSystemState state,
    bool isUr,
    bool isAuth,
    int activeIdx,
  ) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withAlpha((0.04 * 255).round()),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Sleek Sidebar Toggle Button (when signed in)
          if (isAuth) ...[
            Tooltip(
              message: _isSidebarExpanded
                  ? (isUr ? 'مینو بند کریں' : 'Collapse Sidebar')
                  : (isUr ? 'مینو کھولیں' : 'Expand Sidebar'),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isSidebarExpanded = !_isSidebarExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    _isSidebarExpanded ? LucideIcons.panelLeftClose : LucideIcons.panelLeftOpen,
                    color: const Color(0xFF334155),
                    size: 17,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Official CPL Brand Identity (Light Executive Surface)
          InkWell(
            onTap: isAuth
                ? () => context.read<CplSystemCubit>().setScreenIndex(1)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: const CplBrandLogo(
              height: 30,
              isDark: false,
              showSubtitle: true,
            ),
          ),
          const SizedBox(width: 24),

          // Center Segmented Pill Navigation (Clean & Spacious)
          if (isAuth)
            Expanded(
              child: Align(
                alignment: Alignment.centerLeft,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: _topNavLinks.map((item) {
                        final idx = item['index'] as int;
                        final isSelected = activeIdx == idx;
                        return InkWell(
                          onTap: () => context.read<CplSystemCubit>().setScreenIndex(idx),
                          borderRadius: BorderRadius.circular(8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 160),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color: isSelected ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(7),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF0F172A).withAlpha((0.07 * 255).round()),
                                        blurRadius: 4,
                                        offset: const Offset(0, 1),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  item['icon'] as IconData,
                                  size: 14,
                                  color: isSelected ? const Color(0xFFEA580C) : const Color(0xFF64748B),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  isUr ? item['ur'] as String : item['title'] as String,
                                  style: TextStyle(
                                    color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 14),

          // Live Unit Telemetry Status Pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFA7F3D0)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                SizedBox(width: 6),
                Text(
                  'UNIT-1 • 62.4 MW',
                  style: TextStyle(
                    color: Color(0xFF065F46),
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'monospace',
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Language Switcher Pill
          InkWell(
            onTap: () => context.read<CplSystemCubit>().toggleLanguage(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.languages, size: 14, color: Color(0xFFD97706)),
                  const SizedBox(width: 5),
                  Text(
                    isUr ? 'اردو' : 'EN / اردو',
                    style: const TextStyle(
                      color: Color(0xFF334155),
                      fontWeight: FontWeight.w700,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (isAuth) ...[
            const SizedBox(width: 8),

            // Clean Outline PDF Export Action
            OutlinedButton.icon(
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
              icon: const Icon(LucideIcons.download, size: 14, color: Color(0xFF334155)),
              label: Text(
                isUr ? 'رپورٹ' : 'Export PDF',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Color(0xFF0F172A)),
              ),
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFCBD5E1)),
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),

            // Sleek Emergency SOS Trigger
            ElevatedButton.icon(
              onPressed: () => context.read<CplSystemCubit>().setScreenIndex(6),
              icon: const Icon(LucideIcons.siren, size: 15),
              label: Text(
                isUr ? 'ایمرجنسی' : 'SOS Siren',
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626),
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 36),
                padding: const EdgeInsets.symmetric(horizontal: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCollapsibleSidebar(
    BuildContext context,
    CplSystemState state,
    bool isUr,
    int activeIdx,
  ) {
    final width = _isSidebarExpanded ? 255.0 : 68.0;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: width,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: CplColors.slate200)),
      ),
      child: Column(
        children: [
          // Sidebar Header Strip (Clean — collapse controlled from Top Navbar)
          if (_isSidebarExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: CplColors.slate100)),
              ),
              child: Text(
                isUr ? 'نیویگیشن مینو' : 'PLANT NAVIGATION',
                style: const TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  color: CplColors.slate500,
                  letterSpacing: 0.7,
                ),
              ),
            ),

          // Categorized Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _drawerSections.map((section) {
                final items = section['items'] as List<Map<String, dynamic>>;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isSidebarExpanded)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                        child: Text(
                          isUr ? section['sectionUr'] as String : section['section'] as String,
                          style: const TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: CplColors.slate400,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ...items.map((item) {
                      final idx = item['index'] as int;
                      final isSelected = activeIdx == idx;
                      final label = isUr ? item['ur'] as String : item['title'] as String;

                      return Tooltip(
                        message: _isSidebarExpanded ? '' : label,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? CplColors.corporateNavy
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: InkWell(
                            onTap: () => context.read<CplSystemCubit>().setScreenIndex(idx),
                            borderRadius: BorderRadius.circular(10),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: _isSidebarExpanded ? 12 : 0,
                                vertical: 10,
                              ),
                              child: Row(
                                mainAxisAlignment: _isSidebarExpanded
                                    ? MainAxisAlignment.start
                                    : MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    item['icon'] as IconData,
                                    size: 19,
                                    color: isSelected ? CplColors.energyAmber : CplColors.slate600,
                                  ),
                                  if (_isSidebarExpanded) ...[
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        label,
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                          color: isSelected ? Colors.white : CplColors.slate800,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                );
              }).toList(),
            ),
          ),

          // Bottom Plant Coordinates Footer
          if (_isSidebarExpanded)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: CplColors.slate50,
                border: Border(top: BorderSide(color: CplColors.slate200)),
              ),
              child: Row(
                children: const [
                  Icon(LucideIcons.mapPin, size: 15, color: CplColors.safety500),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Chiniot Power (62.4 MW)\n31.7204° N, 72.9791° E',
                      style: TextStyle(
                        fontSize: 10,
                        fontFamily: 'monospace',
                        color: CplColors.slate600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDesktopDashboard(
    BuildContext context,
    CplSystemState state,
    bool isUr,
  ) {
    final openHazards = state.hazards
        .where((h) =>
            h.status.toLowerCase() != 'resolved' &&
            h.status.toLowerCase() != 'closed')
        .toList();
    final criticalHazards = openHazards
        .where((h) => h.severity.toLowerCase() == 'critical')
        .toList();
    final HazardItem? latestAlertHazard = criticalHazards.isNotEmpty
        ? criticalHazards.first
        : (openHazards.isNotEmpty ? openHazards.first : null);

    final totalChecklist = state.checklistItems.length;
    final passedChecklist = state.checklistItems
        .where((c) => c.status.toLowerCase() == 'pass')
        .length;
    final checklistPct = totalChecklist > 0
        ? ((passedChecklist / totalChecklist) * 100).round()
        : 0;

    final activePermits = state.permits
        .where((p) => p.status.toLowerCase() == 'active')
        .toList();
    final pendingPermits = state.permits
        .where((p) => p.status.toLowerCase() == 'pending')
        .toList();

    final totalRosterCount = state.roster.length;
    final compliantRosterCount =
        state.roster.where((w) => w.isFullPpe).length;
    final ppePct = totalRosterCount > 0
        ? ((compliantRosterCount / totalRosterCount) * 100).round()
        : 100;
    final safetyScore = ((checklistPct * 0.5) + (ppePct * 0.5)).round().clamp(0, 100);

    final recentActivities = _buildDesktopActivities(state);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1560),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dynamic Logged-In Employee Profile, Designation, Safety Score & Logout Hero Banner
              _buildEmployeeProfileHeroBanner(
                context: context,
                state: state,
                isUr: isUr,
                safetyScore: safetyScore,
                checklistPct: checklistPct,
                passedChecklist: passedChecklist,
                totalChecklist: totalChecklist,
                ppePct: ppePct,
                compliantRosterCount: compliantRosterCount,
                totalRosterCount: totalRosterCount,
                openHazardsCount: openHazards.length,
              ),
              const SizedBox(height: 16),

              // 2. 4-Card Executive KPI Grid
              _buildDesktopKpiGrid(
                context,
                isUr,
                openHazards.length,
                criticalHazards.length,
                checklistPct,
                passedChecklist,
                totalChecklist,
                activePermits.length,
                pendingPermits.length,
                totalRosterCount,
                compliantRosterCount,
              ),
              const SizedBox(height: 18),

              // 3. Asymmetric 2-Column Enterprise Layout
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Column: Live Plant Sectors + Tabular HSE & Permit Register (68%)
                  Expanded(
                    flex: 68,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildLivePlantSectorsGrid(context, state, isUr),
                        const SizedBox(height: 18),
                        _buildTabularHseRegister(context, state, isUr),
                      ],
                    ),
                  ),
                  const SizedBox(width: 18),

                  // Right Column: Shift Briefing + SOS + Quick Actions + Live Feed (32%)
                  Expanded(
                    flex: 32,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildDesktopShiftBriefing(state, latestAlertHazard, isUr),
                        const SizedBox(height: 14),
                        _buildDesktopEmergencyCard(context, isUr),
                        const SizedBox(height: 14),
                        _buildDesktopQuickActions(context, isUr),
                        const SizedBox(height: 14),
                        _buildDesktopActivityFeed(context, recentActivities, isUr),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeProfileHeroBanner({
    required BuildContext context,
    required CplSystemState state,
    required bool isUr,
    required int safetyScore,
    required int checklistPct,
    required int passedChecklist,
    required int totalChecklist,
    required int ppePct,
    required int compliantRosterCount,
    required int totalRosterCount,
    required int openHazardsCount,
  }) {
    final user = state.currentUser;
    final scoreColor = safetyScore >= 85
        ? const Color(0xFF10B981)
        : (safetyScore >= 65 ? const Color(0xFFF59E0B) : const Color(0xFFEF4444));
    final scoreBand = safetyScore >= 85
        ? (isUr ? 'بہترین تعمیل' : 'EXCELLENT')
        : (safetyScore >= 65
            ? (isUr ? 'توجہ درکار' : 'MODERATE')
            : (isUr ? 'فوری اصلاح' : 'ACTION NEEDED'));

    final avatarWidget = Tooltip(
      message: isUr ? 'پروفائل اور تصویر تبدیل کریں' : 'Manage Profile & Photo',
      child: CplUserAvatar(
        user: user,
        size: 64,
        borderRadius: 16,
        showOnlineDot: true,
        showCplBadge: true,
        onTap: () => context.read<CplSystemCubit>().setScreenIndex(11),
      ),
    );

    final identityWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 6,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFF59E0B).withAlpha((0.18 * 255).round()),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFF59E0B).withAlpha((0.45 * 255).round())),
              ),
              child: Text(
                user.empId.isNotEmpty ? user.empId : 'NOT SIGNED IN',
                style: const TextStyle(
                  color: Color(0xFFFBBF24),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'monospace',
                  letterSpacing: 0.5,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withAlpha((0.16 * 255).round()),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF10B981).withAlpha((0.4 * 255).round())),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(radius: 3, backgroundColor: Color(0xFF10B981)),
                  const SizedBox(width: 5),
                  Text(
                    isUr ? 'ڈیوٹی پر فعال' : 'ON DUTY • VERIFIED',
                    style: const TextStyle(
                      color: Color(0xFFA7F3D0),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
            if (user.shift.isNotEmpty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.clock, size: 12, color: Color(0xFF94A3B8)),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      user.shift,
                      style: const TextStyle(
                        color: Color(0xFFCBD5E1),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          user.name.isNotEmpty
              ? (isUr && user.urduName.isNotEmpty ? user.urduName : user.name)
              : (isUr ? 'سائن ان نہیں' : 'Not Signed In'),
          style: const TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.w800,
            color: Colors.white,
            letterSpacing: -0.3,
            height: 1.15,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 16,
          runSpacing: 4,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.briefcase, size: 13.5, color: Color(0xFFF59E0B)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    user.role.isNotEmpty ? user.role : 'Staff',
                    style: const TextStyle(
                      color: Color(0xFFE2E8F0),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.mapPin, size: 13.5, color: Color(0xFF38BDF8)),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    user.zone.isNotEmpty ? user.zone : 'Boiler Area (Unit 1 & 2)',
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );

    final scoreCardWidget = Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha((0.06 * 255).round()),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withAlpha((0.12 * 255).round())),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 54,
            height: 54,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 54,
                  height: 54,
                  child: CircularProgressIndicator(
                    value: safetyScore / 100.0,
                    strokeWidth: 5.5,
                    backgroundColor: Colors.white.withAlpha((0.12 * 255).round()),
                    valueColor: AlwaysStoppedAnimation<Color>(scoreColor),
                  ),
                ),
                Text(
                  '$safetyScore%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isUr ? 'سیفٹی سکور' : 'SAFETY SCORE',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: scoreColor.withAlpha((0.18 * 255).round()),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        scoreBand,
                        style: TextStyle(
                          color: scoreColor,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  isUr
                      ? 'چیک لسٹ $checklistPct% • پی پی ای $ppePct%'
                      : 'Checklist $checklistPct% ($passedChecklist/$totalChecklist) • PPE $ppePct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  isUr
                      ? '$openHazardsCount کھلے خطرات • $compliantRosterCount/$totalRosterCount پی پی ای تصدیق شدہ'
                      : '$openHazardsCount Open Hazards • $compliantRosterCount/$totalRosterCount PPE Verified',
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 10.5,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );

    final actionsWidget = IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => context.read<CplSystemCubit>().setScreenIndex(11),
            icon: const Icon(LucideIcons.userCog, size: 14, color: Colors.white),
            label: Text(
              isUr ? 'پروفائل' : 'Edit Profile',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12, color: Colors.white),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white.withAlpha((0.08 * 255).round()),
              side: BorderSide(color: Colors.white.withAlpha((0.22 * 255).round())),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => context.read<CplSystemCubit>().logout(),
            icon: const Icon(LucideIcons.logOut, size: 14),
            label: Text(
              isUr ? 'لاگ آؤٹ' : 'Logout',
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
              elevation: 0,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: InkWell(
              onTap: () {
                context.read<CplSystemCubit>().loadLiveData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isUr
                          ? 'لائیو پلانٹ ڈیٹا سنک ہو رہا ہے...'
                          : 'Syncing live CPL metrics from gateway...',
                    ),
                    duration: const Duration(seconds: 1),
                    backgroundColor: CplColors.slate900,
                  ),
                );
              },
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(LucideIcons.refreshCw, size: 11, color: Color(0xFF94A3B8)),
                    const SizedBox(width: 5),
                    Text(
                      isUr ? 'ڈیٹا ریفریش' : 'Sync Live Data',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1628), Color(0xFF132544)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withAlpha((0.08 * 255).round())),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B1628).withAlpha((0.22 * 255).round()),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 960) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                avatarWidget,
                const SizedBox(width: 16),
                Expanded(flex: 5, child: identityWidget),
                const SizedBox(width: 14),
                Flexible(flex: 4, child: scoreCardWidget),
                const SizedBox(width: 14),
                actionsWidget,
              ],
            );
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  avatarWidget,
                  const SizedBox(width: 16),
                  Expanded(child: identityWidget),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: scoreCardWidget),
                  const SizedBox(width: 14),
                  actionsWidget,
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDesktopKpiGrid(
    BuildContext context,
    bool isUr,
    int openHazardsCount,
    int criticalHazardsCount,
    int checklistPct,
    int passedChecklist,
    int totalChecklist,
    int activePermitsCount,
    int pendingPermitsCount,
    int totalRosterCount,
    int compliantRosterCount,
  ) {
    return Row(
      children: [
        _buildDesktopKpiCard(
          title: isUr ? 'اوپن خطرات اور نیئر مس' : 'Open Hazards & Near-Misses',
          value: '$openHazardsCount Open',
          subtitle: '$criticalHazardsCount Critical • 389 YTD (82.5% Closed)',
          icon: LucideIcons.triangleAlert,
          color: const Color(0xFFEA580C),
          onTap: () => context.read<CplSystemCubit>().setScreenIndex(2),
        ),
        const SizedBox(width: 14),
        _buildDesktopKpiCard(
          title: isUr ? 'ماہانہ محفوظ گھنٹے' : 'Safe Man-Hours (Oct 2026)',
          value: '84,730 Hours',
          subtitle: '434 Active Staff (388 CPL + 46 EKL)',
          icon: LucideIcons.clock,
          color: const Color(0xFF059669),
          onTap: () => context.read<CplSystemCubit>().setScreenIndex(9),
        ),
        const SizedBox(width: 14),
        _buildDesktopKpiCard(
          title: isUr ? 'فعال پرمٹ ٹو ورک' : 'Active PTW & LOTO',
          value: '$activePermitsCount Active',
          subtitle: '$pendingPermitsCount Pending Authorization',
          icon: LucideIcons.lock,
          color: const Color(0xFF0B1F3A),
          onTap: () => context.read<CplSystemCubit>().setScreenIndex(5),
        ),
        const SizedBox(width: 14),
        _buildDesktopKpiCard(
          title: isUr ? 'شفٹ چیک لسٹ اور تعمیل' : 'Shift Safety Checklist',
          value: '$checklistPct% Compliant',
          subtitle: '$passedChecklist/$totalChecklist Routine Checks Passed',
          icon: LucideIcons.clipboardCheck,
          color: const Color(0xFF7C3AED),
          onTap: () => context.read<CplSystemCubit>().setScreenIndex(4),
        ),
      ],
    );
  }

  Widget _buildDesktopKpiCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: CplColors.slate200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha((0.03 * 255).round()),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: color.withAlpha((0.1 * 255).round()),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: CplColors.slate500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w500,
                        color: CplColors.slate600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLivePlantSectorsGrid(
    BuildContext context,
    CplSystemState state,
    bool isUr,
  ) {
    const sectors = [
      {
        'id': 'Z1',
        'name': 'Boiler Area (Unit 1 & 2)',
        'workers': 43,
        'risk': 'High',
        'telemetry': '105.2 bar Steam • 540°C Superheated',
        'status': 'OPERATIONAL',
        'color': Color(0xFFF59E0B),
        'icon': LucideIcons.flame,
      },
      {
        'id': 'Z2',
        'name': 'TG Building (Steam Turbine Hall)',
        'workers': 27,
        'risk': 'Critical',
        'telemetry': '3,000 RPM • 62.4 MW Active Generation',
        'status': 'NORMAL',
        'color': Color(0xFFDC2626),
        'icon': LucideIcons.cpu,
      },
      {
        'id': 'Z5',
        'name': '132kV Grid Switchyard',
        'workers': 10,
        'risk': 'Critical',
        'telemetry': '132.4 kV Busbar • 0 Active Grid Faults',
        'status': 'SECURED',
        'color': Color(0xFFDC2626),
        'icon': LucideIcons.zap,
      },
      {
        'id': 'Z4',
        'name': 'Fuel & Bagasse Yard (BC-1 to BC-5)',
        'workers': 92,
        'risk': 'High',
        'telemetry': 'Conveyors BC-1 to BC-5 Running • 180 TPH',
        'status': 'ACTIVE',
        'color': Color(0xFFF59E0B),
        'icon': LucideIcons.truck,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(18),
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
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: CplColors.corporateNavy.withAlpha((0.08 * 255).round()),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(LucideIcons.activity, size: 16, color: CplColors.corporateNavy),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isUr ? 'پلانٹ کے بنیادی آپریشنل سیکٹرز' : 'LIVE PLANT OPERATIONAL SECTORS',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: CplColors.slate800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFA7F3D0)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(radius: 3, backgroundColor: Color(0xFF059669)),
                    SizedBox(width: 5),
                    Text(
                      '4 SECTORS MONITORED',
                      style: TextStyle(
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF047857),
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 2x2 Grid of Sector Cards
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sectors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemBuilder: (ctx, idx) {
              final sec = sectors[idx];
              final riskColor = sec['color'] as Color;

              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CplColors.slate50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: CplColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: CplColors.corporateNavy,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            sec['id'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            sec['name'] as String,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: CplColors.slate900,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: riskColor.withAlpha((0.12 * 255).round()),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${sec['risk']} Risk',
                            style: TextStyle(
                              color: riskColor,
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(LucideIcons.activity, size: 13, color: Color(0xFF059669)),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            sec['telemetry'] as String,
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: CplColors.slate700,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${sec['workers']} Workers on Duty',
                          style: const TextStyle(fontSize: 10, color: CplColors.slate500),
                        ),
                        InkWell(
                          onTap: () => context.read<CplSystemCubit>().setScreenIndex(4),
                          child: const Text(
                            'Audit Zone →',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2563EB),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabularHseRegister(
    BuildContext context,
    CplSystemState state,
    bool isUr,
  ) {
    final list = <Map<String, dynamic>>[];
    for (final p in state.permits.take(3)) {
      list.add({
        'number': p.type,
        'title': p.title,
        'zone': p.zone,
        'lead': p.requester,
        'status': p.status,
        'statusColor': p.status == 'Active' ? const Color(0xFF059669) : const Color(0xFFF59E0B),
        'screen': 5,
      });
    }
    for (final h in state.hazards.take(3)) {
      list.add({
        'number': h.nmNumber.isNotEmpty ? h.nmNumber : 'CPL-NM',
        'title': h.title,
        'zone': h.zone,
        'lead': h.responsibleTeam,
        'status': h.status,
        'statusColor': h.severity.toLowerCase() == 'critical'
            ? const Color(0xFFDC2626)
            : const Color(0xFF059669),
        'screen': 2,
      });
    }

    return Container(
      padding: const EdgeInsets.all(18),
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CplColors.corporateNavy.withAlpha((0.08 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.clipboardCheck, size: 16, color: CplColors.corporateNavy),
                    ),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(
                        isUr ? 'آپریشنل پرمٹ اور HSE رجسٹر' : 'OPERATIONAL PERMIT & HSE AUDIT REGISTER',
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: CplColors.slate800,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () => context.read<CplSystemCubit>().setScreenIndex(5),
                child: const Text(
                  'View All Register Entries →',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Tabular View
          Table(
            columnWidths: const {
              0: FlexColumnWidth(1.4),
              1: FlexColumnWidth(2.2),
              2: FlexColumnWidth(1.8),
              3: FlexColumnWidth(1.4),
              4: FlexColumnWidth(1.2),
              5: FlexColumnWidth(1.0),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              // Header Row
              TableRow(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(bottom: BorderSide(color: CplColors.slate200, width: 1.5)),
                ),
                children: [
                  _buildTableCell('PERMIT / NM #', isHeader: true),
                  _buildTableCell('ACTIVITY / TITLE', isHeader: true),
                  _buildTableCell('PLANT ZONE', isHeader: true),
                  _buildTableCell('RESPONSIBLE LEAD', isHeader: true),
                  _buildTableCell('STATUS', isHeader: true),
                  _buildTableCell('ACTION', isHeader: true),
                ],
              ),

              // Data Rows
              ...list.map((item) {
                final statusCol = item['statusColor'] as Color;
                final screenIdx = item['screen'] as int;

                return TableRow(
                  decoration: const BoxDecoration(
                    border: Border(bottom: BorderSide(color: CplColors.slate100)),
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Text(
                        item['number'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: CplColors.slate900,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Text(
                        item['title'] as String,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: CplColors.slate800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Text(
                        item['zone'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CplColors.slate600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Text(
                        item['lead'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          color: CplColors.slate700,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusCol.withAlpha((0.12 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          (item['status'] as String).toUpperCase(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                            color: statusCol,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                      child: ElevatedButton(
                        onPressed: () => context.read<CplSystemCubit>().setScreenIndex(screenIdx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CplColors.corporateNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                          elevation: 0,
                        ),
                        child: const Text('Inspect', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTableCell(String text, {bool isHeader = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isHeader ? 10 : 11,
          fontWeight: isHeader ? FontWeight.w800 : FontWeight.normal,
          color: isHeader ? CplColors.slate500 : CplColors.slate800,
          letterSpacing: isHeader ? 0.6 : 0,
        ),
      ),
    );
  }

  Widget _buildDesktopShiftBriefing(
    CplSystemState state,
    HazardItem? latestAlertHazard,
    bool isUr,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFFDE68A)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withAlpha((0.08 * 255).round()),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF59E0B),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(LucideIcons.info, color: Colors.white, size: 17),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUr
                      ? 'Shift Briefing: بوائلر ہاؤس یونٹ-1 میں بگاس کنویئر شروع کرنے سے پہلے ہائی سٹیم پریشر چیک کریں۔'
                      : 'Shift Briefing: High steam pressure check at Boiler House Unit-1 before bagasse conveyor startup.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF78350F),
                    height: 1.35,
                  ),
                ),
                if (latestAlertHazard != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '⚠️ ${latestAlertHazard.nmNumber} • ${latestAlertHazard.title} (${latestAlertHazard.zone})',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB91C1C),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopEmergencyCard(BuildContext context, bool isUr) {
    return InkWell(
      onTap: () => context.read<CplSystemCubit>().setScreenIndex(6),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFDC2626),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFDC2626).withAlpha((0.28 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: const Icon(LucideIcons.siren, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isUr ? 'ایمرجنسی سائرن / SOS' : 'EMERGENCY SIREN / SOS',
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isUr
                        ? 'پلانٹ انخلاء اور کنٹرول روم الرٹ کے لیے دبائیں'
                        : 'Tap for Plant-Wide Evacuation & Control Room Alert',
                    style: TextStyle(
                      fontSize: 10.5,
                      color: Colors.white.withAlpha((0.88 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'SOS',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFFDC2626),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDesktopQuickActions(BuildContext context, bool isUr) {
    final actions = [
      {'title': 'Report Hazard', 'ur': 'خطرہ رپورٹ', 'icon': LucideIcons.triangleAlert, 'index': 2, 'color': const Color(0xFFEA580C)},
      {'title': 'Daily Audit', 'ur': 'سیفٹی آڈٹ', 'icon': LucideIcons.clipboardCheck, 'index': 4, 'color': const Color(0xFF059669)},
      {'title': 'PTW & LOTO', 'ur': 'ورک پرمٹ', 'icon': LucideIcons.lock, 'index': 5, 'color': const Color(0xFF0B1F3A)},
      {'title': 'Risk Matrix', 'ur': 'رسک میٹرکس', 'icon': LucideIcons.grid3x3, 'index': 3, 'color': const Color(0xFF3B82F6)},
      {'title': 'HSE Training', 'ur': 'سیفٹی ٹریننگ', 'icon': LucideIcons.graduationCap, 'index': 7, 'color': const Color(0xFF7C3AED)},
      {'title': 'Shift Roster', 'ur': 'ٹیم روسٹر', 'icon': LucideIcons.users, 'index': 8, 'color': const Color(0xFF0D9488)},
    ];

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
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: CplColors.corporateNavy.withAlpha((0.08 * 255).round()),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(LucideIcons.zap, size: 16, color: CplColors.corporateNavy),
              ),
              const SizedBox(width: 8),
              Text(
                isUr ? 'فوری فیلڈ ماڈیولز' : 'QUICK FIELD MODULES',
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: CplColors.slate800,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: actions.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 1.25,
            ),
            itemBuilder: (ctx, idx) {
              final a = actions[idx];
              final col = a['color'] as Color;

              return InkWell(
                onTap: () => context.read<CplSystemCubit>().setScreenIndex(a['index'] as int),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: CplColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(a['icon'] as IconData, size: 20, color: col),
                      const SizedBox(height: 5),
                      Text(
                        isUr ? a['ur'] as String : a['title'] as String,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate800),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopActivityFeed(
    BuildContext context,
    List<Map<String, dynamic>> activities,
    bool isUr,
  ) {
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
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: CplColors.corporateNavy.withAlpha((0.08 * 255).round()),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(LucideIcons.history, size: 16, color: CplColors.corporateNavy),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        isUr ? 'حالیہ لائیو آڈٹ لاگ' : 'RECENT HSE AUDIT LOGS',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: CplColors.slate800,
                          letterSpacing: 0.5,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${activities.length} Events',
                style: const TextStyle(fontSize: 10, color: CplColors.slate500, fontFamily: 'monospace'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...activities.take(4).map((item) {
            final col = item['color'] as Color;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => context.read<CplSystemCubit>().setScreenIndex(item['screen'] as int),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: CplColors.slate50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: col.withAlpha((0.12 * 255).round()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(item['icon'] as IconData, size: 16, color: col),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item['title'] as String,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CplColors.slate900),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              item['subtitle'] as String,
                              style: const TextStyle(fontSize: 10, color: CplColors.slate500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: col.withAlpha((0.1 * 255).round()),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          item['badge'] as String,
                          style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.bold, color: col),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _buildDesktopActivities(CplSystemState state) {
    final list = <Map<String, dynamic>>[];
    for (final h in state.hazards.take(4)) {
      list.add({
        'title': h.title,
        'subtitle': '${h.reporter} • ${h.zone}',
        'badge': h.status.toUpperCase(),
        'color': h.severity.toLowerCase() == 'critical' ? CplColors.red600 : CplColors.safety500,
        'icon': LucideIcons.triangleAlert,
        'screen': 2,
      });
    }
    for (final p in state.permits.take(2)) {
      list.add({
        'title': '${p.type}: ${p.title}',
        'subtitle': '${p.requester} • ${p.zone}',
        'badge': p.status.toUpperCase(),
        'color': p.status == 'Active' ? CplColors.emerald600 : CplColors.amber500,
        'icon': LucideIcons.lock,
        'screen': 5,
      });
    }
    return list;
  }

  Widget _buildKpiCard(
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: CplColors.slate50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: CplColors.slate200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha((0.12 * 255).round()),
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
                      style: const TextStyle(fontSize: 10.5, color: CplColors.slate600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
