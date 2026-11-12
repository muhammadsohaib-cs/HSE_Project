import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/plant_zones.dart';
import '../../../../core/platform/platform_helper.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/entities/emergency_alarm.dart';
import '../cubit/alarm_cubit.dart';
import '../cubit/alarm_state.dart';
import '../widgets/desktop_alarm_modal.dart';

class AlarmDispatchPage extends StatefulWidget {
  const AlarmDispatchPage({super.key});

  @override
  State<AlarmDispatchPage> createState() => _AlarmDispatchPageState();
}

class _AlarmDispatchPageState extends State<AlarmDispatchPage> {
  final _reasonController = TextEditingController();
  String _selectedZone = PlantZones.boilerSection;
  AlarmSeverity _selectedSeverity = AlarmSeverity.critical;

  bool _channelFcm = true;
  bool _channelEmail = true;
  bool _channelDesktopSiren = true;
  bool _confirmedSafeguard = false;

  @override
  void initState() {
    super.initState();
    context.read<AlarmCubit>().loadAlarms();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  void _dispatchAlarm() {
    final reason = _reasonController.text.trim();
    if (reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please provide an emergency description before broadcast')),
      );
      return;
    }

    if (!_confirmedSafeguard) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Accidental dispatch safeguard: You must check the confirmation box!'),
          backgroundColor: AppColors.emergencyRed,
        ),
      );
      return;
    }

    final authState = context.read<AuthCubit>().state;
    String triggerUserId = 'CP-EMP-1002';
    String triggerUserName = 'HSE Manager';

    if (authState is Authenticated) {
      triggerUserId = authState.user.employeeId;
      triggerUserName = authState.user.name;
    }

    final channels = <String>[];
    if (_channelFcm) channels.add('FCM Push Notification');
    if (_channelEmail) channels.add('SendGrid / SMTP Email');
    if (_channelDesktopSiren) channels.add('Desktop Siren Audio Buzzer');

    final alarm = EmergencyAlarm(
      id: 'ALM-${DateTime.now().year}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      triggerUserId: triggerUserId,
      triggerUserName: triggerUserName,
      plantArea: _selectedZone,
      severityLevel: _selectedSeverity,
      description: reason,
      broadcastChannels: channels,
      triggeredAt: DateTime.now(),
    );

    context.read<AlarmCubit>().dispatchAlarm(alarm);

    // Trigger Desktop floating modal if on desktop or critical
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => DesktopAlarmModal(alarm: alarm),
    );

    setState(() {
      _reasonController.clear();
      _confirmedSafeguard = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = PlatformHelper.isDesktop;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Dispatch & Plant Alarming'),
        backgroundColor: const Color(0xFF1F1010),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AlarmCubit>().loadAlarms(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: isDesktop ? 960 : double.infinity),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Dispatch Form Card
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: const BorderSide(color: AppColors.emergencyRed, width: 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(
                                color: AppColors.emergencyRed,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.campaign, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'HSE Command Emergency Broadcast',
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Initiate instantaneous multi-channel plant dispatch',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Severity Level Selector
                        const Text('1. Alarm Severity Level', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Row(
                          children: AlarmSeverity.values.map((sev) {
                            final isSel = _selectedSeverity == sev;
                            final color = sev == AlarmSeverity.warning
                                ? AppColors.riskMedium
                                : (sev == AlarmSeverity.critical ? AppColors.riskHigh : AppColors.emergencyRed);

                            return Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: InkWell(
                                  onTap: () => setState(() => _selectedSeverity = sev),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                    decoration: BoxDecoration(
                                      color: isSel ? color.withAlpha((0.2 * 255).round()) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: isSel ? color : AppColors.borderDark, width: isSel ? 2 : 1),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          sev.title,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            color: isSel ? color : Colors.white,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),

                        // Plant Zone
                        const Text('2. Affected Plant Section', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: _selectedZone,
                          decoration: const InputDecoration(prefixIcon: Icon(Icons.location_on_outlined)),
                          items: PlantZones.allZones.map((z) => DropdownMenuItem(value: z, child: Text(z))).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedZone = v);
                          },
                        ),
                        const SizedBox(height: 20),

                        // Description
                        const Text('3. Emergency Nature & Evacuation Directive', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _reasonController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Major steam leak detected on Boiler #2 main steam line. All personnel in Unit 2 evacuate to Muster Point Alpha.',
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Broadcast Channels
                        const Text('4. Multi-Channel Distribution', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 16,
                          children: [
                            FilterChip(
                              label: const Text('FCM Mobile Push (High Priority)'),
                              selected: _channelFcm,
                              onSelected: (v) => setState(() => _channelFcm = v),
                            ),
                            FilterChip(
                              label: const Text('Transactional Email (SendGrid/SMTP)'),
                              selected: _channelEmail,
                              onSelected: (v) => setState(() => _channelEmail = v),
                            ),
                            FilterChip(
                              label: const Text('Desktop Workstation Siren Modal'),
                              selected: _channelDesktopSiren,
                              onSelected: (v) => setState(() => _channelDesktopSiren = v),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Accidental Dispatch Safeguard Confirmation
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red.withAlpha((0.1 * 255).round()),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade900),
                          ),
                          child: CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text(
                              'Confirmation Safeguard: I confirm this is a verified plant emergency requiring immediate dispatch.',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            value: _confirmedSafeguard,
                            onChanged: (v) => setState(() => _confirmedSafeguard = v ?? false),
                            activeColor: AppColors.emergencyRed,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Broadcast Button
                        ElevatedButton.icon(
                          onPressed: _confirmedSafeguard ? _dispatchAlarm : null,
                          icon: const Icon(Icons.warning, color: Colors.white),
                          label: const Text('DISPATCH EMERGENCY BROADCAST NOW'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.emergencyRed,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Alarms Audit Trail
                const Text(
                  'Recent Plant Alarm History & Acknowledgments',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                BlocBuilder<AlarmCubit, AlarmState>(
                  builder: (context, state) {
                    if (state is AlarmLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state is AlarmLoaded) {
                      if (state.alarms.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Text('No historical alarms logged.'),
                          ),
                        );
                      }

                      return ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: state.alarms.length,
                        itemBuilder: (context, index) {
                          final a = state.alarms[index];
                          final isAck = a.isAcknowledged;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isAck ? AppColors.riskLow : AppColors.emergencyRed,
                                    child: Icon(
                                      isAck ? Icons.check : Icons.priority_high,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              '${a.id} • ${a.severityLevel.title.toUpperCase()}',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: a.severityLevel == AlarmSeverity.warning ? AppColors.riskMedium : AppColors.emergencyRed,
                                                fontSize: 13,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Text('(${a.plantArea})', style: const TextStyle(fontSize: 12)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(a.description, style: const TextStyle(fontSize: 13)),
                                        const SizedBox(height: 6),
                                        Text(
                                          isAck
                                              ? 'Acknowledged by ${a.acknowledgedBy} at ${a.acknowledgedAt.toString().split(".").first}'
                                              : 'Triggered at ${a.triggeredAt.toString().split(".").first} by ${a.triggerUserName}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (!isAck)
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.emergencyRed),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => DesktopAlarmModal(alarm: a),
                                        );
                                      },
                                      child: const Text('View Alert'),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

