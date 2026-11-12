import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../../../core/utils/csv_exporter.dart';
import '../../../../core/utils/pdf_generator.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../../checklists/presentation/cubit/checklist_cubit.dart';
import '../../../checklists/presentation/cubit/checklist_state.dart';
import '../../../emergency_alarms/presentation/cubit/alarm_cubit.dart';
import '../../../emergency_alarms/presentation/cubit/alarm_state.dart';
import '../../../hazards/domain/entities/hazard.dart';
import '../../../hazards/presentation/cubit/hazard_cubit.dart';
import '../../../hazards/presentation/cubit/hazard_state.dart';
import '../../../hazards/presentation/pages/hazard_detail_page.dart';
import '../../../training/presentation/cubit/training_cubit.dart';
import '../../../training/presentation/cubit/training_state.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    _refreshAll();
  }

  void _refreshAll() {
    context.read<HazardCubit>().loadHazards();
    context.read<ChecklistCubit>().loadChecklists();
    context.read<AlarmCubit>().loadAlarms();
    final authState = context.read<AuthCubit>().state;
    String empId = 'CP-EMP-1002';
    if (authState is Authenticated) empId = authState.user.employeeId;
    context.read<TrainingCubit>().loadTrainingData(empId);
  }

  void _exportHazardsCsv(List<Hazard> hazards) {
    final rawData = hazards.map((h) => {
      'id': h.id,
      'reporter_id': h.reporterId,
      'plant_zone': h.plantZone,
      'coordinates': h.coordinates.toString(),
      'severity': h.severity,
      'probability': h.probability,
      'score': h.score,
      'risk_band': h.riskBand.label,
      'status': h.status.label,
      'timestamp': h.createdAt.toIso8601String(),
      'action_owner': h.assignedTo,
      'resolution_notes': h.correctiveAction,
    }).toList();

    final csvString = CsvExporter.exportHazardsCsv(rawData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hazards Audit CSV Exported (${rawData.length} rows)'),
        backgroundColor: AppColors.riskLow,
      ),
    );
  }

  void _exportTurnoverReportPdf() async {
    final pdfBytes = await PdfReportGenerator.generateShiftTurnoverPdf(
      plantUnit: 'Chiniot Power Complex (All Units)',
      shiftType: 'Main Shift Operations',
      outgoingSupervisor: 'HSE Manager Asim Raza',
      checklistsCompleted: 4,
      hazardsIdentified: 2,
      criticalAlarmsCount: 0,
      openItems: [
        {'zone': PlantZones.boilerSection, 'description': 'Steam flange weeping on line 3B', 'risk': 'Critical', 'action': 'Night-shift isolation'},
        {'zone': PlantZones.coalHandling, 'description': 'Conveyor pull-cord microswitch replaced', 'risk': 'Medium', 'action': 'Verified operational'},
      ],
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Chiniot_Power_Executive_HSE_Report.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plant HSE Operations & Command Dashboard'),
        actions: [
          TextButton.icon(
            onPressed: () {
              final hazardState = context.read<HazardCubit>().state;
              if (hazardState is HazardLoaded) {
                _exportHazardsCsv(hazardState.hazards);
              }
            },
            icon: const Icon(Icons.table_chart_outlined, size: 18),
            label: const Text('Export CSV'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _exportTurnoverReportPdf,
            icon: const Icon(Icons.picture_as_pdf, size: 16),
            label: const Text('Export PDF Report'),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAll,
            tooltip: 'Refresh Telemetry',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 1280 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top KPI Metrics Cards
                _buildKpiMetricsRow(isDesktop),
                const SizedBox(height: 24),

                // 2-Column Desktop Grid or Stacked Mobile (Plant Zone Hazard Heatmap & Critical Alarms)
                if (isDesktop)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 3, child: _buildZoneRiskOverviewCard()),
                      const SizedBox(width: 20),
                      Expanded(flex: 2, child: _buildActiveAlarmsFeedCard()),
                    ],
                  )
                else ...[
                  _buildZoneRiskOverviewCard(),
                  const SizedBox(height: 20),
                  _buildActiveAlarmsFeedCard(),
                ],

                const SizedBox(height: 28),

                // Recent Incidents & CAPA Table
                _buildLatestHazardsTableCard(isDesktop),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKpiMetricsRow(bool isDesktop) {
    return BlocBuilder<HazardCubit, HazardState>(
      builder: (context, hazardState) {
        int totalHazards = 0;
        int criticalHazards = 0;
        int openCapas = 0;

        if (hazardState is HazardLoaded) {
          totalHazards = hazardState.hazards.length;
          criticalHazards = hazardState.hazards.where((h) => h.score >= 15).length;
          openCapas = hazardState.hazards.where((h) => !h.isClosed).length;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Total Hazards Logged',
                  value: '$totalHazards',
                  subtitle: 'All plant zones',
                  icon: Icons.report_problem_outlined,
                  color: AppColors.primaryLight,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Critical Risk Items',
                  value: '$criticalHazards',
                  subtitle: 'Score ≥ 15 (Stop Work)',
                  icon: Icons.emergency_rounded,
                  color: AppColors.emergencyRed,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Open CAPA Actions',
                  value: '$openCapas',
                  subtitle: 'Pending verification / closure',
                  icon: Icons.pending_actions_rounded,
                  color: AppColors.riskMedium,
                ),
                _buildKpiCard(
                  width: cardWidth,
                  title: 'Plant Shift Compliance',
                  value: '98.4%',
                  subtitle: 'Daily audits executed',
                  icon: Icons.verified_user_outlined,
                  color: AppColors.riskLow,
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildKpiCard({
    required double width,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderDark),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark)),
        ],
      ),
    );
  }

  Widget _buildZoneRiskOverviewCard() {
    return BlocBuilder<HazardCubit, HazardState>(
      builder: (context, state) {
        final List<Hazard> hazards = state is HazardLoaded ? state.hazards : [];

        // Count per zone
        final Map<String, int> zoneCounts = {};
        for (final z in PlantZones.allZones.take(6)) {
          zoneCounts[z] = hazards.where((h) => h.plantZone == z).length;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Plant Zone Hazard Density',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text('Active Areas', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
                  ],
                ),
                const SizedBox(height: 16),
                ...zoneCounts.entries.map((entry) {
                  final count = entry.value;
                  final percentage = hazards.isNotEmpty ? (count / hazards.length) : 0.0;
                  final color = count == 0 ? AppColors.riskLow : (count > 1 ? AppColors.riskHigh : AppColors.riskMedium);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(entry.key, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                            Text('$count Hazards', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        LinearProgressIndicator(
                          value: percentage == 0 ? 0.05 : percentage,
                          backgroundColor: Colors.grey.shade800,
                          color: color,
                          minHeight: 6,
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveAlarmsFeedCard() {
    return BlocBuilder<AlarmCubit, AlarmState>(
      builder: (context, state) {
        final List alarms = state is AlarmLoaded ? state.alarms : [];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Emergency Alarms Stream',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.notifications_active_outlined, color: AppColors.emergencyRed, size: 20),
                  ],
                ),
                const SizedBox(height: 16),
                if (alarms.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: Text(
                        'No active alarms. Plant operating in safe status.',
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                      ),
                    ),
                  )
                else
                  ...alarms.take(3).map((a) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.backgroundDark,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                a.plantArea,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                a.severityLevel.title,
                                style: const TextStyle(color: AppColors.emergencyRed, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            a.description,
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLatestHazardsTableCard(bool isDesktop) {
    return BlocBuilder<HazardCubit, HazardState>(
      builder: (context, state) {
        final hazards = state is HazardLoaded ? state.hazards : <Hazard>[];

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Live Hazard Identification & Mitigation Register',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Real-Time Synced',
                      style: TextStyle(fontSize: 12, color: AppColors.riskLow, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (hazards.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No active hazards logged.'),
                    ),
                  )
                else if (isDesktop)
                  SizedBox(
                    width: double.infinity,
                    child: DataTable(
                      showCheckboxColumn: false,
                      columns: const [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Zone')),
                        DataColumn(label: Text('Hazard Description')),
                        DataColumn(label: Text('Risk Band')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: hazards.take(5).map((h) {
                        final band = h.riskBand;
                        return DataRow(
                          onSelectChanged: (_) {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => HazardDetailPage(hazard: h)),
                            );
                          },
                          cells: [
                            DataCell(Text(h.id, style: const TextStyle(fontWeight: FontWeight.bold))),
                            DataCell(Text(h.plantZone)),
                            DataCell(
                              ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 300),
                                child: Text(h.title, overflow: TextOverflow.ellipsis),
                              ),
                            ),
                            DataCell(
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: band.color.withAlpha((0.2 * 255).round()),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${band.label} (${h.score})',
                                  style: TextStyle(color: band.color, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                            ),
                            DataCell(Text(h.status.label)),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.open_in_new, size: 16),
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(builder: (_) => HazardDetailPage(hazard: h)),
                                  );
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  )
                else
                  Column(
                    children: hazards.take(4).map((h) {
                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(h.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: Text('${h.plantZone} • ${h.status.label}'),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: h.riskBand.color.withAlpha((0.2 * 255).round()),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '${h.score}',
                            style: TextStyle(fontWeight: FontWeight.bold, color: h.riskBand.color),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => HazardDetailPage(hazard: h)),
                          );
                        },
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

