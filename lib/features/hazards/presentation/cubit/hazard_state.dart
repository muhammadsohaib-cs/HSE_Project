import 'package:equatable/equatable.dart';
import '../../domain/entities/hazard.dart';

abstract class HazardState extends Equatable {
  const HazardState();
  @override
  List<Object?> get props => [];
}

class HazardInitial extends HazardState {}

class HazardLoading extends HazardState {}

class HazardLoaded extends HazardState {
  final List<Hazard> hazards;
  final String? selectedZone;
  final CapaStatus? selectedStatus;
  final int pendingOfflineCount;
  final bool isSyncing;

  const HazardLoaded({
    required this.hazards,
    this.selectedZone,
    this.selectedStatus,
    this.pendingOfflineCount = 0,
    this.isSyncing = false,
  });

  HazardLoaded copyWith({
    List<Hazard>? hazards,
    String? selectedZone,
    CapaStatus? selectedStatus,
    int? pendingOfflineCount,
    bool? isSyncing,
  }) {
    return HazardLoaded(
      hazards: hazards ?? this.hazards,
      selectedZone: selectedZone ?? this.selectedZone,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      pendingOfflineCount: pendingOfflineCount ?? this.pendingOfflineCount,
      isSyncing: isSyncing ?? this.isSyncing,
    );
  }

  @override
  List<Object?> get props => [
        hazards,
        selectedZone,
        selectedStatus,
        pendingOfflineCount,
        isSyncing,
      ];
}

class HazardError extends HazardState {
  final String message;
  const HazardError(this.message);

  @override
  List<Object?> get props => [message];
}

class HazardOperationSuccess extends HazardState {
  final String message;
  const HazardOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

