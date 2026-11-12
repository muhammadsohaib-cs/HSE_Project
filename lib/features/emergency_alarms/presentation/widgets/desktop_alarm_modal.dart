import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/emergency_alarm.dart';
import '../cubit/alarm_cubit.dart';

class DesktopAlarmModal extends StatelessWidget {
  final EmergencyAlarm alarm;
  const DesktopAlarmModal({super.key, required this.alarm});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;
    String ackUserId = 'CP-EMP-1002';
    String ackUserName = 'Control Room Operator';

    if (authState is Authenticated) {
      ackUserId = authState.user.employeeId;
      ackUserName = authState.user.name;
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Center(
        child: Container(
          width: 580,
          decoration: BoxDecoration(
            color: const Color(0xFF1E0E0E),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.emergencyRed, width: 3),
            boxShadow: [
              BoxShadow(
                color: AppColors.emergencyRed.withAlpha((0.6 * 255).round()),
                blurRadius: 30,
                spreadRadius: 8,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: const BoxDecoration(
                  color: AppColors.emergencyRed,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(13),
                    topRight: Radius.circular(13),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 28, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      alarm.severityLevel.title.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),

              // Body Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      alarm.plantArea.toUpperCase(),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      alarm.description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFFFCA5A5),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black38,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildDetailItem('Triggered By', alarm.triggerUserName),
                          _buildDetailItem('Channels', alarm.broadcastChannels.join(' • ')),
                          _buildDetailItem('Time', alarm.triggeredAt.toString().split('.').first),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emergencyRed,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              elevation: 4,
                            ),
                            onPressed: () {
                              context.read<AlarmCubit>().acknowledgeAlarm(
                                alarm.id,
                                ackUserId,
                                ackUserName,
                              );
                              Navigator.of(context, rootNavigator: true).pop();
                            },
                            icon: const Icon(Icons.notifications_off_rounded),
                            label: const Text(
                              'Acknowledge & Silence Buzzer',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
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
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.white)),
      ],
    );
  }
}

