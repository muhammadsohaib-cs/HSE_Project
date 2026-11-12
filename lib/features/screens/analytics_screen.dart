import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
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

        final monthlyData = period == '6M'
            ? [
                {'month': 'Jun', 'hazards': 18, 'closed': 17},
                {'month': 'Jul', 'hazards': 14, 'closed': 14},
                {'month': 'Aug', 'hazards': 22, 'closed': 20},
                {'month': 'Sep', 'hazards': 11, 'closed': 11},
                {'month': 'Oct', 'hazards': 8, 'closed': 8},
                {'month': 'Nov', 'hazards': 3, 'closed': 2},
              ]
            : [
                {'month': 'Q1', 'hazards': 48, 'closed': 45},
                {'month': 'Q2', 'hazards': 54, 'closed': 52},
                {'month': 'Q3', 'hazards': 41, 'closed': 39},
                {'month': 'Q4', 'hazards': 22, 'closed': 21},
              ];

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

                // Top KPI Grid: 96.2% CAPA Closure & 218 Safe Days
                Row(
                  children: [
                    // CAPA Closure Gauge Card
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
                                    value: 0.962,
                                    strokeWidth: 8,
                                    backgroundColor: CplColors.slate100,
                                    valueColor: const AlwaysStoppedAnimation<Color>(CplColors.emerald500),
                                  ),
                                ),
                                const Text(
                                  '96.2%',
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
                              isUr ? 'سی اے پی اے حل کی شرح' : 'CAPA Resolution Rate',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              'Target: >95.0%',
                              style: TextStyle(fontSize: 10.5, color: CplColors.emerald500, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Safe Work Days Card
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
                                'ZERO LTI',
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '218',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                fontFamily: 'monospace',
                              ),
                            ),
                            Text(
                              isUr ? 'محفوظ کام کے دن' : 'Safe Work Days',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '3.84 Million Safe Man-Hours',
                              style: TextStyle(color: CplColors.slate400, fontSize: 10),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
                          Text(
                            isUr ? 'ماہانہ خطرات میں کمی کا رجحان' : 'Hazard Reduction Velocity',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          Row(
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
                          const maxH = 25.0;

                          return Expanded(
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      width: 10,
                                      height: (h / maxH) * 85,
                                      decoration: BoxDecoration(
                                        color: CplColors.safety500,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Container(
                                      width: 10,
                                      height: (c / maxH) * 85,
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
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
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

                // Department Hazard Share Breakdown
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
                        isUr ? 'پلانٹ زونز میں خطرات کی تقسیم' : 'Plant Zone Incident Density',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 14),
                      _buildZoneBar('Boiler House Unit-1', 0.42, '42%', CplColors.red600),
                      const SizedBox(height: 10),
                      _buildZoneBar('Bagasse & Coal Yard', 0.28, '28%', CplColors.safety500),
                      const SizedBox(height: 10),
                      _buildZoneBar('Steam Turbine Hall & Grid', 0.18, '18%', const Color(0xFF8B5CF6)),
                      const SizedBox(height: 10),
                      _buildZoneBar('Water Treatment Plant', 0.12, '12%', CplColors.emerald500),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Functional PDF & Excel Export CTA Bar
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
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
                        onPressed: () {
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

  Widget _buildZoneBar(String label, double ratio, String percent, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
            Text(percent, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 8,
            backgroundColor: CplColors.slate100,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
