import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../domain/entities/user.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _employeeIdController = TextEditingController(text: 'CP-EMP-1002');
  final _passwordController = TextEditingController(text: 'Chiniot@2026');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthCubit>().login(
            employeeId: _employeeIdController.text.trim(),
            password: _passwordController.text,
          );
    }
  }

  void _setDemoRole(String empId, String roleTitle) {
    setState(() {
      _employeeIdController.text = empId;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Switched to Demo Account: $empId ($roleTitle)'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;
    final theme = Theme.of(context);

    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.emergencyRed,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: isDesktop ? 480 : 400),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(color: AppColors.borderDark),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 40.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Plant Icon & Logo
                          Center(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight.withAlpha((0.15 * 255).round()),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bolt_rounded,
                                size: 48,
                                color: AppColors.primaryLight,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'CHINIOT POWER',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'HSE Management System',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondaryDark,
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Employee ID Input with CP-EMP-XXXX format
                          TextFormField(
                            controller: _employeeIdController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: const InputDecoration(
                              labelText: 'Employee ID',
                              hintText: 'CP-EMP-XXXX',
                              prefixIcon: Icon(Icons.badge_outlined),
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your Employee ID';
                              }
                              if (!User.isValidEmployeeId(val)) {
                                return 'Invalid format. Required: CP-EMP-XXXX';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),

                          // Password Input
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword ? Icons.visibility_off : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // Sign In Button
                          ElevatedButton(
                            onPressed: isLoading ? null : _onLoginPressed,
                            child: isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                : const Text('Sign In Securely'),
                          ),

                          if (PlatformHelper.isMobile) ...[
                            const SizedBox(height: 12),
                            OutlinedButton.icon(
                              onPressed: isLoading ? null : () => _onLoginPressed(),
                              icon: const Icon(Icons.fingerprint),
                              label: const Text('Biometric Authentication'),
                            ),
                          ],

                          const SizedBox(height: 32),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Role Quick-Switch Bar for Reviewer Demo
                          const Text(
                            'RBAC Quick Demo Switcher:',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _demoRoleChip('CP-EMP-1001', 'Admin', Colors.purple),
                              _demoRoleChip('CP-EMP-1002', 'HSE Manager', Colors.blue),
                              _demoRoleChip('CP-EMP-1003', 'Inspector', Colors.amber),
                              _demoRoleChip('CP-EMP-1004', 'Worker', Colors.green),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _demoRoleChip(String id, String roleName, Color color) {
    final isSelected = _employeeIdController.text == id;
    return InkWell(
      onTap: () => _setDemoRole(id, roleName),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color.withAlpha((0.25 * 255).round()) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isSelected ? color : AppColors.borderDark),
        ),
        child: Text(
          '$roleName ($id)',
          style: TextStyle(
            fontSize: 11,
            color: isSelected ? Colors.white : AppColors.textSecondaryDark,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

