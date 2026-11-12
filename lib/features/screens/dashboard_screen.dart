import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final lang = state.language;
        final user = state.currentUser;
        final isUrdu = lang == 'ur';

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          Text('MT', style: CplTypography.displayHeading(fontSize: 11, color: Colors.white)),
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
                        CplLocalizations.tr('shiftBriefing', lang),
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
                            Text('218', style: CplTypography.displayHeading(fontSize: 38, color: Colors.white)),
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
                      CplLocalizations.tr('safeDaysSub', lang),
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
                            Text('97.2%', style: CplTypography.displayHeading(fontSize: 22, color: CplColors.emerald600)),
                            Text('148/148 PPE Verified', style: CplTypography.body(fontSize: 10, color: CplColors.slate500)),
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
                            Text('${state.hazards.length}', style: CplTypography.displayHeading(fontSize: 22, color: CplColors.safety500)),
                            Text('1 Critical (Bagasse Yard)', style: CplTypography.body(fontSize: 10, color: CplColors.red600, fontWeight: FontWeight.w600)),
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
