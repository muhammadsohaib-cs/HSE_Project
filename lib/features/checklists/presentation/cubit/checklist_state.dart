import 'package:equatable/equatable.dart';
import '../../domain/entities/checklist.dart';

abstract class ChecklistState extends Equatable {
  const ChecklistState();
  @override
  List<Object?> get props => [];
}

class ChecklistInitial extends ChecklistState {}

class ChecklistLoading extends ChecklistState {}

class ChecklistLoaded extends ChecklistState {
  final List<ChecklistTemplate> templates;
  final List<ChecklistAudit> audits;

  const ChecklistLoaded({
    required this.templates,
    required this.audits,
  });

  ChecklistLoaded copyWith({
    List<ChecklistTemplate>? templates,
    List<ChecklistAudit>? audits,
  }) {
    return ChecklistLoaded(
      templates: templates ?? this.templates,
      audits: audits ?? this.audits,
    );
  }

  @override
  List<Object?> get props => [templates, audits];
}

class ChecklistError extends ChecklistState {
  final String message;
  const ChecklistError(this.message);

  @override
  List<Object?> get props => [message];
}

class ChecklistSubmittedSuccess extends ChecklistState {
  final ChecklistAudit audit;
  const ChecklistSubmittedSuccess(this.audit);

  @override
  List<Object?> get props => [audit];
}

