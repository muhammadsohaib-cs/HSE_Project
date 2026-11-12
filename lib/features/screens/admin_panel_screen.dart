import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _checklistEnController = TextEditingController();
  final _checklistUrController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _checklistEnController.dispose();
    _checklistUrController.dispose();
    super.dispose();
  }

  void _handleAddChecklist() {
    final en = _checklistEnController.text.trim();
    final ur = _checklistUrController.text.trim();
    if (en.isEmpty) return;

    context.read<CplSystemCubit>().addAdminChecklistItem(
      en,
      ur.isEmpty ? en : ur,
    );
    _checklistEnController.clear();
    _checklistUrController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('New inspection rule pushed to all CPL field tablets & smartphones.'),
        backgroundColor: CplColors.emerald500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;

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
                  isUr ? 'ایڈمن اور مینیجر کنٹرول پینل' : 'Manager & Admin Control Panel',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'CPL Governance • Staff ID & SOP Dispatcher',
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: CplColors.safety500,
              indicatorWeight: 3,
              labelColor: CplColors.safety500,
              unselectedLabelColor: CplColors.slate400,
              tabs: [
                Tab(
                  icon: const Icon(Icons.badge, size: 18),
                  text: isUr ? 'اسٹاف آئی ڈیز' : 'Staff IDs',
                ),
                Tab(
                  icon: const Icon(Icons.checklist, size: 18),
                  text: isUr ? 'چیک لسٹ بلڈر' : 'Checklists',
                ),
                Tab(
                  icon: const Icon(Icons.mail, size: 18),
                  text: isUr ? 'ای میل قواعد' : 'Email Rules',
                ),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Staff IDs Approval Queue
              _buildStaffApprovalsTab(context, state, isUr),
              // Tab 2: Checklists Builder
              _buildChecklistsTab(context, state, isUr),
              // Tab 3: Email Rules & Escalation
              _buildEmailRulesTab(context, state, isUr),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStaffApprovalsTab(BuildContext context, CplSystemState state, bool isUr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isUr ? 'ملازمین کی رجسٹریشن کی توثیق' : 'Employee ID Verification Queue',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: CplColors.safety500.withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                '${state.pendingUsers.where((u) => u.status == 'Pending').length} Pending Approval',
                style: const TextStyle(color: CplColors.safety500, fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.pendingUsers.map((user) {
          final isPending = user.status == 'Pending';
          final isApproved = user.status == 'Approved';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPending ? CplColors.safety500.withOpacity(0.4) : CplColors.slate200,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      user.empId,
                      style: CplTypography.mono().copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: CplColors.safety500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? CplColors.emerald500.withOpacity(0.12)
                            : (isPending ? CplColors.amber500.withOpacity(0.12) : CplColors.red600.withOpacity(0.12)),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        user.status,
                        style: TextStyle(
                          color: isApproved
                              ? CplColors.emerald500
                              : (isPending ? CplColors.amber500 : CplColors.red600),
                          fontWeight: FontWeight.bold,
                          fontSize: 10.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  user.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  '${user.role} • ${user.shift} • CNIC: ${user.cnic}',
                  style: TextStyle(fontSize: 12, color: CplColors.slate600),
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (isPending) ...[
                      OutlinedButton(
                        onPressed: () {
                          context.read<CplSystemCubit>().updateUserApproval(user.empId, 'Blocked');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Access Blocked for ${user.empId}'),
                              backgroundColor: CplColors.red600,
                            ),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CplColors.red600,
                          side: const BorderSide(color: CplColors.red600),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(isUr ? 'مسترد کریں' : 'Block'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          context.read<CplSystemCubit>().updateUserApproval(user.empId, 'Approved');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Employee ID ${user.empId} Approved! Login credentials active.'),
                              backgroundColor: CplColors.emerald500,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: CplColors.emerald500,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: Text(isUr ? 'منظور کریں ✓' : 'Approve ID ✓'),
                      ),
                    ] else ...[
                      Text(
                        'Status Updated: ${user.status}',
                        style: TextStyle(fontSize: 11.5, color: CplColors.slate600, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildChecklistsTab(BuildContext context, CplSystemState state, bool isUr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Add new Checklist Item Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: CplColors.slate200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isUr ? 'نئے حفاظتی چیک کا اضافہ کریں' : 'Deploy New Inspection Checklist Item',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                'Dynamically synchronizes across all mobile operator devices instantly.',
                style: TextStyle(fontSize: 11.5, color: CplColors.slate600),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _checklistEnController,
                decoration: const InputDecoration(
                  labelText: 'English Audit Requirement',
                  hintText: 'e.g. Inspect emergency battery bank float voltage',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _checklistUrController,
                decoration: const InputDecoration(
                  labelText: 'Urdu Translation (اردو ترجمہ)',
                  hintText: 'مثال: ایمرجنسی بیٹری بینک کا وولٹیج چیک کریں',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _handleAddChecklist,
                icon: const Icon(Icons.add_task),
                label: Text(
                  isUr ? 'تمام ڈیوائسز پر پش کریں' : 'Push to All Field Devices',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: CplColors.safety500,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Currently Deployed Checklists
        Text(
          isUr ? 'حالیہ فعال چیک لسٹ ٹیمپلیٹ (${state.checklistItems.length})' : 'Active Deployed Checkpoints (${state.checklistItems.length})',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        ...state.checklistItems.map((item) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: CplColors.slate200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.en,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
                const SizedBox(height: 2),
                Text(
                  item.ur,
                  style: CplTypography.urduText(context).copyWith(fontSize: 12, color: CplColors.slate600),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildEmailRulesTab(BuildContext context, CplSystemState state, bool isUr) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Escalation Rules Card
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
                    isUr ? 'ایمرجنسی نوٹیفکیشن ریسیپیئنٹس' : 'Active Escalation Email Recipients',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const Icon(Icons.notifications_active, color: CplColors.safety500, size: 20),
                ],
              ),
              const SizedBox(height: 10),
              ...state.emailRecipients.map((rec) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, size: 16, color: CplColors.emerald500),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          rec,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 18),

        // Automated Triggers List
        Text(
          isUr ? 'خودکار الرٹ کے قوانین' : 'Configured Automation Triggers',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        const SizedBox(height: 10),
        _buildTriggerCard(
          title: 'Critical Severity Hazard Trigger',
          desc: 'Instant SMS & high-priority transactional email sent to HSE Head and DCS Desk.',
          isActive: true,
        ),
        const SizedBox(height: 8),
        _buildTriggerCard(
          title: 'Daily 06:00 AM Shift Summary',
          desc: 'Consolidated PDF report of overnight checklists and muster count dispatched to VP Operations.',
          isActive: true,
        ),
        const SizedBox(height: 8),
        _buildTriggerCard(
          title: 'Rescue 1122 Automated Standby',
          desc: 'Emergency webhook dispatch triggered whenever plant siren is sounded.',
          isActive: true,
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildTriggerCard({required String title, required String desc, required bool isActive}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: CplColors.slate200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isActive ? Icons.toggle_on : Icons.toggle_off,
            color: isActive ? CplColors.emerald500 : CplColors.slate400,
            size: 28,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 2),
                Text(desc, style: TextStyle(fontSize: 11, color: CplColors.slate600)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
