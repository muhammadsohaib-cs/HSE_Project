import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';
import '../cpl_system/models/cpl_models.dart';

class PtwScreen extends StatelessWidget {
  const PtwScreen({super.key});

  Color _getTypeColor(String type) {
    switch (type) {
      case 'Hot Work': return CplColors.red600;
      case 'LOTO': return CplColors.safety500;
      case 'Confined Space': return const Color(0xFF8B5CF6);
      default: return CplColors.slate700;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active': return CplColors.emerald500;
      case 'Pending': return CplColors.amber500;
      case 'Hold': return CplColors.red600;
      default: return CplColors.slate700;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final activeFilter = state.ptwFilter;

        List<PtwItem> filteredPermits = state.permits;
        if (activeFilter == 'Active') {
          filteredPermits = state.permits.where((p) => p.status == 'Active').toList();
        } else if (activeFilter == 'Pending') {
          filteredPermits = state.permits.where((p) => p.status == 'Pending').toList();
        } else if (activeFilter == 'LOTO') {
          filteredPermits = state.permits.where((p) => p.type == 'LOTO' || p.lotoTags.isNotEmpty).toList();
        }

        final filters = ['All', 'Active', 'Pending', 'LOTO'];

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
                  isUr ? 'پرمٹ ٹو ورک اور LOTO' : 'Permit to Work & LOTO',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'High-Voltage & Hazardous Energy Isolation',
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
                // Top Filter Pills
                Row(
                  children: filters.map((f) {
                    final isSelected = activeFilter == f;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: InkWell(
                          onTap: () {
                            context.read<CplSystemCubit>().setPtwFilter(f);
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? CplColors.slate900 : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? CplColors.slate900 : CplColors.slate200,
                              ),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                color: isSelected ? Colors.white : CplColors.slate700,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Live LOTO Isolation Summary Banner
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: CplColors.safety500.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lock_clock, color: CplColors.safety500, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isUr ? '14 فعال LOTO پیڈ لاکس محفوظ ہیں' : '14 Active LOTO Padlocks Engaged',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isUr
                                  ? '132kV سوئچ یارڈ اور بوائلر ٹربائن پر پاور آئسولیشن کی تصدیق ہے'
                                  : 'Zero-voltage verified across 132kV Switchyard & Turbine Hall',
                              style: TextStyle(fontSize: 11.5, color: CplColors.slate600),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // List of Permits
                ...filteredPermits.map((ptw) {
                  final typeColor = _getTypeColor(ptw.type);
                  final statusColor = _getStatusColor(ptw.status);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: CplColors.slate200),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Left color strip
                          Container(
                            width: 6,
                            color: typeColor,
                          ),
                          // Content
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Top Row: Permit ID + Type Badge + Status Badge
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            ptw.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12.5,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: typeColor.withOpacity(0.12),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              ptw.type,
                                              style: TextStyle(
                                                color: typeColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10.5,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: statusColor.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          ptw.status,
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  // Title
                                  Text(
                                    ptw.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: CplColors.slate900,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  // Zone & Requester
                                  Row(
                                    children: [
                                      const Icon(Icons.location_on, size: 14, color: CplColors.slate600),
                                      const SizedBox(width: 4),
                                      Text(ptw.zone, style: const TextStyle(fontSize: 12, color: CplColors.slate600)),
                                      const Spacer(),
                                      const Icon(Icons.person, size: 14, color: CplColors.slate600),
                                      const SizedBox(width: 4),
                                      Text(
                                        ptw.requester.split('(').first.trim(),
                                        style: const TextStyle(fontSize: 12, color: CplColors.slate600),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Telemetry & LOTO Bar
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: CplColors.slate50,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: CplColors.slate200),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.sensors, size: 16, color: CplColors.safety500),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            ptw.telemetry,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              fontFamily: 'monospace',
                                            ),
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: CplColors.slate200),
                                          ),
                                          child: Text(
                                            ptw.lotoTags,
                                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  // Action Row: Timer + Approve/Hold Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(Icons.timer, size: 14, color: CplColors.slate600),
                                          const SizedBox(width: 4),
                                          Text(
                                            ptw.timer,
                                            style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          if (ptw.status != 'Active')
                                            ElevatedButton(
                                              onPressed: () {
                                                context.read<CplSystemCubit>().setPermitStatus(ptw.id, 'Active');
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Permit ${ptw.id} Approved & Live'),
                                                    backgroundColor: CplColors.emerald500,
                                                  ),
                                                );
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: CplColors.emerald500,
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              child: Text(
                                                isUr ? 'منظور کریں' : 'Approve',
                                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          if (ptw.status == 'Active')
                                            OutlinedButton(
                                              onPressed: () {
                                                context.read<CplSystemCubit>().setPermitStatus(ptw.id, 'Hold');
                                                ScaffoldMessenger.of(context).showSnackBar(
                                                  SnackBar(
                                                    content: Text('Permit ${ptw.id} Suspended on Hold'),
                                                    backgroundColor: CplColors.red600,
                                                  ),
                                                );
                                              },
                                              style: OutlinedButton.styleFrom(
                                                foregroundColor: CplColors.red600,
                                                side: const BorderSide(color: CplColors.red600),
                                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                              ),
                                              child: Text(
                                                isUr ? 'روک دیں (Hold)' : 'Hold',
                                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Issue New Permit CTA
                ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('PTW Application form loaded. Required JSA & LOTO isolation tags attached.'),
                        backgroundColor: CplColors.slate900,
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_moderator),
                  label: Text(
                    isUr ? 'نیا پرمٹ ٹو ورک (PTW) جاری کریں' : '+ Request New Work Permit (PTW)',
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
}
