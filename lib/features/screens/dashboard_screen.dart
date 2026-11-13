import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../../core/widgets/cpl_brand_logo.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';
import '../cpl_system/models/cpl_models.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getUserInitials(String name) {
    final clean = name
        .replaceAll(RegExp(r'^(Engr\.|Dr\.|Mr\.|Ms\.)\s*', caseSensitive: false), '')
        .trim();
    final parts = clean.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return 'CP';
    if (parts.length == 1) {
      return parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    }
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  String _formatTimestamp(String raw) {
    if (raw.isEmpty) return 'Just now';
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    final diff = DateTime.now().difference(parsed.toLocal());
    if (diff.inSeconds.abs() < 60) return 'Just now';
    if (diff.inMinutes < 60 && diff.inMinutes >= 0) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24 && diff.inHours >= 0) return '${diff.inHours}h ago';
    final hh = parsed.toLocal().hour.toString().padLeft(2, '0');
    final mm = parsed.toLocal().minute.toString().padLeft(2, '0');
    return '${parsed.toLocal().month}/${parsed.toLocal().day} $hh:$mm';
  }

  List<_LiveActivityEntry> _buildRecentActivities(CplSystemState state) {
    final entries = <_LiveActivityEntry>[];

    // 1. Submitted Hazards
    for (final h in state.hazards.take(3)) {
      entries.add(_LiveActivityEntry(
        icon: h.severity.toLowerCase() == 'critical'
            ? Icons.warning_amber_rounded
            : Icons.report_problem_outlined,
        accent: h.severity.toLowerCase() == 'critical'
            ? CplColors.red600
            : CplColors.safety500,
        title: h.title,
        subtitle: '${h.reporter} • ${h.zone}',
        timestamp: h.time,
        badge: h.status.toUpperCase(),
        targetScreen: 2,
      ));
    }

    // 2. Checklist Sign-off / Audit Events & PTW Events from Audit Logs
    for (final log in state.auditLogs) {
      if (log.action.contains('CHECKLIST') ||
          log.action.contains('PTW') ||
          log.action.contains('CAPA')) {
        entries.add(_LiveActivityEntry(
          icon: log.action.contains('CHECKLIST')
              ? Icons.fact_check_outlined
              : Icons.verified_user_outlined,
          accent: log.action.contains('CHECKLIST')
              ? CplColors.emerald600
              : CplColors.corporateNavy,
          title: log.details,
          subtitle: 'Actor: ${log.actorId} • ${log.targetResource}',
          timestamp: _formatTimestamp(log.timestamp),
          badge: log.action.replaceAll('_', ' '),
          targetScreen: log.action.contains('CHECKLIST') ? 4 : 5,
        ));
      }
    }

    // 3. PTW Permits (if audit logs don't already cover 3 items)
    for (final p in state.permits.take(2)) {
      entries.add(_LiveActivityEntry(
        icon: Icons.lock_clock_outlined,
        accent: p.status == 'Active' ? CplColors.emerald600 : CplColors.amber500,
        title: '${p.type}: ${p.title}',
        subtitle: '${p.requester} • ${p.zone}',
        timestamp: p.timer,
        badge: p.status.toUpperCase(),
        targetScreen: 5,
      ));
    }

    return entries.take(3).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final lang = state.language;
        final user = state.currentUser;
        final isUrdu = lang == 'ur';
        final initials = _getUserInitials(user.name);

        // Live Operational Metrics (100% computed from state)
        final openHazards = state.hazards
            .where((h) =>
                h.status.toLowerCase() != 'resolved' &&
                h.status.toLowerCase() != 'closed')
            .toList();
        final criticalHazards = openHazards
            .where((h) => h.severity.toLowerCase() == 'critical')
            .toList();
        final HazardItem? latestAlertHazard =
            criticalHazards.isNotEmpty ? criticalHazards.first : (openHazards.isNotEmpty ? openHazards.first : null);

        final totalChecklist = state.checklistItems.length;
        final passedChecklist = state.checklistItems
            .where((c) => c.status.toLowerCase() == 'pass')
            .length;
        final checklistPct = totalChecklist > 0
            ? ((passedChecklist / totalChecklist) * 100).round()
            : 0;

        final activePermitsCount = state.permits
            .where((p) => p.status.toLowerCase() == 'active')
            .length;
        final pendingPermitsCount = state.permits
            .where((p) => p.status.toLowerCase() == 'pending')
            .length;

        final totalRosterCount = state.roster.length;
        final compliantRosterCount =
            state.roster.where((w) => w.isFullPpe).length;

        final recentActivities = _buildRecentActivities(state);

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Dynamic Logged-In Employee Identity Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [CplColors.corporateNavy, Color(0xFF142D4F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: CplColors.corporateNavy.withAlpha((0.22 * 255).round()),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top Row: CPL Logo + UNIT-1 ONLINE badge + Sync & Logout actions
                    Row(
                      children: [
                        const Expanded(
                          child: CplBrandLogo(
                            height: 28,
                            showSubtitle: true,
                            isDark: true,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: CplColors.emerald500.withAlpha((0.18 * 255).round()),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: CplColors.emerald500.withAlpha((0.5 * 255).round()),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircleAvatar(
                                radius: 3,
                                backgroundColor: CplColors.emerald500,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                'UNIT-1 ONLINE',
                                style: CplTypography.mono(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: CplColors.emerald50,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 12),

                    // Employee Details Row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () => context.read<CplSystemCubit>().setScreenIndex(10),
                          borderRadius: BorderRadius.circular(14),
                          child: Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: CplColors.energyAmber.withAlpha((0.18 * 255).round()),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: CplColors.energyAmber),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  initials,
                                  style: CplTypography.displayHeading(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  'CPL',
                                  style: CplTypography.mono(
                                    fontSize: 8,
                                    color: CplColors.energyAmber,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withAlpha((0.12 * 255).round()),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      state.isAuthenticated ? user.empId : 'NOT SIGNED IN',
                                      style: CplTypography.mono(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: CplColors.energyAmber,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                !state.isAuthenticated
                                    ? (isUrdu ? 'لاگ ان نہیں ہے' : 'Not Signed In')
                                    : (isUrdu && user.urduName.isNotEmpty
                                        ? user.urduName
                                        : user.name),
                                style: isUrdu
                                    ? CplTypography.urdu(
                                        fontSize: 16,
                                        color: Colors.white,
                                      )
                                    : CplTypography.displayHeading(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                              ),
                              Text(
                                state.isAuthenticated
                                    ? '${user.role} • ${user.zone}'
                                    : (isUrdu
                                        ? 'براہ کرم اپنی ایمپلائی آئی ڈی سے لاگ ان کریں'
                                        : 'Please sign in with your Employee ID'),
                                style: CplTypography.body(
                                  fontSize: 11,
                                  color: CplColors.slate300,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Bottom Strip: Active Duty Shift + Sync + Logout Button
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha((0.08 * 255).round()),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.schedule,
                            size: 14,
                            color: CplColors.energyAmber,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              state.isAuthenticated
                                  ? user.shift
                                  : (isUrdu ? 'کوئی فعال شفٹ نہیں' : 'No Active Shift'),
                              style: CplTypography.body(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            icon: const Icon(
                              Icons.refresh,
                              size: 16,
                              color: CplColors.slate300,
                            ),
                            tooltip: 'Sync Live Plant Data',
                            onPressed: () {
                              context.read<CplSystemCubit>().loadLiveData();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Syncing live CPL metrics from gateway...'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 4),
                          InkWell(
                            onTap: () => context.read<CplSystemCubit>().logout(),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: CplColors.red600.withAlpha((0.9 * 255).round()),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.logout, size: 13, color: Colors.white),
                                  const SizedBox(width: 4),
                                  Text(
                                    isUrdu ? 'لاگ آؤٹ' : 'Logout',
                                    style: CplTypography.body(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // 2. Dynamic Critical Alert Banner (or Emerald Green All Clear Banner)
              InkWell(
                onTap: () => context
                    .read<CplSystemCubit>()
                    .setScreenIndex(state.activeAlarm != null ? 6 : 2),
                borderRadius: BorderRadius.circular(16),
                child: _buildDynamicAlertBanner(state, latestAlertHazard, isUrdu),
              ),
              const SizedBox(height: 12),

              // 3. Full-width Emergency Siren / SOS Trigger Card
              InkWell(
                onTap: () => context.read<CplSystemCubit>().setScreenIndex(6),
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
                        color: CplColors.red600.withAlpha((0.28 * 255).round()),
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
                              style: CplTypography.displayHeading(
                                fontSize: 12,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              CplLocalizations.tr('emergencySub', lang),
                              style: CplTypography.body(
                                fontSize: 10,
                                color: Colors.red.shade100,
                              ),
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
                          style: CplTypography.mono(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: CplColors.red600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Live Operational Metrics Grid (4 Dynamic State-Computed KPIs)
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: CplLocalizations.tr('openHazards', lang),
                      value: '${openHazards.length}',
                      subtitle: criticalHazards.isNotEmpty
                          ? '${criticalHazards.length} Critical (${criticalHazards.first.zone.split(' ').take(2).join(' ')})'
                          : (openHazards.isEmpty
                              ? 'All Zones Clear'
                              : '${openHazards.length} Open Reports'),
                      valueColor: openHazards.isNotEmpty
                          ? CplColors.safety500
                          : CplColors.emerald600,
                      subtitleColor: criticalHazards.isNotEmpty
                          ? CplColors.red600
                          : CplColors.slate500,
                      icon: Icons.warning_amber_rounded,
                      onTap: () => context.read<CplSystemCubit>().setScreenIndex(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: isUrdu ? 'شفٹ چیک لسٹ' : 'Shift Checklist',
                      value: '$checklistPct%',
                      subtitle: '$passedChecklist/$totalChecklist Passed',
                      valueColor: checklistPct >= 80
                          ? CplColors.emerald600
                          : CplColors.amber500,
                      subtitleColor: CplColors.slate500,
                      icon: Icons.fact_check_outlined,
                      onTap: () => context.read<CplSystemCubit>().setScreenIndex(4),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      label: isUrdu ? 'فعال ورک پرمٹ' : 'Active PTW / LOTO',
                      value: '$activePermitsCount',
                      subtitle: pendingPermitsCount > 0
                          ? '$pendingPermitsCount Pending Approval'
                          : '${state.permits.length} Total Permits',
                      valueColor: CplColors.corporateNavy,
                      subtitleColor: pendingPermitsCount > 0
                          ? CplColors.safety600
                          : CplColors.slate500,
                      icon: Icons.lock_clock_outlined,
                      onTap: () => context.read<CplSystemCubit>().setScreenIndex(5),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildMetricCard(
                      label: isUrdu ? 'ڈیوٹی روسٹر' : 'On-Duty Roster',
                      value: '$totalRosterCount',
                      subtitle: '$compliantRosterCount/$totalRosterCount Full PPE',
                      valueColor: CplColors.emerald600,
                      subtitleColor: CplColors.slate500,
                      icon: Icons.groups_outlined,
                      onTap: () => context.read<CplSystemCubit>().setScreenIndex(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // 5. Quick Field Actions Grid (6 Modules)
              Text(
                CplLocalizations.tr('quickActions', lang).toUpperCase(),
                style: CplTypography.body(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: CplColors.slate700,
                ),
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
              const SizedBox(height: 16),

              // 6. Recent Live Activity Feed (Latest 3 events)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isUrdu ? 'حالیہ لائیو سرگرمیاں' : 'RECENT LIVE ACTIVITY',
                    style: CplTypography.body(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: CplColors.slate700,
                    ),
                  ),
                  Text(
                    '${recentActivities.length} Latest Events',
                    style: CplTypography.mono(
                      fontSize: 10,
                      color: CplColors.slate500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentActivities.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Text(
                    'No recent HSE events recorded in this shift.',
                    style: CplTypography.body(fontSize: 12, color: CplColors.slate500),
                  ),
                )
              else
                ...recentActivities.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: InkWell(
                        onTap: () => context
                            .read<CplSystemCubit>()
                            .setScreenIndex(item.targetScreen),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: CplColors.slate200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: item.accent.withAlpha((0.12 * 255).round()),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(item.icon, size: 18, color: item.accent),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: CplTypography.body(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: CplColors.slate900,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      item.subtitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: CplTypography.body(
                                        fontSize: 10.5,
                                        color: CplColors.slate500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: item.accent.withAlpha((0.1 * 255).round()),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      item.badge,
                                      style: CplTypography.mono(
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.bold,
                                        color: item.accent,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    item.timestamp,
                                    style: CplTypography.mono(
                                      fontSize: 9.5,
                                      color: CplColors.slate500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDynamicAlertBanner(
    CplSystemState state,
    HazardItem? latestAlertHazard,
    bool isUrdu,
  ) {
    if (state.activeAlarm != null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CplColors.red50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CplColors.red600),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CplColors.red600,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.campaign, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isUrdu
                    ? 'ایمرجنسی الرٹ فعال: ${state.activeAlarm}'
                    : 'EMERGENCY SIREN ACTIVE: ${state.activeAlarm}',
                style: CplTypography.body(
                  fontSize: 11.5,
                  fontWeight: FontWeight.bold,
                  color: CplColors.red700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (latestAlertHazard == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: CplColors.emerald50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: CplColors.emerald500),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: CplColors.emerald600,
                borderRadius: BorderRadius.circular(8),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.verified_outlined, color: Colors.white, size: 17),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isUrdu
                    ? 'تمام پلانٹ زونز محفوظ ہیں — کوئی فعال خطرہ موجود نہیں'
                    : 'All Plant Zones Clear — No Active Hazards',
                style: CplTypography.body(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: CplColors.emerald700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final isCritical = latestAlertHazard.severity.toLowerCase() == 'critical';
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCritical ? CplColors.red50 : CplColors.amber50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCritical ? CplColors.red600 : CplColors.amber200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: isCritical ? CplColors.red600 : CplColors.amber500,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Icon(
              isCritical ? Icons.warning_amber_rounded : Icons.info_outline,
              color: Colors.white,
              size: 17,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${latestAlertHazard.severity.toUpperCase()} ALERT • ${latestAlertHazard.zone}',
                  style: CplTypography.mono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isCritical ? CplColors.red700 : CplColors.amber950,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${latestAlertHazard.title} — Reported by ${latestAlertHazard.reporter} (${latestAlertHazard.time})',
                  style: CplTypography.body(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isCritical ? CplColors.red700 : CplColors.amber950,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String value,
    required String subtitle,
    required Color valueColor,
    required Color subtitleColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: CplTypography.body(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: CplColors.slate500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(icon, size: 16, color: valueColor),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: CplTypography.displayHeading(
                fontSize: 22,
                color: valueColor,
              ),
            ),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CplTypography.body(
                fontSize: 10,
                color: subtitleColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
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
              ? [
                  BoxShadow(
                    color: CplColors.safety500.withAlpha((0.3 * 255).round()),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
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

class _LiveActivityEntry {
  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final String timestamp;
  final String badge;
  final int targetScreen;

  const _LiveActivityEntry({
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.badge,
    required this.targetScreen,
  });
}
