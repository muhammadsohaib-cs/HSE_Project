import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';
import '../cpl_system/models/cpl_models.dart';

class RosterScreen extends StatelessWidget {
  const RosterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final roster = state.roster;
        final fullyCompliantCount = roster.where((w) => w.isFullPpe).length;

        return Scaffold(
          backgroundColor: CplColors.slate50,
          appBar: AppBar(
            backgroundColor: CplColors.slate900,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.read<CplSystemCubit>().setScreenIndex(1),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUr ? 'ٹیم روسٹر اور پی پی ای مسٹر رول' : 'Team Roster & PPE Muster Roll',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '148 / 148 Accounted For • Shift A',
                  style: CplTypography.caption(context).copyWith(color: CplColors.slate400),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                onPressed: () => context.read<CplSystemCubit>().toggleLanguage(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Headcount & Muster Roll Strip
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.people_alt, size: 20, color: CplColors.safety500),
                              SizedBox(width: 8),
                              Text(
                                'On-Site Muster Headcount',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: CplColors.emerald500.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '148 / 148 SAFE',
                              style: TextStyle(
                                color: CplColors.emerald500,
                                fontWeight: FontWeight.w900,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _buildZoneBadge('Boiler Unit-1', '34 Safe', CplColors.safety500),
                          const SizedBox(width: 6),
                          _buildZoneBadge('Bagasse Yard', '38 Safe', CplColors.amber500),
                          const SizedBox(width: 6),
                          _buildZoneBadge('Turbine & Grid', '76 Safe', const Color(0xFF8B5CF6)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // PPE Compliance Progress Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUr ? 'شفٹ پی پی ای معائنہ (1-ٹیپ ٹوگل)' : 'Shift PPE Verification (1-Tap)',
                      style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '$fullyCompliantCount / ${roster.length} Compliant',
                      style: TextStyle(
                        color: fullyCompliantCount == roster.length ? CplColors.emerald500 : CplColors.safety500,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Worker Cards
                ...roster.map((worker) {
                  final isCompliant = worker.isFullPpe;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCompliant ? CplColors.slate200 : CplColors.amber500.withOpacity(0.5),
                        width: isCompliant ? 1 : 1.5,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Worker Info Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      worker.empId,
                                      style: CplTypography.mono().copyWith(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: CplColors.safety500,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      worker.name,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${worker.role} • ${worker.zone}',
                                  style: TextStyle(fontSize: 11.5, color: CplColors.slate600),
                                ),
                              ],
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isCompliant
                                    ? CplColors.emerald500.withOpacity(0.12)
                                    : CplColors.amber500.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                isCompliant ? (isUr ? 'مکمل پی پی ای ✓' : '100% PPE ✓') : (isUr ? 'نامکمل' : 'PPE MISSING'),
                                style: TextStyle(
                                  color: isCompliant ? CplColors.emerald500 : CplColors.amber500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 10.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 4 PPE Toggle Chips
                        Row(
                          children: [
                            _buildPpeToggleChip(
                              context,
                              label: 'Helmet',
                              icon: '🪖',
                              isActive: worker.helmet,
                              onTap: () {
                                context.read<CplSystemCubit>().toggleWorkerPpe(worker.empId, 'helmet');
                              },
                            ),
                            const SizedBox(width: 6),
                            _buildPpeToggleChip(
                              context,
                              label: 'Shoes',
                              icon: '🥾',
                              isActive: worker.shoes,
                              onTap: () {
                                context.read<CplSystemCubit>().toggleWorkerPpe(worker.empId, 'shoes');
                              },
                            ),
                            const SizedBox(width: 6),
                            _buildPpeToggleChip(
                              context,
                              label: 'Gloves',
                              icon: '🧤',
                              isActive: worker.gloves,
                              onTap: () {
                                context.read<CplSystemCubit>().toggleWorkerPpe(worker.empId, 'gloves');
                              },
                            ),
                            const SizedBox(width: 6),
                            _buildPpeToggleChip(
                              context,
                              label: 'Ear-Plugs',
                              icon: '🎧',
                              isActive: worker.ear,
                              onTap: () {
                                context.read<CplSystemCubit>().toggleWorkerPpe(worker.empId, 'ear');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Shift Muster Verification Button
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isUr
                              ? 'شفٹ A مسٹر رول اور پی پی ای آڈٹ تصدیق کر دیا گیا ہے۔'
                              : 'Shift A Muster Roll & PPE Compliance Sealed & Broadcasted to DCS.',
                        ),
                        backgroundColor: CplColors.emerald500,
                      ),
                    );
                  },
                  icon: const Icon(Icons.assignment_turned_in),
                  label: Text(
                    isUr ? 'مسٹر رول اور پی پی ای آڈٹ بند کریں' : 'Confirm & Broadcast Muster Roll',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CplColors.slate900,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildZoneBadge(String zone, String count, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Text(zone, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold), maxLines: 1),
            Text(count, style: TextStyle(fontSize: 9.5, color: color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildPpeToggleChip(
    BuildContext context, {
    required String label,
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isActive ? CplColors.emerald500 : CplColors.slate100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? CplColors.emerald500 : CplColors.slate200,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(icon, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: isActive ? Colors.white : CplColors.slate600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
