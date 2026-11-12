import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/network/dio_client.dart';
import 'core/platform/audio_service.dart';
import 'core/storage/hive_boxes.dart';
import 'core/storage/offline_sync_queue.dart';
import 'core/storage/secure_storage_service.dart';
import 'core/theme/cpl_theme.dart';
import 'core/widgets/responsive_shell.dart';

// Unified CPL System Cubit & Models
import 'features/cpl_system/cubit/cpl_system_cubit.dart';
import 'features/cpl_system/cubit/cpl_system_state.dart';

// Existing Feature Cubits for complete backward compatibility
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/usecases/login_usecase.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

import 'features/hazards/data/datasources/hazard_local_data_source.dart';
import 'features/hazards/data/datasources/hazard_remote_data_source.dart';
import 'features/hazards/data/repositories/hazard_repository_impl.dart';
import 'features/hazards/domain/usecases/hazard_usecases.dart';
import 'features/hazards/presentation/cubit/hazard_cubit.dart';

import 'features/checklists/data/datasources/checklist_local_data_source.dart';
import 'features/checklists/data/datasources/checklist_remote_data_source.dart';
import 'features/checklists/data/repositories/checklist_repository_impl.dart';
import 'features/checklists/domain/usecases/checklist_usecases.dart';
import 'features/checklists/presentation/cubit/checklist_cubit.dart';

import 'features/emergency_alarms/data/datasources/alarm_local_data_source.dart';
import 'features/emergency_alarms/data/datasources/alarm_remote_data_source.dart';
import 'features/emergency_alarms/data/repositories/alarm_repository_impl.dart';
import 'features/emergency_alarms/domain/usecases/alarm_usecases.dart';
import 'features/emergency_alarms/presentation/cubit/alarm_cubit.dart';

import 'features/training/data/datasources/training_local_data_source.dart';
import 'features/training/data/datasources/training_remote_data_source.dart';
import 'features/training/data/repositories/training_repository_impl.dart';
import 'features/training/domain/usecases/training_usecases.dart';
import 'features/training/presentation/cubit/training_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive Offline Storage with safe error handling
  try {
    await Hive.initFlutter();
    await Hive.openBox(HiveBoxes.hazardsBox);
    await Hive.openBox(HiveBoxes.offlineSyncQueueBox);
    await Hive.openBox(HiveBoxes.checklistsBox);
    await Hive.openBox(HiveBoxes.checklistTemplatesBox);
    await Hive.openBox(HiveBoxes.trainingsBox);
    await Hive.openBox(HiveBoxes.alarmsBox);
    await Hive.openBox(HiveBoxes.auditLogsBox);
    await Hive.openBox(HiveBoxes.rosterBox);
    await Hive.openBox(HiveBoxes.permitsBox);
    await Hive.openBox(HiveBoxes.userBox);
  } catch (e) {
    debugPrint('Hive initialization notice: $e');
  }

  // Initialize Core Services
  final secureStorage = SecureStorageService();
  final dioClient = DioClient(secureStorage: secureStorage);
  final syncQueue = OfflineSyncQueue();
  final audioAlarmService = AudioAlarmService();
  try {
    await audioAlarmService.init();
  } catch (e) {
    debugPrint('AudioAlarmService init notice: $e');
  }

  // Auth Dependencies
  final authLocalDataSource = AuthLocalDataSourceImpl(secureStorage: secureStorage);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(dio: dioClient.dio);
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );
  final loginUseCase = LoginUseCase(authRepository);
  final registerUseCase = RegisterUseCase(authRepository);
  final logoutUseCase = LogoutUseCase(authRepository);
  final getCurrentUserUseCase = GetCurrentUserUseCase(authRepository);

  // Hazard Dependencies
  final hazardLocalDataSource = HazardLocalDataSourceImpl(syncQueue: syncQueue);
  final hazardRemoteDataSource = HazardRemoteDataSourceImpl(dio: dioClient.dio);
  final hazardRepository = HazardRepositoryImpl(
    remoteDataSource: hazardRemoteDataSource,
    localDataSource: hazardLocalDataSource,
  );
  final getHazardsUseCase = GetHazardsUseCase(hazardRepository);
  final reportHazardUseCase = ReportHazardUseCase(hazardRepository);
  final updateCapaStatusUseCase = UpdateCapaStatusUseCase(hazardRepository);
  final syncOfflineHazardsUseCase = SyncOfflineHazardsUseCase(hazardRepository);

  // Checklist Dependencies
  final checklistLocalDataSource = ChecklistLocalDataSourceImpl();
  final checklistRemoteDataSource = ChecklistRemoteDataSourceImpl(dio: dioClient.dio);
  final checklistRepository = ChecklistRepositoryImpl(
    remoteDataSource: checklistRemoteDataSource,
    localDataSource: checklistLocalDataSource,
  );
  final getChecklistTemplatesUseCase = GetChecklistTemplatesUseCase(checklistRepository);
  final getChecklistAuditsUseCase = GetChecklistAuditsUseCase(checklistRepository);
  final submitChecklistAuditUseCase = SubmitChecklistAuditUseCase(checklistRepository);
  final exportShiftTurnoverUseCase = ExportShiftTurnoverUseCase(checklistRepository);

  // Emergency Alarm Dependencies
  final alarmLocalDataSource = AlarmLocalDataSourceImpl();
  final alarmRemoteDataSource = AlarmRemoteDataSourceImpl(dio: dioClient.dio);
  final alarmRepository = AlarmRepositoryImpl(
    remoteDataSource: alarmRemoteDataSource,
    localDataSource: alarmLocalDataSource,
  );
  final getAlarmsUseCase = GetAlarmsUseCase(alarmRepository);
  final triggerAlarmUseCase = TriggerAlarmUseCase(alarmRepository);
  final acknowledgeAlarmUseCase = AcknowledgeAlarmUseCase(alarmRepository);

  // Training Dependencies
  final trainingLocalDataSource = TrainingLocalDataSourceImpl();
  final trainingRemoteDataSource = TrainingRemoteDataSourceImpl(dio: dioClient.dio);
  final trainingRepository = TrainingRepositoryImpl(
    remoteDataSource: trainingRemoteDataSource,
    localDataSource: trainingLocalDataSource,
  );
  final getCoursesUseCase = GetCoursesUseCase(trainingRepository);
  final getCertificationsUseCase = GetCertificationsUseCase(trainingRepository);
  final logAttendanceUseCase = LogAttendanceUseCase(trainingRepository);

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<CplSystemCubit>(
          create: (_) => CplSystemCubit(
            audioService: audioAlarmService,
            dioClient: dioClient,
            syncQueue: syncQueue,
          )..initFromStorage(),
        ),
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            loginUseCase: loginUseCase,
            registerUseCase: registerUseCase,
            logoutUseCase: logoutUseCase,
            getCurrentUserUseCase: getCurrentUserUseCase,
          ),
        ),
        BlocProvider<HazardCubit>(
          create: (_) => HazardCubit(
            getHazardsUseCase: getHazardsUseCase,
            reportHazardUseCase: reportHazardUseCase,
            updateCapaStatusUseCase: updateCapaStatusUseCase,
            syncOfflineHazardsUseCase: syncOfflineHazardsUseCase,
            repository: hazardRepository,
          ),
        ),
        BlocProvider<ChecklistCubit>(
          create: (_) => ChecklistCubit(
            getTemplatesUseCase: getChecklistTemplatesUseCase,
            getAuditsUseCase: getChecklistAuditsUseCase,
            submitAuditUseCase: submitChecklistAuditUseCase,
            exportShiftTurnoverUseCase: exportShiftTurnoverUseCase,
          ),
        ),
        BlocProvider<AlarmCubit>(
          create: (_) => AlarmCubit(
            getAlarmsUseCase: getAlarmsUseCase,
            triggerAlarmUseCase: triggerAlarmUseCase,
            acknowledgeAlarmUseCase: acknowledgeAlarmUseCase,
            audioAlarmService: audioAlarmService,
          ),
        ),
        BlocProvider<TrainingCubit>(
          create: (_) => TrainingCubit(
            getCoursesUseCase: getCoursesUseCase,
            getCertificationsUseCase: getCertificationsUseCase,
            logAttendanceUseCase: logAttendanceUseCase,
          ),
        ),
      ],
      child: const ChiniotPowerHseApp(),
    ),
  );
}

class ChiniotPowerHseApp extends StatelessWidget {
  const ChiniotPowerHseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CplSystemCubit, CplSystemState>(
      builder: (context, state) {
        return MaterialApp(
          title: 'Chiniot Power Limited (CPL) — HSE Management System',
          debugShowCheckedModeBanner: false,
          theme: CplTheme.lightTheme,
          home: const ResponsiveShell(),
        );
      },
    );
  }
}
