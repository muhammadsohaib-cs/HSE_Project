import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _empIdController = TextEditingController(text: 'CPL-EMP-1042');
  final _fullNameController = TextEditingController(text: 'Muhammad Tariq');
  final _cnicMobileController = TextEditingController(text: '33202-4829104-1 / 0300-8661042');

  String _selectedShift = 'Shift A: Morning';
  String _selectedRole = 'Safety Officer';

  final List<String> _shifts = [
    'Shift A: Morning',
    'Shift B: Evening',
    'Shift C: Night',
  ];

  final List<String> _roles = [
    'Plant Worker',
    'Safety Officer',
    'HSE Manager',
  ];

  @override
  void dispose() {
    _empIdController.dispose();
    _fullNameController.dispose();
    _cnicMobileController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final cubit = context.read<CplSystemCubit>();
    if (_isLogin) {
      cubit.login(
        empId: _empIdController.text.trim(),
        shift: _selectedShift,
        role: _selectedRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authenticated ${_empIdController.text.trim()} ($_selectedShift)'),
          backgroundColor: CplColors.slate900,
        ),
      );
    } else {
      cubit.signup(
        empId: _empIdController.text.trim(),
        fullName: _fullNameController.text.trim(),
        cnic: _cnicMobileController.text.trim(),
        shift: _selectedShift,
        role: _selectedRole,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration submitted! Awaiting HSE Manager approval.'),
          backgroundColor: CplColors.safety500,
        ),
      );
      setState(() => _isLogin = true);
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
              // CPL Plant Branding Header Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: CplColors.slate900,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: CplColors.slate900.withAlpha((0.2 * 255).round()),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: CplColors.safety500,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            'CPL',
                            style: CplTypography.displayHeading(fontSize: 14, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                CplLocalizations.tr('plantName', lang),
                                style: CplTypography.displayHeading(fontSize: 15, color: Colors.white),
                              ),
                              Text(
                                CplLocalizations.tr('plantSub', lang),
                                style: CplTypography.body(fontSize: 11, color: CplColors.slate300),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _isLogin ? CplLocalizations.tr('loginTitle', lang) : CplLocalizations.tr('signupTitle', lang),
                      style: CplTypography.body(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: CplColors.safety400,
                      ),
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
                        onTap: () => setState(() => _isLogin = true),
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
                        onTap: () => setState(() => _isLogin = false),
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
              const SizedBox(height: 14),

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
                                  color: isSelected ? CplColors.slate900 : CplColors.slate50,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isSelected ? CplColors.slate900 : CplColors.slate200),
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
                onPressed: _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CplColors.safety500,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text(
                  _isLogin ? '${CplLocalizations.tr('signInBtn', lang)} →' : '${CplLocalizations.tr('registerBtn', lang)} →',
                  style: CplTypography.displayHeading(fontSize: 13, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
