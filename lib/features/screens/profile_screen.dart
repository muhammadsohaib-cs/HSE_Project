import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../core/theme/cpl_theme.dart';
import '../../core/widgets/cpl_user_avatar.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cnicController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedShift = 'General Shift (08:00 - 17:00)';
  String _selectedZone = 'Boiler Area (Unit 1 & 2)';
  String _hydratedEmpId = '';

  bool _isSavingProfile = false;
  bool _isUploadingAvatar = false;
  bool _isUpdatingPassword = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  String? _profileFeedback;
  bool _profileFeedbackOk = true;
  String? _passwordFeedback;
  bool _passwordFeedbackOk = true;

  final List<String> _shifts = const [
    'General Shift (08:00 - 17:00)',
    'Shift A (07:00 - 19:00 / 19:00 - 07:00)',
    'Shift B (07:00 - 19:00 / 19:00 - 07:00)',
    'Shift C (07:00 - 19:00 / 19:00 - 07:00)',
    'Shift D (07:00 - 19:00 / 19:00 - 07:00)',
  ];

  final List<String> _zones = const [
    'Boiler Area (Unit 1 & 2)',
    'TG Building (Steam Turbine Hall)',
    'Central Control Room (CCR)',
    'Fuel & Bagasse Yard (BC-1 to BC-5 / JT)',
    '132kV Grid Switchyard',
    'Water Treatment Plant (WTP)',
    'Balance of Plant (BOP & Cooling Tower)',
    'ESP & Ash Handling (SCC / Silo)',
    'Bagasse Piling & Shredder (BPL / RSML)',
    'Admin, Stores & Workshops (MMD / EMD / I&C)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cnicController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _syncControllersFromState(CplSystemState state) {
    final user = state.currentUser;
    if (user.empId.isNotEmpty && _hydratedEmpId != user.empId) {
      _hydratedEmpId = user.empId;
      _nameController.text = user.name;
      _emailController.text = user.email;
      _cnicController.text = user.cnic;
      _selectedShift = _shifts.contains(user.shift) ? user.shift : _shifts.first;
      _selectedZone = _zones.contains(user.zone) ? user.zone : _zones.first;
    }
  }

  Future<void> _pickAndUploadAvatar() async {
    setState(() {
      _isUploadingAvatar = true;
      _profileFeedback = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        if (mounted) setState(() => _isUploadingAvatar = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null || bytes.isEmpty) {
        if (mounted) {
          setState(() {
            _isUploadingAvatar = false;
            _profileFeedbackOk = false;
            _profileFeedback = 'Could not read image data. Please pick a PNG or JPG image.';
          });
        }
        return;
      }

      if (!mounted) return;
      final err = await context.read<CplSystemCubit>().uploadUserAvatar(
            bytes: bytes,
            fileName: file.name,
          );
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
          _profileFeedbackOk = err == null;
          _profileFeedback = err ?? 'Profile photo updated and synced to database!';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingAvatar = false;
          _profileFeedbackOk = false;
          _profileFeedback = 'Image selection error: $e';
        });
      }
    }
  }

  Future<void> _removeAvatar() async {
    setState(() {
      _isUploadingAvatar = true;
      _profileFeedback = null;
    });
    final err = await context.read<CplSystemCubit>().updateUserProfile(
          fullName: _nameController.text.trim().isNotEmpty
              ? _nameController.text.trim()
              : context.read<CplSystemCubit>().state.currentUser.name,
          removeAvatar: true,
        );
    if (mounted) {
      setState(() {
        _isUploadingAvatar = false;
        _profileFeedbackOk = err == null;
        _profileFeedback = err ?? 'Profile photo removed.';
      });
    }
  }

  Future<void> _saveProfile() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _profileFeedbackOk = false;
        _profileFeedback = 'Full Name cannot be empty.';
      });
      return;
    }

    setState(() {
      _isSavingProfile = true;
      _profileFeedback = null;
    });

    final err = await context.read<CplSystemCubit>().updateUserProfile(
          fullName: name,
          email: _emailController.text.trim(),
          cnic: _cnicController.text.trim(),
          shift: _selectedShift,
          assignedZone: _selectedZone,
        );

    if (mounted) {
      setState(() {
        _isSavingProfile = false;
        _profileFeedbackOk = err == null;
        _profileFeedback = err ?? 'Profile changes saved! Your name and details are updated on the dashboard.';
      });
    }
  }

  Future<void> _changePassword() async {
    final current = _currentPasswordController.text.trim();
    final next = _newPasswordController.text.trim();
    final confirm = _confirmPasswordController.text.trim();

    if (current.isEmpty || next.isEmpty || confirm.isEmpty) {
      setState(() {
        _passwordFeedbackOk = false;
        _passwordFeedback = 'Please complete all three password fields.';
      });
      return;
    }
    if (next.length < 4) {
      setState(() {
        _passwordFeedbackOk = false;
        _passwordFeedback = 'New password must be at least 4 characters.';
      });
      return;
    }
    if (next != confirm) {
      setState(() {
        _passwordFeedbackOk = false;
        _passwordFeedback = 'New password and confirmation do not match.';
      });
      return;
    }

    setState(() {
      _isUpdatingPassword = true;
      _passwordFeedback = null;
    });

    final err = await context.read<CplSystemCubit>().changeUserPassword(
          currentPassword: current,
          newPassword: next,
        );

    if (mounted) {
      setState(() {
        _isUpdatingPassword = false;
        _passwordFeedbackOk = err == null;
        _passwordFeedback = err ?? 'Password updated securely! Use your new password next time you sign in.';
        if (err == null) {
          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        _syncControllersFromState(state);
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
                  isUr ? 'پروفائل اور پاس ورڈ سیٹنگز' : 'Profile & Account Security',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${user.empId} • ${user.role}',
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
            padding: const EdgeInsets.all(20),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 920),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Profile Photo & Identity Hero Card
                    Container(
                      padding: const EdgeInsets.all(22),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0B1628), Color(0xFF132544)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Wrap(
                        spacing: 20,
                        runSpacing: 16,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              CplUserAvatar(
                                user: user,
                                size: 88,
                                borderRadius: 20,
                                showOnlineDot: true,
                                onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                              ),
                              Positioned(
                                right: -6,
                                top: -6,
                                child: InkWell(
                                  onTap: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: CplColors.safety500,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFF0B1628), width: 2),
                                    ),
                                    child: const Icon(LucideIcons.camera, size: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ConstrainedBox(
                            constraints: const BoxConstraints(minWidth: 240, maxWidth: 460),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF59E0B).withAlpha((0.18 * 255).round()),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    user.empId,
                                    style: const TextStyle(
                                      color: Color(0xFFFBBF24),
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${user.role} • ${user.zone}',
                                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 10,
                                  runSpacing: 8,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: _isUploadingAvatar ? null : _pickAndUploadAvatar,
                                      icon: _isUploadingAvatar
                                          ? const SizedBox(
                                              width: 14,
                                              height: 14,
                                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                            )
                                          : const Icon(LucideIcons.upload, size: 15),
                                      label: Text(
                                        isUr ? 'تصویر اپ لوڈ کریں' : 'Upload Profile Image',
                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: CplColors.safety500,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      ),
                                    ),
                                    if (user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty)
                                      OutlinedButton.icon(
                                        onPressed: _isUploadingAvatar ? null : _removeAvatar,
                                        icon: const Icon(LucideIcons.trash2, size: 14, color: Color(0xFFFCA5A5)),
                                        label: Text(
                                          isUr ? 'تصویر ہٹائیں' : 'Remove Photo',
                                          style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 12),
                                        ),
                                        style: OutlinedButton.styleFrom(
                                          side: BorderSide(color: const Color(0xFFFCA5A5).withAlpha((0.45 * 255).round())),
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 2. Edit Personal Information Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                              const Icon(LucideIcons.userPen, size: 18, color: CplColors.corporateNavy),
                              const SizedBox(width: 8),
                              Text(
                                isUr ? 'ذاتی معلومات میں ترمیم کریں' : 'Personal Profile Details',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_profileFeedback != null) ...[
                            Container(
                              padding: const EdgeInsets.all(11),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: _profileFeedbackOk ? CplColors.emerald50 : CplColors.red50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _profileFeedbackOk ? CplColors.emerald500 : CplColors.red600,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _profileFeedbackOk ? Icons.check_circle : Icons.error_outline,
                                    size: 18,
                                    color: _profileFeedbackOk ? CplColors.emerald600 : CplColors.red600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _profileFeedback!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _profileFeedbackOk ? CplColors.emerald700 : CplColors.red700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                              labelText: isUr ? 'پورا نام' : 'Full Name',
                              prefixIcon: const Icon(LucideIcons.user, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: isUr ? 'ای میل ایڈریس' : 'Email Address',
                              prefixIcon: const Icon(LucideIcons.mail, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _cnicController,
                            decoration: InputDecoration(
                              labelText: isUr ? 'شناختی کارڈ / موبائل' : 'CNIC / Contact ID',
                              prefixIcon: const Icon(LucideIcons.creditCard, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _zones.contains(_selectedZone) ? _selectedZone : _zones.first,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: isUr ? 'پلانٹ زون' : 'Assigned Plant Zone',
                              prefixIcon: const Icon(LucideIcons.mapPin, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _zones
                                .map((z) => DropdownMenuItem(
                                      value: z,
                                      child: Text(z, overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedZone = v);
                            },
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<String>(
                            value: _shifts.contains(_selectedShift) ? _selectedShift : _shifts.first,
                            isExpanded: true,
                            decoration: InputDecoration(
                              labelText: isUr ? 'شفٹ' : 'Active Duty Shift',
                              prefixIcon: const Icon(LucideIcons.clock, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            items: _shifts
                                .map((s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s, overflow: TextOverflow.ellipsis),
                                    ))
                                .toList(),
                            onChanged: (v) {
                              if (v != null) setState(() => _selectedShift = v);
                            },
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _isSavingProfile ? null : _saveProfile,
                              icon: _isSavingProfile
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(LucideIcons.save, size: 16),
                              label: Text(
                                isUr ? 'پروفائل محفوظ کریں' : 'Save Profile Changes',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CplColors.corporateNavy,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 3. Password & Account Security Card
                    Container(
                      padding: const EdgeInsets.all(20),
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
                              const Icon(LucideIcons.keyRound, size: 18, color: CplColors.safety500),
                              const SizedBox(width: 8),
                              Text(
                                isUr ? 'پاس ورڈ تبدیل کریں' : 'Change Password & Security',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          if (_passwordFeedback != null) ...[
                            Container(
                              padding: const EdgeInsets.all(11),
                              margin: const EdgeInsets.only(bottom: 14),
                              decoration: BoxDecoration(
                                color: _passwordFeedbackOk ? CplColors.emerald50 : CplColors.red50,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: _passwordFeedbackOk ? CplColors.emerald500 : CplColors.red600,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    _passwordFeedbackOk ? Icons.check_circle : Icons.error_outline,
                                    size: 18,
                                    color: _passwordFeedbackOk ? CplColors.emerald600 : CplColors.red600,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _passwordFeedback!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: _passwordFeedbackOk ? CplColors.emerald700 : CplColors.red700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          TextField(
                            controller: _currentPasswordController,
                            obscureText: _obscureCurrent,
                            decoration: InputDecoration(
                              labelText: isUr ? 'موجودہ پاس ورڈ / پن' : 'Current Password / PIN',
                              prefixIcon: const Icon(LucideIcons.lock, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureCurrent ? LucideIcons.eye : LucideIcons.eyeOff, size: 18),
                                onPressed: () => setState(() => _obscureCurrent = !_obscureCurrent),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _newPasswordController,
                            obscureText: _obscureNew,
                            decoration: InputDecoration(
                              labelText: isUr ? 'نیا پاس ورڈ' : 'New Password',
                              prefixIcon: const Icon(LucideIcons.shieldCheck, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureNew ? LucideIcons.eye : LucideIcons.eyeOff, size: 18),
                                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _confirmPasswordController,
                            obscureText: _obscureConfirm,
                            decoration: InputDecoration(
                              labelText: isUr ? 'نئے پاس ورڈ کی تصدیق کریں' : 'Confirm New Password',
                              prefixIcon: const Icon(LucideIcons.checkCheck, size: 18),
                              suffixIcon: IconButton(
                                icon: Icon(_obscureConfirm ? LucideIcons.eye : LucideIcons.eyeOff, size: 18),
                                onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                              ),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Align(
                            alignment: Alignment.centerRight,
                            child: ElevatedButton.icon(
                              onPressed: _isUpdatingPassword ? null : _changePassword,
                              icon: _isUpdatingPassword
                                  ? const SizedBox(
                                      width: 15,
                                      height: 15,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(LucideIcons.keyRound, size: 16),
                              label: Text(
                                isUr ? 'پاس ورڈ اپ ڈیٹ کریں' : 'Update Password',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CplColors.safety500,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // 4. Active Session Logout Bar
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: CplColors.slate200),
                      ),
                      child: Row(
                        children: [
                          const Icon(LucideIcons.logOut, color: CplColors.red600, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isUr ? 'سیشن ختم کریں' : 'Active Plant Session',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
                                ),
                                Text(
                                  isUr
                                      ? 'محفوظ طریقے سے لاگ آؤٹ کریں اور سیشن صاف کریں۔'
                                      : 'Sign out securely and clear cached credentials from this device.',
                                  style: const TextStyle(fontSize: 11.5, color: CplColors.slate600),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () => context.read<CplSystemCubit>().logout(),
                            icon: const Icon(LucideIcons.logOut, size: 15),
                            label: Text(isUr ? 'لاگ آؤٹ' : 'Logout', style: const TextStyle(fontWeight: FontWeight.bold)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: CplColors.red600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
