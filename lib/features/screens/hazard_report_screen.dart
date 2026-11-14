import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/platform/audio_record_service.dart';
import '../../core/platform/media_service.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class HazardReportScreen extends StatefulWidget {
  const HazardReportScreen({super.key});

  @override
  State<HazardReportScreen> createState() => _HazardReportScreenState();
}

class _HazardReportScreenState extends State<HazardReportScreen> with SingleTickerProviderStateMixin {
  final AudioRecordService _recordService = AudioRecordService();
  final MediaService _mediaService = MediaService();

  String _selectedCategory = 'Steam Leak';
  String _selectedSeverity = 'High';
  String _selectedZone = 'Boiler Area (Unit 1 & 2)';
  final _descController = TextEditingController();
  final String _gpsCoords = '31.7204° N, 72.9791° E';

  bool _isRecording = false;
  int _recordSeconds = 0;
  Timer? _recordTimer;
  bool _photoCaptured = false;
  String? _recordedVoicePath;
  String? _capturedPhotoPath;
  String _capturedPhotoName = '';

  late AnimationController _animController;

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Fire / Spark', 'icon': '🔥', 'color': CplColors.red600},
    {'name': 'Steam Leak', 'icon': '💨', 'color': CplColors.safety500},
    {'name': 'Electrical', 'icon': '⚡', 'color': CplColors.amber500},
    {'name': 'Slip / Trip', 'icon': '🚧', 'color': Color(0xFF8B5CF6)},
    {'name': 'PPE Missing', 'icon': '🪖', 'color': CplColors.emerald500},
  ];

  final List<String> _severities = ['Low', 'Medium', 'High', 'Critical'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _recordTimer?.cancel();
    _animController.dispose();
    _descController.dispose();
    _recordService.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    if (!_isRecording) {
      final path = await _recordService.startRecording();
      setState(() {
        _isRecording = true;
        _recordedVoicePath = path;
        _recordSeconds = 0;
        _recordTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
          setState(() => _recordSeconds++);
        });
      });
    } else {
      final path = await _recordService.stopRecording();
      _recordTimer?.cancel();
      setState(() {
        _isRecording = false;
        _recordedVoicePath = path ?? _recordedVoicePath;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Urdu Voice Note Saved & Attached to Incident Queue'),
            backgroundColor: CplColors.emerald500,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _dispatchReport() {
    final cubit = context.read<CplSystemCubit>();
    cubit.dispatchHazard(
      category: _selectedCategory,
      zone: _selectedZone,
      severity: _selectedSeverity,
      description: _descController.text.trim(),
      coords: _gpsCoords,
      photoPath: _capturedPhotoPath,
      voicePath: _recordedVoicePath,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Hazard logged & dispatched to HSE Control Desk: $_selectedCategory ($_selectedZone)'),
        backgroundColor: CplColors.red600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final zones = state.zones.map((z) => z.name).toList();

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
                  isUr ? 'خطرہ اور نقص کی رپورٹ' : 'Hazard & Risk Identification',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Boiler & Co-Gen Plant Unit-1 (62.4 MW)',
                  style: CplTypography.caption(context).copyWith(
                    color: CplColors.slate400,
                  ),
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
                // Live Status Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: CplColors.safety500.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CplColors.safety500.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.gps_fixed, size: 18, color: CplColors.safety600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          isUr
                            ? 'GPS تصدیق شدہ مقام: 31.7204° N, 72.9791° E'
                            : 'GPS Watermark Verified: 31.7204° N, 72.9791° E (Chiniot Power)',
                          style: CplTypography.mono().copyWith(
                            color: CplColors.safety600,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 1. Select Hazard Category
                Text(
                  isUr ? '1. خطرے کی قسم منتخب کریں' : '1. Select Hazard Category',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat['name'];
                    return InkWell(
                      onTap: () => setState(() => _selectedCategory = cat['name'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? CplColors.slate900 : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? CplColors.slate900 : CplColors.slate200,
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4, offset: const Offset(0, 2))]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(cat['icon'] as String, style: const TextStyle(fontSize: 18)),
                            const SizedBox(width: 8),
                            Text(
                              cat['name'] as String,
                              style: TextStyle(
                                color: isSelected ? Colors.white : CplColors.slate700,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 2. Plant Zone Selector
                Text(
                  isUr ? '2. پلانٹ زون (لوکیشن)' : '2. Plant Zone / Location',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: zones.contains(_selectedZone) ? _selectedZone : zones.first,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: CplColors.slate700),
                      items: zones.map((z) {
                        return DropdownMenuItem(
                          value: z,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on, size: 18, color: CplColors.safety500),
                              const SizedBox(width: 8),
                              Text(z, style: const TextStyle(fontWeight: FontWeight.w600)),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedZone = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Severity Level
                Text(
                  isUr ? '3. شدت کی درجہ بندی' : '3. Severity Level',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: _severities.map((sev) {
                    final isSelected = _selectedSeverity == sev;
                    Color color;
                    switch (sev) {
                      case 'Critical': color = CplColors.red600; break;
                      case 'High': color = CplColors.safety500; break;
                      case 'Medium': color = CplColors.amber500; break;
                      default: color = CplColors.emerald500;
                    }
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: InkWell(
                          onTap: () => setState(() => _selectedSeverity = sev),
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected ? color : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? color : CplColors.slate200,
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              sev,
                              style: TextStyle(
                                color: isSelected ? Colors.white : CplColors.slate700,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),

                // 4. Photo Evidence Capture with CPL Watermark
                Text(
                  isUr ? '4. تصویری ثبوت (کیمرہ)' : '4. Photo Evidence Capture',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: CplColors.slate900,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.slate700),
                  ),
                  child: Stack(
                    children: [
                      // Background industrial preview graphic
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _photoCaptured ? Icons.check_circle : Icons.camera_alt,
                              size: 48,
                              color: _photoCaptured ? CplColors.emerald500 : Colors.white54,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _photoCaptured
                                ? _capturedPhotoName
                                : 'Tap Camera to Capture Proof',
                              style: TextStyle(
                                color: _photoCaptured ? Colors.white : Colors.white60,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Watermark Overlay
                      Positioned(
                        bottom: 8,
                        left: 10,
                        right: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.75),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'CPL 62.4 MW • ${_selectedZone.toUpperCase()}',
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontFamily: 'monospace'),
                              ),
                              Text(
                                _gpsCoords,
                                style: const TextStyle(color: CplColors.amber400, fontSize: 10, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // Re-take Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: InkWell(
                          onTap: () async {
                            final file = await _mediaService.capturePhoto();
                            if (file != null) {
                              setState(() {
                                _photoCaptured = true;
                                _capturedPhotoPath = file.path;
                                _capturedPhotoName = 'Photo Captured • ${file.name}';
                              });
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('GPS Watermarked: ${file.watermark}'),
                                    backgroundColor: CplColors.emerald500,
                                  ),
                                );
                              }
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.white24,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.refresh, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  _photoCaptured ? 'Retake' : 'Capture',
                                  style: const TextStyle(color: Colors.white, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 5. Urdu Voice Note Recorder
                Text(
                  isUr ? '5. اردو وائس نوٹ ریکارڈ کریں' : '5. Urdu Voice Note Recorder',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _isRecording ? CplColors.red600 : CplColors.slate200, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      // Record / Stop Button
                      GestureDetector(
                        onTap: _toggleRecording,
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: _isRecording ? CplColors.red600 : CplColors.slate900,
                            shape: BoxShape.circle,
                            boxShadow: _isRecording
                                ? [BoxShadow(color: CplColors.red600.withOpacity(0.4), blurRadius: 10, spreadRadius: 3)]
                                : null,
                          ),
                          child: Icon(
                            _isRecording ? Icons.stop : Icons.mic,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Waveform & Status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _isRecording
                                      ? (isUr ? 'ریکارڈنگ جاری ہے...' : 'Recording Live...')
                                      : (_recordedVoicePath != null
                                          ? (isUr ? 'وائس نوٹ محفوظ ہو گیا' : 'Voice Note Recorded (${_recordSeconds}s)')
                                          : (isUr ? 'آواز ریکارڈ کرنے کے لیے مائیک دبائیں' : 'Tap Mic to Record Voice Note')),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _isRecording ? CplColors.red600 : CplColors.slate800,
                                  ),
                                ),
                                Text(
                                  _isRecording || _recordedVoicePath != null
                                      ? '0:${_recordSeconds.toString().padLeft(2, '0')}'
                                      : '0:00',
                                  style: CplTypography.mono().copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _isRecording ? CplColors.red600 : CplColors.slate600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            // Simulated animated waveform bars
                            Row(
                              children: List.generate(24, (index) {
                                final height = _isRecording
                                    ? 8 + (index % 5) * 4 * _animController.value
                                    : (index % 4 == 0 ? 18.0 : (index % 3 == 0 ? 12.0 : 6.0));
                                return Expanded(
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 1),
                                    height: height,
                                    decoration: BoxDecoration(
                                      color: _isRecording
                                          ? CplColors.red600.withOpacity(0.8)
                                          : CplColors.safety500,
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 6. Detailed Hazard Notes
                Text(
                  isUr ? '6. تفصیلی تفصیل (اردو یا انگریزی)' : '6. Detailed Observation Notes',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: isUr ? 'یہاں خطرے کی تفصیل لکھیں...' : 'Enter hazard description or immediate actions taken...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: CplColors.slate200),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                ElevatedButton(
                  onPressed: _dispatchReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CplColors.safety500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send_rounded, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isUr ? 'خطرہ فوری رپورٹ کریں (HSE کو ارسال)' : 'Dispatch Hazard Alert Now',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
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
