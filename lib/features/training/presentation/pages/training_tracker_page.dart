import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/training.dart';
import '../cubit/training_cubit.dart';
import '../cubit/training_state.dart';

class TrainingTrackerPage extends StatefulWidget {
  const TrainingTrackerPage({super.key});

  @override
  State<TrainingTrackerPage> createState() => _TrainingTrackerPageState();
}

class _TrainingTrackerPageState extends State<TrainingTrackerPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthCubit>().state;
    String empId = 'CP-EMP-1004';
    if (authState is Authenticated) {
      empId = authState.user.employeeId;
    }
    context.read<TrainingCubit>().loadTrainingData(empId);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showQrAttendanceDialog(TrainingCourse course) {
    final authState = context.read<AuthCubit>().state;
    String empId = 'CP-EMP-1004';
    String empName = 'Rashid Mehmood';
    if (authState is Authenticated) {
      empId = authState.user.employeeId;
      empName = authState.user.name;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primaryLight),
            const SizedBox(width: 8),
            Expanded(child: Text(course.title, style: const TextStyle(fontSize: 14))),
          ],
        ),
        content: SizedBox(
          width: 360,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.qr_code_2_rounded, size: 160, color: Colors.black87),
                    const SizedBox(height: 8),
                    Text(
                      'TOKEN: ${course.id}-$empId',
                      style: const TextStyle(color: Colors.black54, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Scan this badge at Training Hall entrance or muster reader to record automated attendance.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              context.read<TrainingCubit>().recordAttendance(
                    courseId: course.id,
                    employeeId: empId,
                    employeeName: empName,
                  );
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Attendance verified! New certification certificate provisioned.'),
                  backgroundColor: AppColors.riskLow,
                ),
              );
            },
            child: const Text('Simulate Scan & Verify'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Training & Competency Tracker'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryLight,
          tabs: const [
            Tab(icon: Icon(Icons.school_outlined), text: 'Course Catalog'),
            Tab(icon: Icon(Icons.verified_outlined), text: 'My Safety Licenses & Expirations'),
          ],
        ),
      ),
      body: BlocBuilder<TrainingCubit, TrainingState>(
        builder: (context, state) {
          if (state is TrainingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TrainingLoaded) {
            return TabBarView(
              controller: _tabController,
              children: [
                _buildCoursesTab(state.courses, isDesktop),
                _buildCertificatesTab(state.certifications, isDesktop),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCoursesTab(List<TrainingCourse> courses, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 1080 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LayoutBuilder(
                builder: (context, constraints) {
                  final cols = constraints.maxWidth > 700 ? 2 : 1;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      childAspectRatio: isDesktop ? 2.1 : 1.7,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: courses.length,
                    itemBuilder: (context, index) {
                      final c = courses[index];

                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryLight.withAlpha((0.2 * 255).round()),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      c.category.toUpperCase(),
                                      style: const TextStyle(fontSize: 10, color: AppColors.primaryLight, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Text(
                                    '${c.durationHours} Hours • Valid: ${c.validityDays} Days',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                c.title,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              Expanded(
                                child: Text(
                                  c.description,
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark, height: 1.3),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.picture_as_pdf, size: 18),
                                        tooltip: 'Embedded PDF Documentation',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Opening PDF manual: ${c.pdfDocUrl}')),
                                          );
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.play_circle_outline, size: 18),
                                        tooltip: 'Video Tutorial',
                                        onPressed: () {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Playing video module: ${c.videoUrl}')),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showQrAttendanceDialog(c),
                                    icon: const Icon(Icons.qr_code, size: 16),
                                    label: const Text('QR Attendance'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCertificatesTab(List<UserCertification> certs, bool isDesktop) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: isDesktop ? 960 : double.infinity),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Automated Expiry Notice Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.borderDark),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.access_time_filled, color: AppColors.riskMedium, size: 28),
                    SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Automated Certification Validity Alerts',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Mandatory plant licenses trigger automated reminders at 30, 15, and 7 days before expiry to prevent site access deauthorization.',
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: certs.length,
                itemBuilder: (context, index) {
                  final cert = certs[index];
                  final urgency = cert.urgency;

                  Color urgencyColor = AppColors.riskLow;
                  if (urgency == ExpiryUrgency.expiringIn30Days) urgencyColor = AppColors.riskMedium;
                  if (urgency == ExpiryUrgency.expiringIn15Days) urgencyColor = AppColors.riskHigh;
                  if (urgency == ExpiryUrgency.expiringIn7Days || urgency == ExpiryUrgency.expired) {
                    urgencyColor = AppColors.emergencyRed;
                  }

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
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
                                  color: urgencyColor.withAlpha((0.2 * 255).round()),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: urgencyColor),
                                ),
                                child: Text(
                                  urgency.label.toUpperCase(),
                                  style: TextStyle(color: urgencyColor, fontWeight: FontWeight.bold, fontSize: 11),
                                ),
                              ),
                              Text(
                                '${cert.daysUntilExpiry} Days Remaining',
                                style: TextStyle(fontWeight: FontWeight.bold, color: urgencyColor, fontSize: 13),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            cert.courseTitle,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Certificate #: ${cert.certificateNumber} • Score: ${cert.scorePercentage}%',
                            style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Issued: ${cert.issueDate.toString().split(" ").first}',
                                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                              ),
                              Text(
                                'Expiry Date: ${cert.expiryDate.toString().split(" ").first}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ],
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
}

