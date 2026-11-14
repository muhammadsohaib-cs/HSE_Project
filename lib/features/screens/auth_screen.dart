import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/platform/biometric_service.dart';
import '../../core/theme/cpl_theme.dart';
import '../../core/widgets/cpl_brand_logo.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _empIdController = TextEditingController();
  final _pinController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _cnicMobileController = TextEditingController();
  final BiometricAuthService _biometricAuth = BiometricAuthService();

  String _selectedShift = 'General Shift (08:00 - 17:00)';
  String _selectedRole = 'HSE Manager';
  String _selectedZone = 'Boiler Area (Unit 1 & 2)';
  String? _errorMessage;
  String? _successMessage;
  bool _isSubmitting = false;

  final List<String> _shifts = [
    'General Shift (08:00 - 17:00)',
    'Shift A (07:00 - 19:00 / 19:00 - 07:00)',
    'Shift B (07:00 - 19:00 / 19:00 - 07:00)',
    'Shift C (07:00 - 19:00 / 19:00 - 07:00)',
    'Shift D (07:00 - 19:00 / 19:00 - 07:00)',
  ];

  final List<String> _roles = [
    'Plant Worker',
    'Safety Officer',
    'HSE Manager',
  ];

  final List<String> _zones = [
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
    _empIdController.dispose();
    _pinController.dispose();
    _fullNameController.dispose();
    _cnicMobileController.dispose();
    super.dispose();
  }

  void _fillAccount({required String empId, required String role, required String pin, required String name}) {
    setState(() {
      _empIdController.text = empId;
      _pinController.text = pin;
      _selectedRole = role;
      _fullNameController.text = name;
      _errorMessage = null;
      _successMessage = null;
    });
    context.read<CplSystemCubit>().clearAuthError();
  }

  void _showServerSettingsDialog(BuildContext context) {
    final controller = TextEditingController(text: ApiEndpoints.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.settings_ethernet, color: CplColors.energyAmber),
            SizedBox(width: 8),
            Text('Plant Server Settings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Specify CPL Intranet / Backend Gateway URL for synchronizing field data across devices:',
              style: TextStyle(fontSize: 12, color: CplColors.slate600),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Backend Gateway URL',
                hintText: 'http://10.0.2.2:5000/api/v1',
                prefixIcon: Icon(Icons.dns_outlined, size: 20),
              ),
              style: const TextStyle(fontFamily: 'monospace', fontSize: 13),
            ),
            const SizedBox(height: 12),
            const Text('Quick Select Preset:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                ActionChip(
                  label: const Text('Android (10.0.2.2)', style: TextStyle(fontSize: 10)),
                  onPressed: () => controller.text = 'http://10.0.2.2:5000/api/v1',
                ),
                ActionChip(
                  label: const Text('PC / Web (localhost)', style: TextStyle(fontSize: 10)),
                  onPressed: () => controller.text = 'http://localhost:5000/api/v1',
                ),
                ActionChip(
                  label: const Text('Physical Wi-Fi (LAN)', style: TextStyle(fontSize: 10)),
                  onPressed: () => controller.text = 'http://192.168.1.40:5000/api/v1',
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final newUrl = controller.text.trim();
              if (newUrl.isNotEmpty) {
                context.read<CplSystemCubit>().updateServerUrl(newUrl);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Server Gateway updated to: $newUrl'),
                    backgroundColor: CplColors.renewableGreen,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: CplColors.corporateNavy,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save & Reconnect'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleBiometricLogin() async {
    final authenticated = await _biometricAuth.authenticate(
      reason: 'Scan fingerprint to verify CPL Staff identity',
    );
    if (!mounted) return;
    if (authenticated) {
      final cubit = context.read<CplSystemCubit>();
      await cubit.login(
        empId: _empIdController.text.trim(),
        shift: _selectedShift,
        role: _selectedRole,
        pin: _pinController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Biometric verified for ${_empIdController.text.trim()}'),
            backgroundColor: CplColors.emerald600,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Biometric verification failed. Please enter PIN.'),
          backgroundColor: CplColors.red600,
        ),
      );
    }
  }

  Future<void> _handleSubmit() async {
    final cubit = context.read<CplSystemCubit>();
    final cleanEmpId = _empIdController.text.trim().toUpperCase();
    final cleanSecret = _pinController.text.trim();
    final cleanName = _fullNameController.text.trim();

    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (cleanEmpId.isEmpty) {
      setState(() => _errorMessage = 'Please enter your Employee ID (e.g., CPL-EMP-1042).');
      return;
    }
    if (cleanSecret.isEmpty) {
      setState(() => _errorMessage = 'Please enter your Password or Security PIN.');
      return;
    }

    if (_isLogin) {
      setState(() => _isSubmitting = true);
      final success = await cubit.login(
        empId: cleanEmpId,
        shift: _selectedShift,
        role: _selectedRole,
        pin: cleanSecret,
        password: cleanSecret,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Authenticated $cleanEmpId ($_selectedShift)'),
              backgroundColor: CplColors.slate900,
            ),
          );
        } else {
          setState(() {
            _errorMessage = cubit.state.lastAuthError ??
                'Invalid Employee ID or Password/PIN. Please check your credentials.';
          });
        }
      }
    } else {
      if (cleanName.isEmpty) {
        setState(() => _errorMessage = 'Please enter your Full Name.');
        return;
      }
      setState(() => _isSubmitting = true);
      final success = await cubit.signup(
        empId: cleanEmpId,
        fullName: cleanName,
        cnic: _cnicMobileController.text.trim(),
        shift: _selectedShift,
        role: _selectedRole,
        pin: cleanSecret,
        password: cleanSecret,
        assignedZone: _selectedZone,
      );
      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          setState(() {
            _isLogin = true;
            _empIdController.text = cleanEmpId;
            _pinController.text = cleanSecret;
            _successMessage = 'Account Registered for $cleanEmpId! Please sign in.';
            _errorMessage = null;
          });
        } else {
          setState(() {
            _errorMessage = cubit.state.lastAuthError ??
                'Registration failed for $cleanEmpId. Please try again.';
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final lang = state.language;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // CPL Plant Branding Header Card with Official Logo & Server Settings
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CplColors.corporateNavy,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: CplColors.corporateNavy.withAlpha((0.25 * 255).round()),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CplBrandLogo(
                            height: 38,
                            isDark: true,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.settings_ethernet, color: CplColors.energyAmber, size: 22),
                          tooltip: 'Plant Server Settings',
                          onPressed: () => _showServerSettingsDialog(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _isLogin ? CplLocalizations.tr('loginTitle', lang) : CplLocalizations.tr('signupTitle', lang),
                          style: CplTypography.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CplColors.energyAmber,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            ApiEndpoints.baseUrl.contains('10.0.2.2') ? 'Emulator Mode' : 'Live Gateway',
                            style: const TextStyle(fontSize: 10, color: Colors.white70, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Fast Switch Real CPL Personnel Chips
              Row(
                children: const [
                  Text('CPL VERIFIED STAFF • فوری عملہ لاگ ان:', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold, color: CplColors.slate600)),
                ],
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ActionChip(
                      avatar: const Icon(Icons.admin_panel_settings, size: 14, color: Colors.white),
                      label: const Text('3648 Sumaira Rafique (HSE Lead)', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: CplColors.corporateNavy,
                      onPressed: () => _fillAccount(empId: 'CPL-EMP-3648', role: 'HSE Manager', pin: '3648', name: 'Sumaira Rafique'),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.engineering, size: 14, color: Colors.white),
                      label: const Text('0509 M. Shahbaz (SM Shift A)', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: CplColors.emerald600,
                      onPressed: () => _fillAccount(empId: 'CPL-EMP-0509', role: 'HSE Manager', pin: '0509', name: 'Muhammad Shahbaz'),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.verified_user, size: 14, color: Colors.white),
                      label: const Text('3845 Faisal Nadeem (Safety)', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: CplColors.safety500,
                      onPressed: () => _fillAccount(empId: 'CPL-EMP-3845', role: 'Safety Officer', pin: '3845', name: 'Faisal Nadeem'),
                    ),
                    const SizedBox(width: 6),
                    ActionChip(
                      avatar: const Icon(Icons.person, size: 14, color: Colors.white),
                      label: const Text('0808 Umer Asghar (CCR Engr)', style: TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.bold)),
                      backgroundColor: CplColors.slate700,
                      onPressed: () => _fillAccount(empId: 'CPL-EMP-0808', role: 'Plant Worker', pin: '0808', name: 'Umer Asghar'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Login / Signup Segmented Toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: CplColors.slate200,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isLogin = true;
                          _errorMessage = null;
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: _isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: _isLogin
                                ? [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4)]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'Staff Login (لاگ ان)',
                            style: CplTypography.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _isLogin ? CplColors.slate900 : CplColors.slate600,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () => setState(() {
                          _isLogin = false;
                          _errorMessage = null;
                          _successMessage = null;
                          if (_empIdController.text.trim() == 'CPL-EMP-1001' &&
                              _fullNameController.text.trim() == 'Engr. Tariq Khan') {
                            _empIdController.clear();
                            _pinController.clear();
                            _fullNameController.clear();
                            _cnicMobileController.clear();
                          }
                        }),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: !_isLogin ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: !_isLogin
                                ? [BoxShadow(color: Colors.black.withAlpha((0.05 * 255).round()), blurRadius: 4)]
                                : null,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'New Signup (رجسٹریشن)',
                            style: CplTypography.body(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: !_isLogin ? CplColors.slate900 : CplColors.slate600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Inline Green Confirmation Banner (Registration -> Login)
              if (_successMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CplColors.emerald50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.emerald500),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: CplColors.emerald600, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _successMessage!,
                          style: CplTypography.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CplColors.emerald700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Inline Red Validation Error Banner
              if ((_errorMessage ?? state.lastAuthError) != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: CplColors.red50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.red600),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: CplColors.red600, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          (_errorMessage ?? state.lastAuthError)!,
                          style: CplTypography.body(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: CplColors.red700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Form Inputs Container
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: CplColors.slate200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMPLOYEE ID • ملازم نمبر', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _empIdController,
                      style: CplTypography.mono(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.badge_outlined, size: 18),
                        hintText: 'CPL-EMP-XXXX',
                      ),
                    ),
                    const SizedBox(height: 14),

                    Text('SECURITY PIN / PASSWORD • پن کوڈ', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _pinController,
                      obscureText: true,
                      keyboardType: TextInputType.text,
                      style: CplTypography.mono(fontSize: 13, fontWeight: FontWeight.bold),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.lock_outline, size: 18),
                        hintText: '4-digit PIN (e.g. 1001, 1042) or admin123',
                      ),
                    ),
                    const SizedBox(height: 14),

                    if (!_isLogin) ...[
                      Text('FULL NAME • پورا نام', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _fullNameController,
                        style: CplTypography.body(fontSize: 13, fontWeight: FontWeight.w600),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.person_outline, size: 18),
                          hintText: 'e.g. Bilal Mahmood',
                        ),
                      ),
                      const SizedBox(height: 14),

                      Text('ASSIGNED PLANT ZONE • پلانٹ زون', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
                        value: _selectedZone,
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.location_on_outlined, size: 18),
                        ),
                        items: _zones
                            .map((z) => DropdownMenuItem<String>(
                                  value: z,
                                  child: Text(z, style: CplTypography.body(fontSize: 12, fontWeight: FontWeight.w600)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedZone = val);
                        },
                      ),
                      const SizedBox(height: 14),
                    ],

                    Text('CNIC / MOBILE VERIFICATION • شناختی کارڈ', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cnicMobileController,
                      style: CplTypography.mono(fontSize: 12),
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.verified_user_outlined, size: 18),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Text('ACTIVE DUTY SHIFT • شفٹ منتخب کریں', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                    const SizedBox(height: 8),
                    ..._shifts.map((sh) {
                      final isSelected = _selectedShift == sh;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: InkWell(
                          onTap: () => setState(() => _selectedShift = sh),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? CplColors.safety50 : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isSelected ? CplColors.safety500 : CplColors.slate200),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  sh,
                                  style: CplTypography.body(
                                    fontSize: 12,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    color: isSelected ? CplColors.safety600 : CplColors.slate800,
                                  ),
                                ),
                                CircleAvatar(
                                  radius: 5,
                                  backgroundColor: isSelected ? CplColors.safety500 : CplColors.slate300,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 10),

                    Text('ROLE BADGE • عہدہ', style: CplTypography.body(fontSize: 10, fontWeight: FontWeight.bold, color: CplColors.slate500)),
                    const SizedBox(height: 8),
                    Row(
                      children: _roles.map((r) {
                        final isSelected = _selectedRole == r;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2.0),
                            child: InkWell(
                              onTap: () => setState(() => _selectedRole = r),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? CplColors.corporateNavy : CplColors.slate50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? CplColors.corporateNavy : CplColors.slate200),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  r,
                                  style: CplTypography.body(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected ? Colors.white : CplColors.slate700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CplColors.corporateNavy,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        _isLogin ? '${CplLocalizations.tr('signInBtn', lang)} →' : '${CplLocalizations.tr('registerBtn', lang)} →',
                        style: CplTypography.displayHeading(fontSize: 13, color: Colors.white),
                      ),
              ),

              if (_isLogin) ...[
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: _handleBiometricLogin,
                  icon: const Icon(Icons.fingerprint, color: CplColors.slate900, size: 20),
                  label: Text(
                    'Biometric Sign In • فنگر پرنٹ لاگ ان',
                    style: CplTypography.body(fontSize: 12, fontWeight: FontWeight.bold, color: CplColors.slate900),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    side: const BorderSide(color: CplColors.slate300, width: 1.2),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

