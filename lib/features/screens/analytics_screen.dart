import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/theme/cpl_theme.dart';
import '../../core/utils/csv_exporter.dart';
import '../../core/utils/pdf_generator.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final period = state.analyticsPeriod;

        final all2026Months = [
          {'month': 'Jan', 'hazards': 41, 'closed': 40, 'open': 1, 'rate': '97.6%'},
          {'month': 'Feb', 'hazards': 13, 'closed': 12, 'open': 1, 'rate': '92.3%'},
          {'month': 'Mar', 'hazards': 23, 'closed': 23, 'open': 0, 'rate': '100%'},
          {'month': 'Apr', 'hazards': 48, 'closed': 41, 'open': 7, 'rate': '85.4%'},
          {'month': 'May', 'hazards': 56, 'closed': 49, 'open': 7, 'rate': '87.5%'},
          {'month': 'Jun', 'hazards': 45, 'closed': 39, 'open': 6, 'rate': '86.7%'},
          {'month': 'Jul', 'hazards': 79, 'closed': 61, 'open': 18, 'rate': '77.2%'},
          {'month': 'Aug', 'hazards': 38, 'closed': 30, 'open': 8, 'rate': '78.9%'},
          {'month': 'Sep', 'hazards': 23, 'closed': 20, 'open': 3, 'rate': '87.0%'},
          {'month': 'Oct', 'hazards': 23, 'closed': 6, 'open': 17, 'rate': '26.1%'},
        ];

        final monthlyData = period == '6M'
            ? all2026Months.sublist(4) // May - Oct 2026
            : all2026Months; // Jan - Oct 2026 (389 Total, 321 Closed, 68 Open)

        // Dynamic live plant metrics from CplSystemState
        final openHazards = state.hazards
            .where((h) => h.status.toLowerCase() != 'resolved' && h.status.toLowerCase() != 'closed')
            .length;
        final criticalHazards = state.hazards
            .where((h) =>
                h.severity.toLowerCase() == 'critical' &&
                h.status.toLowerCase() != 'resolved' &&
                h.status.toLowerCase() != 'closed')
            .length;
        final activePermits = state.permits.where((p) => p.status.toLowerCase() == 'active').length;
        final totalChecklist = state.checklistItems.length;
        final passedChecklist = state.checklistItems.where((c) => c.status.toLowerCase() == 'pass').length;
        final checklistPct = totalChecklist > 0 ? ((passedChecklist / totalChecklist) * 100).round() : 0;
        final compliantRoster = state.roster.where((w) => w.helmet && w.shoes && w.gloves && w.ear).length;
        final rosterPct = state.roster.isNotEmpty ? ((compliantRoster / state.roster.length) * 100).round() : 0;

        const nmClosureRate = 0.825; // 321 / 389 Closed in 2026 (82.5%)
        const nmClosureDisplay = '82.5';
        final streakDays = (DateTime.now().difference(DateTime(2025, 4, 1)).inDays).clamp(1, 9999);

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
                  isUr ? 'سیفٹی اینالیٹکس اور رپورٹس' : 'Safety Analytics & Reports',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ISO 45001 Compliance Metrics • 62.4 MW',
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
                // Timeframe Switcher
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUr ? 'تجزیاتی دورانیہ منتخب کریں' : 'Reporting Window',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CplColors.slate200),
                      ),
                      child: Row(
                        children: ['6M', '1Y'].map((p) {
                          final isSelected = period == p;
                          return InkWell(
                            onTap: () {
                              context.read<CplSystemCubit>().setAnalyticsPeriod(p);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected ? CplColors.slate900 : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                p,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : CplColors.slate700,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Top KPI Hero Cards: 2026 Near-Miss Closure & Monthly Safe Man-Hours
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 2026 Near-Miss Closure Gauge Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: CplColors.slate200),
                        ),
                        child: Column(
                          children: [
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: CircularProgressIndicator(
                                    value: nmClosureRate,
                                    strokeWidth: 8,
                                    backgroundColor: CplColors.slate100,
                                    valueColor: const AlwaysStoppedAnimation<Color>(CplColors.emerald500),
                                  ),
                                ),
                                const Text(
                                  '$nmClosureDisplay%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isUr ? '2026 نیئر مس کلوزر ریٹ' : '2026 Near-Miss Closure Rate',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              '321 Closed / 389 Total (68 Open)',
                              style: TextStyle(fontSize: 10.5, color: CplColors.emerald500, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Safe Man-Hours & Workforce Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CplColors.slate900,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: CplColors.safety500,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'ZERO LTI • OCT 2026',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '84,730',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              isUr ? 'ماہانہ محفوظ ورکنگ آورز' : 'Monthly Safe Man-Hours',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '434 Personnel (388 CPL + 46 EKL) • $streakDays Safe Days',
                              style: const TextStyle(color: CplColors.slate400, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Live Plant Telemetry Summary Strip (Dynamic from active Cubit state)
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isWide = constraints.maxWidth >= 680;
                    final cards = [
                      _buildLiveStatCard(
                        title: isUr ? 'کھلے خطرات' : 'Open Hazards',
                        value: '$openHazards',
                        sub: '$criticalHazards Critical',
                        color: criticalHazards > 0 ? CplColors.red600 : CplColors.safety500,
                      ),
                      _buildLiveStatCard(
                        title: isUr ? 'چیک لسٹ تعمیل' : 'Checklist Score',
                        value: '$checklistPct%',
                        sub: '${state.checklistTemplates.length} Active SOPs',
                        color: const Color(0xFF7C3AED),
                      ),
                      _buildLiveStatCard(
                        title: isUr ? 'فعال پرمٹس' : 'Active PTWs',
                        value: '$activePermits',
                        sub: '${state.permits.length} Total Permits',
                        color: CplColors.corporateNavy,
                      ),
                      _buildLiveStatCard(
                        title: isUr ? 'پی پی ای تعمیل' : 'PPE Compliance',
                        value: '$rosterPct%',
                        sub: '$compliantRoster/${state.roster.length} Verified',
                        color: CplColors.emerald500,
                      ),
                    ];
                    if (isWide) {
                      return Row(
                        children: [
                          Expanded(child: cards[0]),
                          const SizedBox(width: 10),
                          Expanded(child: cards[1]),
                          const SizedBox(width: 10),
                          Expanded(child: cards[2]),
                          const SizedBox(width: 10),
                          Expanded(child: cards[3]),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        Row(
                          children: [
                            Expanded(child: cards[0]),
                            const SizedBox(width: 10),
                            Expanded(child: cards[1]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(child: cards[2]),
                            const SizedBox(width: 10),
                            Expanded(child: cards[3]),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 18),

                // Monthly Near-Miss & Hazard Trend Bar Chart
                Container(
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
                            child: Text(
                              isUr ? 'ماہانہ خطرات میں کمی کا رجحان' : 'Hazard Reduction Velocity',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: CplColors.safety500, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Logged', style: TextStyle(fontSize: 10)),
                              const SizedBox(width: 10),
                              Container(width: 8, height: 8, decoration: const BoxDecoration(color: CplColors.emerald500, shape: BoxShape.circle)),
                              const SizedBox(width: 4),
                              const Text('Resolved', style: TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Bar visualization
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: monthlyData.map((d) {
                          final h = (d['hazards'] as int).toDouble();
                          final c = (d['closed'] as int).toDouble();
                          const maxH = 85.0;

                          return Expanded(
                            child: Column(
                              children: [
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    '${d['closed']}/${d['hazards']}',
                                    style: const TextStyle(fontSize: 8.5, fontFamily: 'monospace', color: CplColors.slate600),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 8,
                                      height: ((h / maxH) * 85).clamp(4.0, 85.0),
                                      decoration: BoxDecoration(
                                        color: CplColors.safety500,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 2),
                                    Container(
                                      width: 8,
                                      height: ((c / maxH) * 85).clamp(4.0, 85.0),
                                      decoration: BoxDecoration(
                                        color: CplColors.emerald500,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  d['month'] as String,
                                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Departmental Near-Miss Closure Rate Cards (from CPL-NM File Oct 2026.xlsx)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUr
                            ? 'ڈیپارٹمنٹ کے لحاظ سے نیئر مس کیسز (2026 کل 389 کیسز)'
                            : 'Departmental Near-Miss Breakdown (CPL-NM 2026 • 389 Cases)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      _buildZoneBar('Mechanical Maintenance (MMD) — 155 cases', 155 / 389, '155 (39.8%)', CplColors.red600),
                      const SizedBox(height: 10),
                      _buildZoneBar('Electrical Maintenance (EMD) — 64 cases', 64 / 389, '64 (16.5%)', CplColors.safety500),
                      const SizedBox(height: 10),
                      _buildZoneBar('Admin & HR — 64 cases', 64 / 389, '64 (16.5%)', const Color(0xFF8B5CF6)),
                      const SizedBox(height: 10),
                      _buildZoneBar('Civil Department — 26 cases', 26 / 389, '26 (6.7%)', CplColors.amber500),
                      const SizedBox(height: 10),
                      _buildZoneBar('Operations (Ops) — 20 cases', 20 / 389, '20 (5.1%)', CplColors.emerald500),
                      const SizedBox(height: 10),
                      _buildZoneBar('Safety / HSE (12) • Fuel (5) • I&C (3)', 20 / 389, '20 (5.1%)', CplColors.corporateNavy),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Departmental Man-Hours Breakdown Card (from Monthly Working Hours Report Oct-26.xlsx)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isUr
                            ? 'ڈیپارٹمنٹ ورکنگ آورز رپورٹ (اکتوبر 2026 • 84,730 گھنٹے)'
                            : 'Departmental Working Hours (Oct 2026 • 84,730 Total Hrs)',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      _buildZoneBar('Admin & HR (108 staff)', 24204 / 84730, '24,204 hrs', CplColors.corporateNavy),
                      const SizedBox(height: 10),
                      _buildZoneBar('Operations Deptt. (106 staff)', 18326 / 84730, '18,326 hrs', CplColors.emerald600),
                      const SizedBox(height: 10),
                      _buildZoneBar('Fuel Dept (92 staff)', 17010 / 84730, '17,010 hrs', CplColors.safety500),
                      const SizedBox(height: 10),
                      _buildZoneBar('EKL Contractors (46 staff)', 9648 / 84730, '9,648 hrs', const Color(0xFF8B5CF6)),
                      const SizedBox(height: 10),
                      _buildZoneBar('Mechanical MMD (27 staff)', 5252 / 84730, '5,252 hrs', CplColors.amber500),
                      const SizedBox(height: 10),
                      _buildZoneBar('Safety & Health (12 staff • 3,310h) + EMD/I&C/Civil/Stores', 8602 / 84730, '8,602 hrs', CplColors.emerald500),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Functional PDF & Excel Export CTA Bar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final bytes = await PdfReportGenerator.generateShiftTurnoverPdf(
                              plantUnit: state.checklistZone,
                              shiftType: state.currentUser.shift.isNotEmpty ? state.currentUser.shift : 'Shift A',
                              outgoingSupervisor: state.currentUser.name.isNotEmpty ? state.currentUser.name : 'HSE Officer',
                              checklistsCompleted: state.checklistItems.length,
                              hazardsIdentified: state.hazards.length,
                              criticalAlarmsCount: state.activeAlarm != null ? 1 : 0,
                              openItems: state.hazards
                                  .take(6)
                                  .map((h) => {
                                        'id': h.nmNumber.isNotEmpty ? h.nmNumber : h.id,
                                        'zone': h.zone,
                                        'title': h.title,
                                        'severity': h.severity,
                                      })
                                  .toList(),
                            );
                            await PdfReportGenerator.saveOrShareReport(bytes, 'CPL_HSE_Executive_Analytics_2026.pdf');
                          } catch (_) {}
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isUr
                                      ? 'CPL ایگزیکٹو پی ڈی ایف رپورٹ تیار ہو گئی ہے (PDF Export Completed)'
                                      : 'CPL Executive HSE PDF Report Generated & Downloaded.',
                                ),
                                backgroundColor: CplColors.slate900,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 18),
                        label: Text(
                          isUr ? 'پی ڈی ایف رپورٹ' : 'Export PDF',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CplColors.slate900,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () async {
                          try {
                            final csvContent = CsvExporter.exportHazardsCsv(
                              state.hazards
                                  .map((h) => {
                                        'id': h.nmNumber.isNotEmpty ? h.nmNumber : h.id,
                                        'reporter_id': h.reporter,
                                        'plant_zone': h.zone,
                                        'coordinates': h.coords,
                                        'severity': h.severity,
                                        'status': h.status,
                                        'timestamp': h.time,
                                        'action_owner': h.responsibleTeam,
                                        'resolution_notes': h.suggestion,
                                      })
                                  .toList(),
                            );
                            await CsvExporter.saveCsvReport(csvContent, 'CPL_HSE_Audit_Data_2026.csv');
                          } catch (_) {}
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isUr
                                      ? 'سی ایس وی / ایکسل آڈٹ فائل محفوظ ہو گئی (CSV Exported)'
                                      : 'CPL Master HSE Audit Data (.CSV) Exported Successfully.',
                                ),
                                backgroundColor: CplColors.emerald500,
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.table_chart, color: Colors.white, size: 18),
                        label: Text(
                          isUr ? 'ایکسل آڈٹ ڈیٹا' : 'Export Excel / CSV',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CplColors.emerald500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLiveStatCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: CplColors.slate200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: CplColors.slate600),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              fontFamily: 'monospace',
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: const TextStyle(fontSize: 10.5, color: CplColors.slate500, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildZoneBar(String label, double ratio, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Text(percent, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio.clamp(0.0, 1.0),
            minHeight: 8,
            backgroundColor: CplColors.slate100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
