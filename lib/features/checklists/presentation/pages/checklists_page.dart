import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:printing/printing.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../domain/entities/checklist.dart';
import '../cubit/checklist_cubit.dart';
import '../cubit/checklist_state.dart';
import 'execute_checklist_page.dart';

class ChecklistsPage extends StatefulWidget {
  const ChecklistsPage({super.key});

  @override
  State<ChecklistsPage> createState() => _ChecklistsPageState();
}

class _ChecklistsPageState extends State<ChecklistsPage> {
  ShiftType _selectedShift = ShiftType.morning;

  @override
  void initState() {
    super.initState();
    context.read<ChecklistCubit>().loadChecklists();
  }

  void _exportPdf(ChecklistAudit audit) async {
    final pdfBytes = await context.read<ChecklistCubit>().exportTurnoverPdf(
      audit: audit,
      outstandingHazards: [],
    );

    await Printing.layoutPdf(
      onLayout: (format) async => pdfBytes,
      name: 'Chiniot_Power_Shift_Turnover_${audit.id}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Safety Checklists & Shift Handover'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ChecklistCubit>().loadChecklists(),
          ),
        ],
      ),
      body: BlocBuilder<ChecklistCubit, ChecklistState>(
        builder: (context, state) {
          if (state is ChecklistLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChecklistLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: isDesktop ? 1080 : double.infinity),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Active Shift Selection Banner
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Active Plant Shift Execution',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Select target shift for daily compliance logs & turnover reporting',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                              DropdownButton<ShiftType>(
                                value: _selectedShift,
                                items: ShiftType.values.map((s) {
                                  return DropdownMenuItem(value: s, child: Text(s.label));
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => _selectedShift = val);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Section Header: Available Templates
                      const Text(
                        'Launch Shift Inspection Form',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      // Templates Grid / List
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final crossAxisCount = constraints.maxWidth > 700 ? 2 : 1;
                          return GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: isDesktop ? 2.8 : 2.2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: state.templates.length,
                            itemBuilder: (context, index) {
                              final tpl = state.templates[index];
                              return Card(
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(12),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ExecuteChecklistPage(
                                          template: tpl,
                                          shiftType: _selectedShift,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: AppColors.primaryLight.withAlpha((0.15 * 255).round()),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Icon(Icons.assignment, color: AppColors.primaryLight),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                tpl.title,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '${tpl.plantUnit} • ${tpl.defaultItems.length} checklist items',
                                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondaryDark),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 28),

                      // Section Header: Executed Audits & Shift Logs
                      const Text(
                        'Recent Shift Turnover Audits',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),

                      if (state.audits.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No shift audits executed today yet.'),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.audits.length,
                          itemBuilder: (context, index) {
                            final audit = state.audits[index];

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: audit.failCount > 0 ? AppColors.riskMedium : AppColors.riskLow,
                                      child: Icon(
                                        audit.failCount > 0 ? Icons.warning_amber : Icons.check,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            audit.title,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${audit.plantUnit} • ${audit.shiftType} • Inspector: ${audit.inspectorName}',
                                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Result: ${audit.passCount} Passed, ${audit.failCount} Failed, ${audit.naCount} N/A (${audit.completionRate}%)',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: audit.failCount > 0 ? AppColors.riskHigh : AppColors.riskLow,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () => _exportPdf(audit),
                                      icon: const Icon(Icons.picture_as_pdf, size: 16),
                                      label: const Text('PDF Report'),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

