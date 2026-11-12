import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class ChecklistScreen extends StatelessWidget {
  const ChecklistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final items = state.checklistItems;
        final passCount = items.where((i) => i.status == 'pass').length;
        final failCount = items.where((i) => i.status == 'fail').length;
        final totalCount = items.length;
        final progress = totalCount > 0 ? (passCount / totalCount) : 0.0;

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
                  isUr ? 'روزانہ حفاظتی چیک لسٹ' : 'Daily Safety Checklist',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Pre-Shift Operational Audit • Shift A',
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
                // Top Sync Bar & Zone Selector
                Row(
                  children: [
                    // Offline Ready Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: CplColors.emerald500.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: CplColors.emerald500.withOpacity(0.4)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.cloud_done, size: 14, color: CplColors.emerald500),
                          const SizedBox(width: 6),
                          Text(
                            isUr ? 'آف لائن فعال • ہم آہنگ' : 'Offline Ready • Synced',
                            style: const TextStyle(
                              color: CplColors.emerald500,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // Zone Selector Chip
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: CplColors.slate200),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: state.checklistZone,
                          items: state.zones.map((z) {
                            return DropdownMenuItem(
                              value: z.name,
                              child: Text(
                                z.name,
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              context.read<CplSystemCubit>().setChecklistZone(val);
                            }
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Shift Readiness Progress Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isUr ? 'شفٹ تیاری کی پیش رفت' : 'Shift Readiness Score',
                            style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${(progress * 100).toInt()}% Compliant',
                            style: TextStyle(
                              color: failCount > 0 ? CplColors.red600 : CplColors.emerald500,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: CplColors.slate100,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            failCount > 0 ? CplColors.safety500 : CplColors.emerald500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '$passCount Passed • $failCount Deficiencies',
                            style: CplTypography.caption(context).copyWith(
                              color: failCount > 0 ? CplColors.red600 : CplColors.slate600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Operator: ${state.currentUser.empId}',
                            style: CplTypography.caption(context).copyWith(color: CplColors.slate600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Checklist Items Section Title
                Text(
                  isUr ? 'آڈٹ کے نکات کی جانچ کریں' : 'Inspect Audit Items',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                // List of Audit Items
                ...items.map((item) {
                  final isPass = item.status == 'pass';
                  final isFail = item.status == 'fail';
                  final isNa = item.status == 'na';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isFail ? CplColors.red600.withOpacity(0.5) : CplColors.slate200,
                        width: isFail ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // English text
                        Text(
                          item.en,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: CplColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Urdu text
                        Text(
                          item.ur,
                          style: CplTypography.urduText(context).copyWith(
                            fontSize: 13,
                            color: CplColors.slate600,
                            height: 1.8,
                          ),
                          textAlign: isUr ? TextAlign.right : TextAlign.left,
                        ),
                        if (isFail) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: CplColors.red600.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: CplColors.red600.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 16, color: CplColors.red600),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isUr
                                        ? 'توجہ: خرابی پر فوری CAPA تشکیل پا گیا ہے اور متعلقہ انجینئر کو اطلاع کر دی گئی ہے۔'
                                        : 'Alert: Defect flagged. Auto-CAPA created and notified to DCS shift lead.',
                                    style: const TextStyle(fontSize: 11, color: CplColors.red600, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 12),
                        // Pass / Fail / NA Button Bar
                        Row(
                          children: [
                            // PASS BUTTON
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<CplSystemCubit>().setChecklistItemStatus(item.id, 'pass');
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isPass ? CplColors.emerald500 : CplColors.slate50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isPass ? CplColors.emerald500 : CplColors.slate200,
                                    ),
                                  ),
                                  child: Text(
                                    isUr ? 'ٹھیک ہے ✓' : 'Pass ✓',
                                    style: TextStyle(
                                      color: isPass ? Colors.white : CplColors.slate700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // FAIL BUTTON
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<CplSystemCubit>().setChecklistItemStatus(item.id, 'fail');
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isFail ? CplColors.red600 : CplColors.slate50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isFail ? CplColors.red600 : CplColors.slate200,
                                    ),
                                  ),
                                  child: Text(
                                    isUr ? 'خرابی ✕' : 'Fail ✕',
                                    style: TextStyle(
                                      color: isFail ? Colors.white : CplColors.slate700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // N/A BUTTON
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<CplSystemCubit>().setChecklistItemStatus(item.id, 'na');
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isNa ? CplColors.slate700 : CplColors.slate50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isNa ? CplColors.slate700 : CplColors.slate200,
                                    ),
                                  ),
                                  child: Text(
                                    'N / A',
                                    style: TextStyle(
                                      color: isNa ? Colors.white : CplColors.slate700,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 16),

                // Digital Verification & Thumb Signature Pad
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: state.checklistSigned ? CplColors.emerald500 : CplColors.slate200,
                      width: state.checklistSigned ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            isUr ? 'آپریٹر ڈیجیٹل تصدیق اور انگوٹھا' : 'Operator Digital Signature Pad',
                            style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                          ),
                          Icon(
                            state.checklistSigned ? Icons.verified : Icons.fingerprint,
                            color: state.checklistSigned ? CplColors.emerald500 : CplColors.safety500,
                            size: 24,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isUr
                            ? 'میں تصدیق کرتا ہوں کہ درج بالا بوائلر اور سیفٹی چیکس میری نگرانی میں مکمل ہوئے ہیں۔'
                            : 'I hereby certify that all pre-shift boiler house safety checks have been physically audited.',
                        style: TextStyle(fontSize: 12, color: CplColors.slate600, height: isUr ? 1.8 : 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${state.currentUser.name} (${state.currentUser.empId})',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              Text(
                                'Shift A • Chiniot Co-Gen 62.4 MW',
                                style: TextStyle(fontSize: 11, color: CplColors.slate600),
                              ),
                            ],
                          ),
                          ElevatedButton(
                            onPressed: () {
                              context.read<CplSystemCubit>().toggleChecklistSignature();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: state.checklistSigned ? CplColors.emerald500 : CplColors.slate900,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: Text(
                              state.checklistSigned
                                  ? (isUr ? 'دستخط شدہ ✓' : 'Signed ✓')
                                  : (isUr ? 'ڈیجیٹل دستخط کریں' : 'Tap to Sign'),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Submit Shift Audit Button
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isUr
                              ? 'شفٹ آڈٹ رپورٹ کامیابی کے ساتھ سرور پر جمع ہو گئی ہے۔'
                              : 'Shift Safety Audit Submitted & Archived to CPL Cloud.',
                        ),
                        backgroundColor: CplColors.emerald500,
                      ),
                    );
                    context.read<CplSystemCubit>().setScreenIndex(1); // Return to Dashboard
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CplColors.safety500,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 3,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isUr ? 'مکمل آڈٹ رپورٹ جمع کروائیں' : 'Submit Shift Safety Audit',
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
