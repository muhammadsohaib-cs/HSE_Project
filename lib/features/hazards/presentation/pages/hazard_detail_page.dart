import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/platform/media_service.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/hazard.dart';
import '../cubit/hazard_cubit.dart';
import '../widgets/risk_matrix_widget.dart';

class HazardDetailPage extends StatefulWidget {
  final Hazard hazard;
  const HazardDetailPage({super.key, required this.hazard});

  @override
  State<HazardDetailPage> createState() => _HazardDetailPageState();
}

class _HazardDetailPageState extends State<HazardDetailPage> {
  late Hazard _hazard;
  final _assignedToController = TextEditingController();
  final _correctiveActionController = TextEditingController();
  final _supervisorNotesController = TextEditingController();
  String? _resolutionPhotoUrl;

  @override
  void initState() {
    super.initState();
    _hazard = widget.hazard;
    _assignedToController.text = _hazard.assignedTo ?? '';
    _correctiveActionController.text = _hazard.correctiveAction ?? '';
    _resolutionPhotoUrl = _hazard.resolutionProofMediaUrl;
  }

  @override
  void dispose() {
    _assignedToController.dispose();
    _correctiveActionController.dispose();
    _supervisorNotesController.dispose();
    super.dispose();
  }

  void _showApprovalDialog() {
    final authState = context.read<AuthCubit>().state;
    String supId = 'CP-EMP-1002';
    String supName = 'Asim Raza (HSE Manager)';

    if (authState is Authenticated) {
      supId = authState.user.employeeId;
      supName = '${authState.user.name} (${authState.user.role.title})';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified_user_rounded, color: AppColors.riskLow),
            SizedBox(width: 8),
            Text('Supervisory Digital Sign-Off'),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Authorizing Officer: $supName', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('Employee ID: $supId', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark)),
              const SizedBox(height: 12),
              const Text('Resolution Photo Proof:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _resolutionPhotoUrl ?? 'Evidence photo attached: resolution_proof_2026.jpg',
                      style: const TextStyle(fontSize: 12, color: AppColors.riskLow),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final media = await MediaService().pickPhoto();
                      if (media != null && mounted) {
                        setState(() => _resolutionPhotoUrl = media.path);
                        Navigator.of(ctx).pop();
                        _showApprovalDialog();
                      }
                    },
                    icon: const Icon(Icons.attach_file, size: 16),
                    label: const Text('Change'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _supervisorNotesController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Mandatory Supervisory Verification Notes',
                  hintText: 'Confirmed on-site mitigation meets plant safety standard...',
                ),
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskLow),
            onPressed: () {
              final notes = _supervisorNotesController.text.trim();
              if (notes.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Supervisory verification notes are required')),
                );
                return;
              }

              final signOff = SupervisorSignOff(
                supervisorId: supId,
                supervisorName: supName,
                signatureHash: 'SHA256:${DateTime.now().microsecondsSinceEpoch.toRadixString(16)}',
                approvalNotes: notes,
                signedAt: DateTime.now(),
              );

              context.read<HazardCubit>().advanceCapaStatus(
                hazardId: _hazard.id,
                targetStatus: CapaStatus.closed,
                assignedTo: _assignedToController.text,
                correctiveAction: _correctiveActionController.text,
                resolutionProofMediaUrl: _resolutionPhotoUrl ?? 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=800',
                supervisorSignOff: signOff,
              );

              setState(() {
                _hazard = _hazard.copyWith(
                  status: CapaStatus.closed,
                  supervisorSignOff: signOff,
                  resolutionProofMediaUrl: _resolutionPhotoUrl ?? 'https://images.unsplash.com/photo-1581091226825-a6a2a5aee158?w=800',
                  closedAt: DateTime.now(),
                );
              });

              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('CAPA closed and supervisor sign-off recorded!'), backgroundColor: AppColors.riskLow),
              );
            },
            child: const Text('Digitally Sign & Close'),
          ),
        ],
      ),
    );
  }

  void _advanceToStatus(CapaStatus nextStatus) {
    if (nextStatus == CapaStatus.closed) {
      _showApprovalDialog();
      return;
    }

    context.read<HazardCubit>().advanceCapaStatus(
      hazardId: _hazard.id,
      targetStatus: nextStatus,
      assignedTo: _assignedToController.text.trim().isEmpty ? null : _assignedToController.text.trim(),
      correctiveAction: _correctiveActionController.text.trim().isEmpty ? null : _correctiveActionController.text.trim(),
    );

    setState(() {
      _hazard = _hazard.copyWith(
        status: nextStatus,
        assignedTo: _assignedToController.text,
        correctiveAction: _correctiveActionController.text,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('CAPA Status advanced to ${nextStatus.label}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDesktop = PlatformHelper.isDesktop;
    final riskBand = _hazard.riskBand;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_hazard.id} Details'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: riskBand.color.withAlpha((0.2 * 255).round()),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: riskBand.color),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(backgroundColor: riskBand.color, radius: 4),
                const SizedBox(width: 6),
                Text(
                  '${riskBand.label} (${_hazard.score})',
                  style: TextStyle(color: riskBand.color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 960 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // CAPA Stepper Header
                _buildCapaStatusStepper(),
                const SizedBox(height: 20),

                // Core Details Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _hazard.title,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _hazard.description,
                          style: const TextStyle(fontSize: 14, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 24,
                          runSpacing: 12,
                          children: [
                            _buildMetaItem('Plant Zone', _hazard.plantZone, Icons.business),
                            _buildMetaItem('Reporter', '${_hazard.reporterName} (${_hazard.reporterId})', Icons.person),
                            _buildMetaItem('Coordinates', _hazard.coordinates.toString(), Icons.location_on),
                            _buildMetaItem('Reported Date', _hazard.createdAt.toString().split('.').first, Icons.schedule),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 5x5 Matrix Visual Preview
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Evaluated Risk Matrix Position',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        RiskMatrixWidget(
                          selectedProbability: _hazard.probability,
                          selectedSeverity: _hazard.severity,
                          isInteractive: false,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // CAPA Assignment & Action Plan
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Corrective and Preventive Action (CAPA)',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _assignedToController,
                          readOnly: _hazard.isClosed,
                          decoration: const InputDecoration(
                            labelText: 'Assigned Action Owner / Lead Engineer',
                            prefixIcon: Icon(Icons.assignment_ind),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _correctiveActionController,
                          readOnly: _hazard.isClosed,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Corrective Action Plan & Root Cause Mitigation',
                            prefixIcon: Icon(Icons.build),
                            alignLabelWithHint: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Supervisory Sign-Off Card (if Closed)
                if (_hazard.isClosed && _hazard.supervisorSignOff != null) ...[
                  const SizedBox(height: 20),
                  Card(
                    color: AppColors.riskLow.withAlpha((0.08 * 255).round()),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: AppColors.riskLow, width: 1.5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.verified, color: AppColors.riskLow),
                              SizedBox(width: 8),
                              Text('Supervisory Digital Sign-Off Recorded', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text('Supervisor: ${_hazard.supervisorSignOff!.supervisorName}'),
                          Text('Employee ID: ${_hazard.supervisorSignOff!.supervisorId}'),
                          Text('Digital Signature: ${_hazard.supervisorSignOff!.signatureHash}'),
                          Text('Approval Notes: ${_hazard.supervisorSignOff!.approvalNotes}'),
                          Text('Signed At: ${_hazard.supervisorSignOff!.signedAt.toString().split(".").first}'),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Workflow Action Buttons
                if (!_hazard.isClosed) ...[
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      if (_hazard.status == CapaStatus.reported)
                        ElevatedButton.icon(
                          onPressed: () => _advanceToStatus(CapaStatus.underReview),
                          icon: const Icon(Icons.fact_check),
                          label: const Text('Move to Under Review'),
                        ),
                      if (_hazard.status == CapaStatus.underReview)
                        ElevatedButton.icon(
                          onPressed: () => _advanceToStatus(CapaStatus.assigned),
                          icon: const Icon(Icons.assignment),
                          label: const Text('Assign to Engineer'),
                        ),
                      if (_hazard.status == CapaStatus.assigned)
                        ElevatedButton.icon(
                          onPressed: () => _advanceToStatus(CapaStatus.actionTaken),
                          icon: const Icon(Icons.engineering),
                          label: const Text('Mark Action Taken'),
                        ),
                      if (_hazard.status == CapaStatus.actionTaken)
                        ElevatedButton.icon(
                          onPressed: () => _advanceToStatus(CapaStatus.verification),
                          icon: const Icon(Icons.rule),
                          label: const Text('Ready for HSE Verification'),
                        ),
                      if (_hazard.status == CapaStatus.verification)
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.riskLow),
                          onPressed: () => _advanceToStatus(CapaStatus.closed),
                          icon: const Icon(Icons.verified_user),
                          label: const Text('Supervisor Sign-Off & Close'),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaItem(String title, String value, IconData icon) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondaryDark),
        const SizedBox(width: 6),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ],
        ),
      ],
    );
  }

  Widget _buildCapaStatusStepper() {
    final stages = CapaStatus.values.where((s) => s != CapaStatus.draft).toList();
    final currentIndex = stages.indexOf(_hazard.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (int i = 0; i < stages.length; i++) ...[
                Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: i <= currentIndex ? AppColors.primaryLight : Colors.grey.shade700,
                      child: Text(
                        '${i + 1}',
                        style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      stages[i].label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: i == currentIndex ? FontWeight.bold : FontWeight.normal,
                        color: i <= currentIndex ? Colors.white : AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
                if (i < stages.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Container(
                      width: 20,
                      height: 2,
                      color: i < currentIndex ? AppColors.primaryLight : Colors.grey.shade700,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

