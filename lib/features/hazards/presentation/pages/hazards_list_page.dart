import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../domain/entities/hazard.dart';
import '../cubit/hazard_cubit.dart';
import '../cubit/hazard_state.dart';
import 'hazard_detail_page.dart';
import 'report_hazard_page.dart';

class HazardsListPage extends StatefulWidget {
  const HazardsListPage({super.key});

  @override
  State<HazardsListPage> createState() => _HazardsListPageState();
}

class _HazardsListPageState extends State<HazardsListPage> {
  String? _selectedZone;
  CapaStatus? _selectedStatus;

  @override
  void initState() {
    super.initState();
    context.read<HazardCubit>().loadHazards();
  }

  void _onZoneFilterChanged(String? zone) {
    setState(() => _selectedZone = zone);
    context.read<HazardCubit>().filterHazards(plantZone: zone, status: _selectedStatus);
  }

  void _onStatusFilterChanged(CapaStatus? status) {
    setState(() => _selectedStatus = status);
    context.read<HazardCubit>().filterHazards(plantZone: _selectedZone, status: status);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hazards & CAPA Tracking'),
        actions: [
          BlocBuilder<HazardCubit, HazardState>(
            builder: (context, state) {
              if (state is HazardLoaded && state.pendingOfflineCount > 0) {
                return TextButton.icon(
                  onPressed: state.isSyncing
                      ? null
                      : () => context.read<HazardCubit>().syncOfflineBuffer(),
                  icon: state.isSyncing
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.riskMedium),
                        )
                      : const Icon(Icons.cloud_upload_outlined, color: AppColors.riskMedium),
                  label: Text(
                    'Sync (${state.pendingOfflineCount})',
                    style: const TextStyle(color: AppColors.riskMedium, fontWeight: FontWeight.bold),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<HazardCubit>().loadHazards(
                  plantZone: _selectedZone,
                  status: _selectedStatus,
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const ReportHazardPage()),
          );
        },
        icon: const Icon(Icons.add_alert_rounded),
        label: const Text('Report Hazard'),
        backgroundColor: AppColors.emergencyRed,
      ),
      body: Column(
        children: [
          // Filter Bar
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButton<String?>(
                      value: _selectedZone,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Text('Filter by Plant Zone (All)'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Plant Zones')),
                        ...PlantZones.allZones.map((z) => DropdownMenuItem(value: z, child: Text(z))),
                      ],
                      onChanged: _onZoneFilterChanged,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButton<CapaStatus?>(
                      value: _selectedStatus,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      hint: const Text('Filter by Status (All)'),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All CAPA Statuses')),
                        ...CapaStatus.values.map(
                          (s) => DropdownMenuItem(value: s, child: Text(s.label)),
                        ),
                      ],
                      onChanged: _onStatusFilterChanged,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Hazards List / Table View
          Expanded(
            child: BlocBuilder<HazardCubit, HazardState>(
              builder: (context, state) {
                if (state is HazardLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is HazardError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: AppColors.emergencyRed),
                        const SizedBox(height: 12),
                        Text(state.message),
                        const SizedBox(height: 12),
                        ElevatedButton(
                          onPressed: () => context.read<HazardCubit>().loadHazards(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                if (state is HazardLoaded) {
                  if (state.hazards.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.verified_outlined, size: 54, color: AppColors.riskLow),
                          const SizedBox(height: 12),
                          const Text(
                            'No open hazards found for selected filters',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'All operational areas are within nominal safety thresholds.',
                            style: TextStyle(color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    );
                  }

                  return isDesktop
                      ? _buildDesktopDataTable(state.hazards)
                      : _buildMobileListView(state.hazards);
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileListView(List<Hazard> hazards) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: hazards.length,
      itemBuilder: (context, index) {
        final h = hazards[index];
        final band = h.riskBand;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HazardDetailPage(hazard: h)),
            ),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: band.color.withAlpha((0.2 * 255).round()),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: band.color),
                        ),
                        child: Text(
                          '${band.label} (${h.score})',
                          style: TextStyle(color: band.color, fontWeight: FontWeight.bold, fontSize: 11),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: AppColors.borderDark),
                        ),
                        child: Text(
                          h.status.label,
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    h.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    h.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryDark),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        h.plantZone,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                      Text(
                        h.id,
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDesktopDataTable(List<Hazard> hazards) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: SizedBox(
          width: double.infinity,
          child: DataTable(
            showCheckboxColumn: false,
            columns: const [
              DataColumn(label: Text('Hazard ID', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Plant Zone', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Title / Summary', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Risk Score', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('CAPA Status', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Reporter', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: hazards.map((h) {
              final band = h.riskBand;
              return DataRow(
                onSelectChanged: (_) {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => HazardDetailPage(hazard: h)),
                  );
                },
                cells: [
                  DataCell(Text(h.id, style: const TextStyle(fontWeight: FontWeight.w600))),
                  DataCell(Text(h.plantZone)),
                  DataCell(
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 260),
                      child: Text(
                        h.title,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ),
                  DataCell(
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: band.color.withAlpha((0.2 * 255).round()),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: band.color),
                      ),
                      child: Text(
                        '${band.label} (${h.score})',
                        style: TextStyle(color: band.color, fontWeight: FontWeight.bold, fontSize: 11),
                      ),
                    ),
                  ),
                  DataCell(
                    Chip(
                      label: Text(h.status.label, style: const TextStyle(fontSize: 11)),
                      padding: EdgeInsets.zero,
                    ),
                  ),
                  DataCell(Text('${h.reporterName} (${h.reporterId})')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.arrow_forward, size: 18),
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
        ),
      ),
    );
  }
}

