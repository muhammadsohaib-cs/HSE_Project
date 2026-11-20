import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';
import '../cpl_system/models/cpl_models.dart';

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
        final naCount = items.where((i) => i.status == 'na').length;
        final totalCount = items.length;
        final progress = totalCount > 0 ? (passCount / totalCount) : 0.0;
        final currentTpl = state.activeChecklistTemplate;
        final filteredTemplates = state.filteredChecklistTemplates;
        final uniqueTemplates = <String, ChecklistTemplate>{
          for (final t in filteredTemplates) t.id: t,
        }.values.toList();
        final selectedTemplateId = uniqueTemplates.any((t) => t.id == state.activeChecklistTemplateId)
            ? state.activeChecklistTemplateId
            : (uniqueTemplates.isNotEmpty ? uniqueTemplates.first.id : null);
        final uniqueZones = <String, PlantZone>{
          for (final z in state.zones) z.name: z,
        }.values.toList();
        final selectedZone = uniqueZones.any((z) => z.name == state.checklistZone)
            ? state.checklistZone
            : (uniqueZones.isNotEmpty ? uniqueZones.first.name : null);
        final categories = state.checklistCategories;

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
                  isUr ? 'سیفٹی معائنہ چیک لسٹس' : 'HSE Inspection Checklists',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  isUr
                      ? 'چنیوٹ پاور لمیٹڈ • 12 فعال آپریشنل آڈٹس'
                      : 'Chiniot Power Limited • 12 Active Operational Checklists',
                  style: CplTypography.caption(context).copyWith(color: CplColors.slate400),
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.language, color: Colors.white),
                tooltip: 'Toggle English / اردو',
                onPressed: () => context.read<CplSystemCubit>().toggleLanguage(),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
                    const SizedBox(width: 10),
                    // Zone Selector Chip
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: CplColors.slate200),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedZone,
                            items: uniqueZones.map((z) {
                              return DropdownMenuItem(
                                value: z.name,
                                child: Text(
                                  z.name,
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
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
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Category Filter Pills
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, idx) {
                      final cat = categories[idx];
                      final isSelected = state.checklistCategoryFilter == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            context.read<CplSystemCubit>().setChecklistCategoryFilter(cat);
                          }
                        },
                        selectedColor: CplColors.slate900,
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : CplColors.slate700,
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        ),
                        side: BorderSide(
                          color: isSelected ? CplColors.slate900 : CplColors.slate300,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 14),

                // Active Template Header Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: CplColors.slate200),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CplColors.safety500.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: CplColors.safety500.withOpacity(0.3)),
                            ),
                            child: Text(
                              'DOC# ${currentTpl?.docNo ?? state.activeChecklistTemplateId}',
                              style: const TextStyle(
                                color: CplColors.safety600,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CplColors.emerald500.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              currentTpl?.frequency ?? 'Daily',
                              style: const TextStyle(
                                color: CplColors.emerald500,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Text(
                            isUr
                                ? 'ٹیمپلیٹس: ${uniqueTemplates.length}/${state.checklistTemplates.length}'
                                : '${uniqueTemplates.length}/${state.checklistTemplates.length} CPL SOPs',
                            style: const TextStyle(color: CplColors.slate400, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Dropdown to switch between all templates
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                        decoration: BoxDecoration(
                          color: CplColors.slate50,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: CplColors.slate300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: selectedTemplateId,
                            items: uniqueTemplates.map((t) {
                              return DropdownMenuItem<String>(
                                value: t.id,
                                child: Text(
                                  '${t.docNo}: ${isUr && t.titleUr.isNotEmpty ? t.titleUr : t.title}',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                context.read<CplSystemCubit>().selectChecklistTemplate(val);
                              }
                            },
                          ),
                        ),
                      ),
                      if (currentTpl != null && currentTpl.description.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          currentTpl.description,
                          style: const TextStyle(fontSize: 12, color: CplColors.slate600, height: 1.4),
                        ),
                      ],
                    ],
                  ),
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
                            isUr ? 'آڈٹ مکمل ہونے کی شرح' : 'Checklist Audit Score',
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
                            '$passCount Pass • $failCount Fail • $naCount N/A',
                            style: CplTypography.caption(context).copyWith(
                              color: failCount > 0 ? CplColors.red600 : CplColors.slate600,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Inspector: ${state.currentUser.empId}',
                            style: CplTypography.caption(context).copyWith(color: CplColors.slate600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Checklist Items Section Title
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isUr ? 'آڈٹ کے نکات کی جانچ کریں' : 'Inspect Audit Checkpoints',
                      style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${items.length} items',
                      style: const TextStyle(fontSize: 12, color: CplColors.slate400, fontWeight: FontWeight.bold),
                    ),
                  ],
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
                        // Checkpoint Header with ID & Category
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: CplColors.slate100,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '#${item.id}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: CplColors.slate700),
                              ),
                            ),
                            if (item.category.isNotEmpty) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  item.category,
                                  style: const TextStyle(fontSize: 11, color: CplColors.slate400),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 6),

                        // English description
                        Text(
                          item.en,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: CplColors.slate900,
                          ),
                        ),
                        const SizedBox(height: 4),

                        // Urdu description
                        Text(
                          item.ur,
                          style: CplTypography.urduText(context).copyWith(
                            fontSize: 13,
                            color: CplColors.slate600,
                            height: 1.8,
                          ),
                          textAlign: isUr ? TextAlign.right : TextAlign.left,
                        ),

                        // Standard / Acceptance Criteria
                        if (item.standard.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: CplColors.slate50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: CplColors.slate200),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.rule, size: 14, color: CplColors.slate500),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Standard: ${item.standard}',
                                    style: const TextStyle(fontSize: 11, color: CplColors.slate600),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

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

                        // Glove-Friendly 48dp Pass / Fail / NA buttons
                        Row(
                          children: [
                            // PASS Button
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<CplSystemCubit>().setChecklistItemStatus(item.id, 'pass');
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isPass ? CplColors.emerald500 : CplColors.slate100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isPass ? CplColors.emerald500 : CplColors.slate300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        size: 18,
                                        color: isPass ? Colors.white : CplColors.slate500,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isUr ? 'پاس' : 'PASS',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isPass ? Colors.white : CplColors.slate700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // FAIL Button
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<CplSystemCubit>().setChecklistItemStatus(item.id, 'fail');
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isFail ? CplColors.red600 : CplColors.slate100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isFail ? CplColors.red600 : CplColors.slate300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.cancel,
                                        size: 18,
                                        color: isFail ? Colors.white : CplColors.slate500,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isUr ? 'فیل' : 'FAIL',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isFail ? Colors.white : CplColors.slate700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),

                            // NA Button
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  context.read<CplSystemCubit>().setChecklistItemStatus(item.id, 'na');
                                },
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isNa ? CplColors.slate700 : CplColors.slate100,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isNa ? CplColors.slate700 : CplColors.slate300,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.do_not_disturb_on_outlined,
                                        size: 18,
                                        color: isNa ? Colors.white : CplColors.slate500,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'N/A',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                          color: isNa ? Colors.white : CplColors.slate700,
                                        ),
                                      ),
                                    ],
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

                // Digital Sign-Off & Verification Box
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
                        children: [
                          Icon(
                            Icons.draw_outlined,
                            size: 20,
                            color: state.checklistSigned ? CplColors.emerald500 : CplColors.slate600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isUr ? 'ڈیجیٹل تصدیق اور دستخط' : 'Operator Digital Sign-off',
                            style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isUr
                            ? 'میں تصدیق کرتا ہوں کہ درج بالا معائنہ اور حفاظتی چیکس میری نگرانی میں مکمل ہوئے ہیں۔'
                            : 'I hereby certify that all safety inspection items listed in ${currentTpl?.docNo ?? "this SOP"} have been physically audited.',
                        style: TextStyle(fontSize: 12, color: CplColors.slate600, height: isUr ? 1.8 : 1.4),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${state.currentUser.name} (${state.currentUser.empId})',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${state.currentUser.shift} • Chiniot Co-Gen 62.4 MW',
                                  style: TextStyle(fontSize: 11, color: CplColors.slate600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
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
                  onPressed: () async {
                    await context.read<CplSystemCubit>().submitChecklistAudit();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isUr
                                ? 'آڈٹ رپورٹ (${currentTpl?.docNo ?? ""}) کامیابی کے ساتھ سرور پر جمع ہو گئی ہے۔'
                                : 'Checklist Audit ${currentTpl?.docNo ?? ""} Submitted & Recorded to CPL Cloud.',
                          ),
                          backgroundColor: CplColors.emerald500,
                        ),
                      );
                      context.read<CplSystemCubit>().setScreenIndex(1); // Return to Dashboard
                    }
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
                        isUr
                            ? 'مکمل آڈٹ رپورٹ جمع کروائیں (${currentTpl?.docNo ?? ""})'
                            : 'Submit Shift Safety Audit (${currentTpl?.docNo ?? "CPL"})',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
