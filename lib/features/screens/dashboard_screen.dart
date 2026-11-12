import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../../core/widgets/cpl_brand_logo.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getUserInitials(String name) {
    final clean = name.replaceAll(RegExp(r'^(Engr\.|Dr\.|Mr\.|Ms\.)\s*', caseSensitive: false), '').trim();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'CP';
    if (parts.length == 1) return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _getDynamicShiftBriefing(CplSystemState state, user, bool isUrdu) {
    if (state.activeAlarm != null) {
      return isUrdu
          ? '⚠️ ایمرجنسی الرٹ: پلانٹ سیفٹی سائرن فعال ہے (${state.activeAlarm})۔ فوری حفاظتی انخلاء اور کنٹرول روم ہدایات پر عمل کریں۔'
          : '⚠️ EMERGENCY ALERT: Active Siren (${state.activeAlarm}). Follow plant evacuation & control room directives.';
    }
    final openHazards = state.hazards.where((h) => h.status.toLowerCase() != 'resolved' && h.status.toLowerCase() != 'closed').toList();
    final critical = openHazards.where((h) => h.severity.toLowerCase() == 'critical').toList();
    if (critical.isNotEmpty) {
      final first = critical.first;
      return isUrdu
          ? 'اہم حفاظتی بریفنگ: ${first.zone} میں ${first.title} کی نگرانی جاری ہے۔ احتیاطی تدابیر اور PPE پر سختی سے عمل کریں۔'
          : 'Critical Safety Briefing: Active attention required at ${first.zone} (${first.title}). Maintain strict PPE.';
    }
    final zoneHazards = openHazards.where((h) => h.zone == user.zone).toList();
    if (zoneHazards.isNotEmpty) {
      return isUrdu
          ? 'شفٹ بریفنگ (${user.shift.split(':')[0]}): ${user.zone} میں محتاط رہیں۔ ${zoneHazards.first.title} کا معائنہ کریں۔'
          : 'Shift Briefing (${user.shift.split(':')[0]}): Heightened caution in ${user.zone}. Verify ${zoneHazards.first.title}.';
    }
    return isUrdu
        ? 'شفٹ بریفنگ (${user.shift.split(':')[0]}): 62.4 میگاواٹ کو-جن پلانٹ بحفاظت فعال ہے۔ تمام زونز میں 100% PPE معائنہ مکمل کریں۔'
        : 'Shift Briefing (${user.shift.split(':')[0]}): 62.4 MW Co-Gen operating safely. Verify 100% PPE compliance at turnover.';
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final lang = state.language;
        final user = state.currentUser;
        final isUrdu = lang == 'ur';

        // Dynamic Calculations
        final initials = _getUserInitials(user.name);
        final briefingText = _getDynamicShiftBriefing(state, user, isUrdu);

        // Safe days derived from plant commissioning milestone
        final streakDays = (DateTime.now().difference(DateTime(2025, 4, 1)).inDays).clamp(1, 9999);
        final recordDays = streakDays + 32;

        // Live PPE Compliance from Roster
        final totalWorkers = state.roster.isNotEmpty ? state.roster.length : 148;
        final compliantWorkers = state.roster.isNotEmpty
            ? state.roster.where((w) => w.isFullPpe).length
            : 144;
        final compliancePct = (compliantWorkers / totalWorkers * 100).toStringAsFixed(1);

        // Live Open & Critical Hazards
        final openHazards = state.hazards.where((h) => h.status.toLowerCase() != 'resolved' && h.status.toLowerCase() != 'closed').toList();
        final criticalHazards = openHazards.where((h) => h.severity.toLowerCase() == 'critical').toList();
        final criticalSubText = criticalHazards.isNotEmpty
            ? '${criticalHazards.length} Critical (${criticalHazards.first.zone.split(' ').take(2).join(' ')})'
            : (openHazards.isNotEmpty ? '${openHazards.length} Active Hazards' : (isUrdu ? 'تمام خطرات کلیئر' : 'All Clear (Zero Defect)'));

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 0. CPL Brand Identity & Logout Header Strip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const CplBrandLogo(
                    height: 28,
                    showSubtitle: true,
                    isDark: false,
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.refresh, size: 18, color: CplColors.slate600),
                        tooltip: 'Sync Latest Records',
                        onPressed: () {
                          context.read<CplSystemCubit>().loadLiveData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Refreshing live CPL records from gateway...'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.logout, size: 18, color: CplColors.red600),
                        tooltip: 'Logout Staff Session',
                        onPressed: () {
                          context.read<CplSystemCubit>().logout();
                        },
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // 1. Staff & Plant Live Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CplColors.emerald50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: CplColors.emerald500.withAlpha((0.3 * 255).round())),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircleAvatar(radius: 3, backgroundColor: CplColors.emerald500),
                                  const SizedBox(width: 4),
                                  Text(
                                    CplLocalizations.tr('unitStatus', lang),
                                    style: CplTypography.mono(fontSize: 9, fontWeight: FontWeight.bold, color: CplColors.emerald700),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(user.empId, style: CplTypography.mono(fontSize: 10, color: CplColors.slate500)),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          isUrdu ? user.urduName : user.name,
                          style: isUrdu
                              ? CplTypography.urdu(fontSize: 16, color: CplColors.slate900)
                              : CplTypography.displayHeading(fontSize: 16, color: CplColors.slate900),
                        ),
                        Text(
                          '${user.role} • ${user.zone}',
                          style: CplTypography.body(fontSize: 11, color: CplColors.slate500),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(10), // Jump to Admin Panel
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: CplColors.slate900,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: CplColors.safety500.withAlpha((0.4 * 255).round())),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(initials, style: CplTypography.displayHeading(fontSize: 11, color: Colors.white)),
                          Text('CPL', style: CplTypography.mono(fontSize: 8, color: CplColors.safety400)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 2. Shift Briefing Banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: CplColors.amber50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: CplColors.amber200),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: CplColors.amber500,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(Icons.info_outline, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        briefingText,
                        style: isUrdu
                            ? CplTypography.urdu(fontSize: 11, color: CplColors.amber950)
                            : CplTypography.body(fontSize: 11, fontWeight: FontWeight.w600, color: CplColors.amber950),
                        textAlign: isUrdu ? TextAlign.right : TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 3. Hero Milestone Card: 218 Safe Work Days
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CplColors.slate900, Color(0xFF1E293B), CplColors.slate900],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: CplColors.slate900.withAlpha((0.25 * 255).round()),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: CplColors.emerald500.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircleAvatar(radius: 3, backgroundColor: CplColors.emerald500),
                          const SizedBox(width: 6),
                          Text(
                            'Chiniot Power Safety Streak',
                            style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.emerald50),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text('$streakDays', style: CplTypography.displayHeading(fontSize: 38, color: Colors.white)),
                            const SizedBox(width: 8),
                            Text(CplLocalizations.tr('safeDaysLabel', lang), style: CplTypography.body(fontSize: 12, fontWeight: FontWeight.bold, color: CplColors.slate200)),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          alignment: Alignment.center,
                          child: const Icon(Icons.shield_outlined, color: CplColors.safety500, size: 24),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 8),
                    Text(
                      isUrdu ? 'پلانٹ ریکارڈ: $recordDays دن • یونٹ-1 اور بوائلر محفوظ' : 'Plant Record: $recordDays Days • Unit-1 & Boiler Safe',
                      style: CplTypography.body(fontSize: 10, color: CplColors.slate300),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 4. Full-width Emergency Siren / SOS Trigger Card
              InkWell(
                onTap: () => context.read<CplSystemCubit>().setScreenIndex(6), // Screen 07: Alarms
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [CplColors.red600, CplColors.red700],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: CplColors.red600.withAlpha((0.3 * 255).round()),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: const Icon(Icons.campaign, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              CplLocalizations.tr('emergencySiren', lang),
                              style: CplTypography.displayHeading(fontSize: 12, color: Colors.white, letterSpacing: 0.5),
                            ),
                            Text(
                              CplLocalizations.tr('emergencySub', lang),
                              style: CplTypography.body(fontSize: 10, color: Colors.red.shade100),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'SOS',
                          style: CplTypography.mono(fontSize: 10, fontWeight: FontWeight.w900, color: CplColors.red600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 5. KPI Pair (Compliance & Open Hazards)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => context.read<CplSystemCubit>().setScreenIndex(9), // Screen 10: Analytics
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: CplColors.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(CplLocalizations.tr('compliance', lang), style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                            const SizedBox(height: 2),
                            Text('$compliancePct%', style: CplTypography.displayHeading(fontSize: 22, color: CplColors.emerald600)),
                            Text('$compliantWorkers/$totalWorkers PPE Verified', style: CplTypography.body(fontSize: 10, color: CplColors.slate500)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      onTap: () => context.read<CplSystemCubit>().setScreenIndex(2), // Screen 03: Hazard
                      borderRadius: BorderRadius.circular(18),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: CplColors.slate200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(CplLocalizations.tr('openHazards', lang), style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                            const SizedBox(height: 2),
                            Text('${openHazards.length}', style: CplTypography.displayHeading(fontSize: 22, color: CplColors.safety500)),
                            Text(
                              criticalSubText,
                              style: CplTypography.body(
                                fontSize: 10,
                                color: criticalHazards.isNotEmpty ? CplColors.red600 : CplColors.emerald600,
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
              const SizedBox(height: 16),

              // 6. Quick Field Actions Grid (6 Modules)
              Text(
                CplLocalizations.tr('quickActions', lang).toUpperCase(),
                style: CplTypography.body(fontSize: 11, fontWeight: FontWeight.bold, color: CplColors.slate700),
              ),
              const SizedBox(height: 8),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.15,
                children: [
                  _buildQuickActionTile(
                    icon: '⚠️',
                    label: CplLocalizations.tr('reportHazard', lang),
                    isPrimary: true,
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(2),
                  ),
                  _buildQuickActionTile(
                    icon: '✅',
                    label: CplLocalizations.tr('dailyAudit', lang),
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(4),
                  ),
                  _buildQuickActionTile(
                    icon: '🔒',
                    label: CplLocalizations.tr('ptwLoto', lang),
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(5),
                  ),
                  _buildQuickActionTile(
                    icon: '📊',
                    label: CplLocalizations.tr('riskMatrix', lang),
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(3),
                  ),
                  _buildQuickActionTile(
                    icon: '🎓',
                    label: CplLocalizations.tr('trainingHub', lang),
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(7),
                  ),
                  _buildQuickActionTile(
                    icon: '👷',
                    label: CplLocalizations.tr('musterRoll', lang),
                    onTap: () => context.read<CplSystemCubit>().setScreenIndex(8),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionTile({
    required String icon,
    required String label,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          color: isPrimary ? CplColors.safety500 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isPrimary ? null : Border.all(color: CplColors.slate200),
          boxShadow: isPrimary
              ? [BoxShadow(color: CplColors.safety500.withAlpha((0.3 * 255).round()), blurRadius: 8, offset: const Offset(0, 3))]
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CplTypography.body(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isPrimary ? Colors.white : CplColors.slate800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
