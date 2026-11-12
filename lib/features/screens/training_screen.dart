import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';
import '../cpl_system/models/cpl_models.dart';

class TrainingScreen extends StatelessWidget {
  const TrainingScreen({super.key});

  void _showQuizModal(BuildContext context, TrainingModule training, bool isUr) {
    int selectedOption = -1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalCtx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isUr ? 'سیفٹی کوئز • تصدیقی امتحان' : 'Safety Competency Assessment',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(modalCtx),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    training.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: CplColors.slate900),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isUr
                        ? 'سوال: 132kV گرڈ سوئچ یارڈ میں کام کرتے وقت ارتھ سوئچ لگانے سے پہلے کیا تصدیق ضروری ہے؟'
                        : 'Question: What mandatory verification is required before closing the earth switch on a 132kV busbar?',
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  // Options
                  ...[
                    'A. Only visual check through binoculars.',
                    'B. Zero-voltage test with an approved high-voltage detector stick.',
                    'C. Switch off the station lights.',
                    'D. Inform the tea boy.',
                  ].asMap().entries.map((entry) {
                    final idx = entry.key;
                    final optText = entry.value;
                    final isChosen = selectedOption == idx;
                    return InkWell(
                      onTap: () {
                        setModalState(() {
                          selectedOption = idx;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isChosen ? CplColors.safety500.withOpacity(0.12) : CplColors.slate50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isChosen ? CplColors.safety500 : CplColors.slate200,
                            width: isChosen ? 1.5 : 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isChosen ? Icons.radio_button_checked : Icons.radio_button_off,
                              color: isChosen ? CplColors.safety500 : CplColors.slate600,
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                optText,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: isChosen ? FontWeight.bold : FontWeight.normal,
                                  color: isChosen ? CplColors.safety600 : CplColors.slate800,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: selectedOption == 1
                        ? () {
                            context.read<CplSystemCubit>().completeTrainingQuiz(training.id);
                            Navigator.pop(modalCtx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isUr
                                      ? 'مبارک ہو! امتحان پاس ہو گیا اور سرٹیفکیٹ کی تجدید ہو گئی (100% درست)'
                                      : 'Assessment Passed! Certificate renewed till Nov 2027 (Score: 100%)',
                                ),
                                backgroundColor: CplColors.emerald500,
                              ),
                            );
                          }
                        : selectedOption == -1
                            ? null
                            : () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Incorrect answer. Option B is mandatory according to CPL Electrical SOP.'),
                                    backgroundColor: CplColors.red600,
                                  ),
                                );
                              },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: CplColors.emerald500,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isUr ? 'جواب جمع کروائیں اور تصدیق حاصل کریں' : 'Submit Answer & Renew Certificate',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final user = state.currentUser;

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
                  isUr ? 'سیفٹی ٹریننگ اور کیو آر پاس' : 'Training & Toolbox Attendance',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'ISO 45001 Certification Competency',
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
                // Daily Toolbox Talk Attendance Card with QR
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isUr ? 'روزانہ ٹول باکس ٹاک (TBT)' : 'Daily Toolbox Talk (TBT)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Shift A • Unit-1 Boiler Deck • 06:00 AM',
                                style: TextStyle(fontSize: 11.5, color: CplColors.slate600),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: state.qrCheckedIn
                                  ? CplColors.emerald500.withOpacity(0.12)
                                  : CplColors.safety500.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.qrCheckedIn ? (isUr ? 'حاضری درج ✓' : 'PRESENT ✓') : 'PENDING',
                              style: TextStyle(
                                color: state.qrCheckedIn ? CplColors.emerald500 : CplColors.safety500,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 20),
                      Row(
                        children: [
                          // Vector QR code container
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: CplColors.slate200),
                            ),
                            child: QrImageView(
                              data: 'CPL-TBT|${user.empId}|${DateTime.now().toIso8601String()}',
                              version: QrVersions.auto,
                              size: 96,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.empId,
                                  style: CplTypography.mono().copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: CplColors.safety500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                ),
                                Text(
                                  user.role,
                                  style: TextStyle(fontSize: 11.5, color: CplColors.slate600),
                                ),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    context.read<CplSystemCubit>().setQrAttendanceCheckedIn();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('TBT Attendance Verified via QR Code!'),
                                        backgroundColor: CplColors.emerald500,
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: state.qrCheckedIn ? CplColors.slate900 : CplColors.safety500,
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: Text(
                                    state.qrCheckedIn
                                        ? (isUr ? 'حاضری درج ہے' : 'Checked In (06:14 AM)')
                                        : (isUr ? 'کیو آر اسکین کریں' : '1-Tap QR Check In'),
                                    style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Training Modules List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUr ? 'حفاظتی کورسز اور سرٹیفیکیشن' : 'Safety Courses & Certification',
                      style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '3 Courses',
                      style: CplTypography.caption(context).copyWith(color: CplColors.slate600),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Module Cards
                ...state.trainings.map((trn) {
                  final isDueSoon = trn.status == 'Due Soon';
                  final isCompleted = trn.status == 'Completed';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDueSoon ? CplColors.safety500.withOpacity(0.5) : CplColors.slate200,
                        width: isDueSoon ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: CplColors.slate100,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                trn.id,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, fontFamily: 'monospace'),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? CplColors.emerald500.withOpacity(0.12)
                                    : CplColors.amber500.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                trn.status,
                                style: TextStyle(
                                  color: isCompleted ? CplColors.emerald500 : CplColors.amber500,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trn.title,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: CplColors.slate900),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          trn.ur,
                          style: CplTypography.urduText(context).copyWith(
                            fontSize: 12.5,
                            color: CplColors.slate600,
                            height: 1.8,
                          ),
                          textAlign: isUr ? TextAlign.right : TextAlign.left,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.ondemand_video, size: 14, color: CplColors.slate600),
                            const SizedBox(width: 4),
                            Text(trn.duration, style: const TextStyle(fontSize: 11.5, color: CplColors.slate600)),
                            const Spacer(),
                            const Icon(Icons.verified_user, size: 14, color: CplColors.slate600),
                            const SizedBox(width: 4),
                            Text(trn.expiry, style: const TextStyle(fontSize: 11.5, color: CplColors.slate600)),
                          ],
                        ),
                        const Divider(height: 18),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Score: ${trn.score}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _showQuizModal(context, trn, isUr);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDueSoon ? CplColors.safety500 : CplColors.slate900,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              child: Text(
                                isDueSoon
                                    ? (isUr ? 'کوئز حل کریں' : 'Take Safety Quiz')
                                    : (isUr ? 'دوبارہ دیکھیں' : 'Review Module'),
                                style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
