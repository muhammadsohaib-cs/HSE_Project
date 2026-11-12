import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/media_service.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/checklist.dart';
import '../cubit/checklist_cubit.dart';

class ExecuteChecklistPage extends StatefulWidget {
  final ChecklistTemplate template;
  final ShiftType shiftType;

  const ExecuteChecklistPage({
    super.key,
    required this.template,
    this.shiftType = ShiftType.morning,
  });

  @override
  State<ExecuteChecklistPage> createState() => _ExecuteChecklistPageState();
}

class _ExecuteChecklistPageState extends State<ExecuteChecklistPage> {
  late List<ChecklistItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.template.defaultItems);
  }

  void _onStatusToggle(int index, ChecklistItemStatus status) {
    if (status == ChecklistItemStatus.fail) {
      _showFailureDeviationDialog(index);
    } else {
      setState(() {
        _items[index] = _items[index].copyWith(
          status: status,
          deviationNotes: null,
          deviationPhotoUrl: null,
        );
      });
    }
  }

  void _showFailureDeviationDialog(int index) {
    final noteController = TextEditingController(text: _items[index].deviationNotes ?? '');
    String? photoUrl = _items[index].deviationPhotoUrl;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.report_problem_rounded, color: AppColors.riskHigh),
              SizedBox(width: 8),
              Text('Deviation Report (Mandatory)'),
            ],
          ),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _items[index].title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: noteController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Deviation Description & Non-Compliance Reason *',
                    hintText: 'Describe physical anomaly, leakage, or defective safeguard...',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        photoUrl ?? 'No deviation photo attached',
                        style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        final media = await MediaService().capturePhoto();
                        if (media != null) {
                          setDialogState(() => photoUrl = media.path);
                        }
                      },
                      icon: const Icon(Icons.camera_alt, size: 16),
                      label: const Text('Add Photo'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskHigh),
              onPressed: () {
                final notes = noteController.text.trim();
                if (notes.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Deviation notes are mandatory for failed items')),
                  );
                  return;
                }

                setState(() {
                  _items[index] = _items[index].copyWith(
                    status: ChecklistItemStatus.fail,
                    deviationNotes: notes,
                    deviationPhotoUrl: photoUrl ?? 'https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800',
                  );
                });

                Navigator.of(ctx).pop();
              },
              child: const Text('Record Failure Deviation'),
            ),
          ],
        ),
      ),
    );
  }

  void _submitAudit() {
    final unanswered = _items.where((i) => i.status == ChecklistItemStatus.unanswered).length;
    if (unanswered > 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please evaluate all items before finalizing ($unanswered remaining)'),
          backgroundColor: AppColors.riskMedium,
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    String inspId = 'CP-EMP-1003';
    String inspName = 'Hamza Ali (HSE Inspector)';
    if (authState is Authenticated) {
      inspId = authState.user.employeeId;
      inspName = authState.user.name;
    }

    final audit = ChecklistAudit(
      id: 'AUD-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      templateId: widget.template.id,
      title: widget.template.title,
      plantUnit: widget.template.plantUnit,
      shiftType: widget.shiftType.label,
      inspectorId: inspId,
      inspectorName: inspName,
      items: _items,
      completionRate: 100.0,
      isCompleted: true,
      auditDate: DateTime.now(),
    );

    context.read<ChecklistCubit>().submitAudit(audit);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checklist completed and saved to shift turnover log!'),
        backgroundColor: AppColors.riskLow,
      ),
    );

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;
    final total = _items.length;
    final answered = _items.where((i) => i.status != ChecklistItemStatus.unanswered).length;
    final passCount = _items.where((i) => i.status == ChecklistItemStatus.pass).length;
    final failCount = _items.where((i) => i.status == ChecklistItemStatus.fail).length;
    final naCount = _items.where((i) => i.status == ChecklistItemStatus.na).length;
    final progress = total > 0 ? answered / total : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.template.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                widget.shiftType.label.split('(').first,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.primaryLight),
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 960 : double.infinity),
          child: Column(
            children: [
              // Progress Banner
              Container(
                color: AppColors.cardDark,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Completion: ${(progress * 100).toInt()}% ($answered/$total)',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            _buildCountPill('Pass: $passCount', AppColors.riskLow),
                            const SizedBox(width: 8),
                            _buildCountPill('Fail: $failCount', AppColors.riskCritical),
                            const SizedBox(width: 8),
                            _buildCountPill('N/A: $naCount', Colors.grey),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.shade800,
                      color: failCount > 0 ? AppColors.riskMedium : AppColors.riskLow,
                      minHeight: 6,
                    ),
                  ],
                ),
              ),

              // Checklist Items List
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = _items[index];

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  radius: 12,
                                  backgroundColor: AppColors.primaryLight.withAlpha((0.2 * 255).round()),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primaryLight),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.category.toUpperCase(),
                                        style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark, fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        item.title,
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Pass / Fail / NA Toggle Buttons
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                _buildToggleOption(
                                  label: 'PASS',
                                  icon: Icons.check_circle_outline,
                                  color: AppColors.riskLow,
                                  isSelected: item.status == ChecklistItemStatus.pass,
                                  onTap: () => _onStatusToggle(index, ChecklistItemStatus.pass),
                                ),
                                const SizedBox(width: 8),
                                _buildToggleOption(
                                  label: 'FAIL',
                                  icon: Icons.cancel_outlined,
                                  color: AppColors.riskCritical,
                                  isSelected: item.status == ChecklistItemStatus.fail,
                                  onTap: () => _onStatusToggle(index, ChecklistItemStatus.fail),
                                ),
                                const SizedBox(width: 8),
                                _buildToggleOption(
                                  label: 'N/A',
                                  icon: Icons.remove_circle_outline,
                                  color: Colors.grey,
                                  isSelected: item.status == ChecklistItemStatus.na,
                                  onTap: () => _onStatusToggle(index, ChecklistItemStatus.na),
                                ),
                              ],
                            ),

                            // Display deviation note if failed
                            if (item.status == ChecklistItemStatus.fail && item.deviationNotes != null) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: AppColors.riskHigh.withAlpha((0.1 * 255).round()),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.riskHigh),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.warning, size: 16, color: AppColors.riskHigh),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Deviation: ${item.deviationNotes}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.riskHigh),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 16),
                                      onPressed: () => _showFailureDeviationDialog(index),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom Submission Bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.cardDark,
                  border: Border(top: BorderSide(color: AppColors.borderDark)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: progress >= 1.0 ? _submitAudit : null,
                        icon: const Icon(Icons.assignment_turned_in),
                        label: const Text('Complete & Sign Shift Audit'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.riskLow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountPill(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha((0.2 * 255).round()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildToggleOption({
    required String label,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: isSelected ? color : AppColors.borderDark),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textSecondaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

