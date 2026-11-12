import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/cpl_localizations.dart';
import '../../core/theme/cpl_theme.dart';
import '../cpl_system/cubit/cpl_system_cubit.dart';
import '../cpl_system/cubit/cpl_system_state.dart';

class AlarmCenterScreen extends StatefulWidget {
  const AlarmCenterScreen({super.key});

  @override
  State<AlarmCenterScreen> createState() => _AlarmCenterScreenState();
}

class _AlarmCenterScreenState extends State<AlarmCenterScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        final isUr = state.isUrdu;
        final hasActiveAlarm = state.activeAlarm != null;

        return Scaffold(
          backgroundColor: CplColors.slate50,
          appBar: AppBar(
            backgroundColor: hasActiveAlarm ? CplColors.red600 : CplColors.slate900,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.read<CplSystemCubit>().setScreenIndex(1),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isUr ? 'ایمرجنسی سائرن اور الرٹ سینٹر' : 'Siren & Emergency Dispatch',
                  style: CplTypography.subheading(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Automated Gateway • Plant Siren 1122',
                  style: CplTypography.caption(context).copyWith(color: Colors.white70),
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
                // Active Alarm Pulsing Banner (if triggered)
                if (hasActiveAlarm) ...[
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: CplColors.red600.withOpacity(0.85 + 0.15 * _pulseController.value),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: CplColors.red600.withOpacity(0.5 * _pulseController.value),
                              blurRadius: 16,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.warning, color: Colors.white, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'CRITICAL ALARM ACTIVATED!',
                                        style: CplTypography.mono().copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w900,
                                          fontSize: 15,
                                        ),
                                      ),
                                      Text(
                                        '${state.activeAlarm} — EVACUATE ZONE IMMEDIATELY',
                                        style: const TextStyle(color: Colors.white, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: () {
                                context.read<CplSystemCubit>().clearPlantAlarm();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('All-Clear Drill Sounded. Plant returned to normal status.'),
                                    backgroundColor: CplColors.emerald500,
                                  ),
                                );
                              },
                              icon: const Icon(Icons.check_circle, color: CplColors.red600),
                              label: Text(
                                isUr ? 'آل کلیئر ڈرل (سائرن بند کریں)' : 'SOUND ALL-CLEAR (RESET SIREN)',
                                style: const TextStyle(
                                  color: CplColors.red600,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(42),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],

                // Critical Siren Trigger Cards
                Text(
                  isUr ? 'پلانٹ ایمرجنسی سائرن کا انتخاب کریں' : 'Manual Siren Triggers (Audio Buzzer)',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  isUr
                      ? 'بٹن دبانے پر پلانٹ اسپیکرز اور ریسکیو 1122 کو آٹو میٹڈ الرٹ چلا جائے گا'
                      : 'Triggers local buzzer, plant PA system, and automated SMS/Email gateway',
                  style: CplTypography.caption(context).copyWith(color: CplColors.slate600),
                ),
                const SizedBox(height: 12),

                // 3 Siren Buttons
                _buildSirenCard(
                  context,
                  title: isUr ? 'فائر الارم سائرن' : 'Fire & Explosion Siren',
                  subtitle: 'Boiler / Bagasse Yard Yard Ignition',
                  icon: Icons.local_fire_department,
                  color: CplColors.red600,
                  onTap: () {
                    context.read<CplSystemCubit>().triggerPlantAlarm('FIRE ALARM: BAGASSE & BOILER');
                  },
                ),
                const SizedBox(height: 10),

                _buildSirenCard(
                  context,
                  title: isUr ? 'ہائی پریشر سٹیم لیک' : 'High-Pressure Steam Rupture',
                  subtitle: 'Steam Turbine & Economizer Piping',
                  icon: Icons.air,
                  color: CplColors.safety500,
                  onTap: () {
                    context.read<CplSystemCubit>().triggerPlantAlarm('STEAM LEAK: BOILER UNIT-1');
                  },
                ),
                const SizedBox(height: 10),

                _buildSirenCard(
                  context,
                  title: isUr ? '132kV گرڈ ٹرپ / الیکٹریکل آرک' : '132kV Grid Switchyard Trip',
                  subtitle: 'Arc Flash / Hazardous Electrical Fault',
                  icon: Icons.flash_on,
                  color: CplColors.amber500,
                  onTap: () {
                    context.read<CplSystemCubit>().triggerPlantAlarm('ELECTRICAL TRIP: 132kV GRID');
                  },
                ),
                const SizedBox(height: 24),

                // Automated Email & SMS Gateway Logs
                Text(
                  isUr ? 'خودکار ای میل اور ایس ایم ایس گیٹ وے' : 'Automated Email & SMS Gateway',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: CplColors.slate200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.mark_email_read, size: 18, color: CplColors.emerald500),
                              SizedBox(width: 8),
                              Text(
                                'SMTP & Twilio Link: ONLINE',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, fontFamily: 'monospace'),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: CplColors.emerald500.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'READY',
                              style: TextStyle(color: CplColors.emerald500, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      ...state.emailLogs.map((log) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: CplColors.slate100,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.email_outlined, size: 14, color: CplColors.slate700),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      log.subject,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'To: ${log.to}',
                                      style: TextStyle(fontSize: 11, color: CplColors.slate600, fontFamily: 'monospace'),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    log.time,
                                    style: TextStyle(fontSize: 10, color: CplColors.slate600),
                                  ),
                                  Text(
                                    log.status,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: log.status == 'Delivered' || log.status == 'Sent'
                                          ? CplColors.emerald500
                                          : CplColors.amber500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Emergency Contacts Strip
                Text(
                  isUr ? 'فوری رابطہ نمبرز' : 'Emergency Contacts Quick Dial',
                  style: CplTypography.subheading(context).copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildContactChip('Rescue 1122', '047-1122', Icons.emergency),
                    const SizedBox(width: 8),
                    _buildContactChip('DHQ Hospital', '047-9200144', Icons.local_hospital),
                    const SizedBox(width: 8),
                    _buildContactChip('DCS Desk', 'Ext 204', Icons.phone_in_talk),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSirenCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.5, color: color),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: CplColors.slate600),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'SOUND',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactChip(String label, String phone, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CplColors.slate200),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: CplColors.slate700),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
            Text(phone, style: TextStyle(fontSize: 10, color: CplColors.slate600, fontFamily: 'monospace')),
          ],
        ),
      ),
    );
  }
}
