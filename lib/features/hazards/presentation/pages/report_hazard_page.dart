import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/location_service.dart';
import '../../../../core/platform/media_service.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/hazard.dart';
import '../cubit/hazard_cubit.dart';
import '../widgets/risk_matrix_widget.dart';

class ReportHazardPage extends StatefulWidget {
  const ReportHazardPage({super.key});

  @override
  State<ReportHazardPage> createState() => _ReportHazardPageState();
}

class _ReportHazardPageState extends State<ReportHazardPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _mediaService = MediaService();

  String _selectedZone = PlantZones.boilerSection;
  int _probability = 3;
  int _severity = 3;
  PlantCoordinate? _coordinates;
  bool _fetchingLocation = false;
  final List<String> _capturedMedia = [];

  @override
  void initState() {
    super.initState();
    _fetchCoordinates();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _fetchCoordinates() async {
    setState(() => _fetchingLocation = true);
    final coords = await LocationService.getCurrentCoordinates(plantZone: _selectedZone);
    if (mounted) {
      setState(() {
        _coordinates = coords;
        _fetchingLocation = false;
      });
    }
  }

  Future<void> _handleMediaCapture() async {
    final media = await _mediaService.capturePhoto();
    if (media != null && mounted) {
      setState(() {
        _capturedMedia.add(media.path);
      });
    }
  }

  void _submitHazard() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthCubit>().state;
      String reporterId = 'CP-EMP-1004';
      String reporterName = 'Field Worker';

      if (authState is Authenticated) {
        reporterId = authState.user.employeeId;
        reporterName = authState.user.name;
      }

      final coords = _coordinates ??
          PlantCoordinate(
            latitude: LocationService.defaultLat,
            longitude: LocationService.defaultLng,
            source: 'DefaultReference',
          );

      final hazard = Hazard(
        id: 'HZ-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        reporterId: reporterId,
        reporterName: reporterName,
        plantZone: _selectedZone,
        coordinates: coords,
        probability: _probability,
        severity: _severity,
        score: _probability * _severity,
        status: CapaStatus.reported,
        mediaUrls: _capturedMedia.isNotEmpty
            ? _capturedMedia
            : ['https://images.unsplash.com/photo-1581092160607-ee22621dd758?w=800'],
        createdAt: DateTime.now(),
      );

      context.read<HazardCubit>().reportHazard(hazard);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hazard ${hazard.id} submitted successfully!'),
          backgroundColor: AppColors.riskLow,
        ),
      );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Plant Hazard / Near-Miss'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 800 : double.infinity),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Plant Zone & Auto Coordinates Bar
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Location & Plant Section',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _selectedZone,
                            decoration: const InputDecoration(
                              labelText: 'Plant Zone',
                              prefixIcon: Icon(Icons.location_city_outlined),
                            ),
                            items: PlantZones.allZones.map((z) {
                              return DropdownMenuItem(value: z, child: Text(z));
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedZone = val);
                                _fetchCoordinates();
                              }
                            },
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Icon(
                                Icons.my_location,
                                size: 16,
                                color: _coordinates != null ? AppColors.riskLow : Colors.grey,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _fetchingLocation
                                      ? 'Acquiring GPS / Zone Coordinates...'
                                      : 'GPS Tag: ${_coordinates?.toString() ?? "Pending"}',
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.refresh, size: 18),
                                onPressed: _fetchCoordinates,
                                tooltip: 'Refresh GPS',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title & Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Hazard Observation Details',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Short Hazard Summary',
                              hintText: 'e.g. Steam pipe insulation damaged & hot surface exposed',
                              prefixIcon: Icon(Icons.warning_amber_rounded),
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please specify hazard title' : null,
                          ),
                          const SizedBox(height: 14),
                          TextFormField(
                            controller: _descController,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Detailed Observation & Environmental Risk',
                              hintText: 'Detail exact location, leaking medium, potential personnel danger...',
                              alignLabelWithHint: true,
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'Please provide detailed description' : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 5x5 Risk Matrix Interactive Scoring
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                '5x5 Quantitative Risk Assessment',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              Text(
                                'P: $_probability | S: $_severity',
                                style: const TextStyle(fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RiskMatrixWidget(
                            selectedProbability: _probability,
                            selectedSeverity: _severity,
                            onCellSelected: (p, s) {
                              setState(() {
                                _probability = p;
                                _severity = s;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Media Evidence
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Photographic Evidence (Timestamp Watermarked)',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              OutlinedButton.icon(
                                onPressed: _handleMediaCapture,
                                icon: Icon(PlatformHelper.isMobile ? Icons.camera_alt : Icons.upload_file),
                                label: Text(PlatformHelper.isMobile ? 'Take Photo' : 'Upload File'),
                              ),
                            ],
                          ),
                          if (_capturedMedia.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: _capturedMedia.map((path) {
                                return Chip(
                                  avatar: const Icon(Icons.image, size: 16),
                                  label: Text(path.split(RegExp(r'[/\\]')).last),
                                  onDeleted: () {
                                    setState(() => _capturedMedia.remove(path));
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Submit Button
                  ElevatedButton.icon(
                    onPressed: _submitHazard,
                    icon: const Icon(Icons.send_rounded),
                    label: const Text('Submit Hazard to HSE Queue'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

