import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final int? statusCode;

  const Failure(this.message, {this.statusCode});

  @override
  List<Object?> get props => [message, statusCode];
}

class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.statusCode});
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Local cache operation failed']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No active network connection available']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message, {super.statusCode});
}

class HardwareFailure extends Failure {
  const HardwareFailure(super.message);
}

class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

