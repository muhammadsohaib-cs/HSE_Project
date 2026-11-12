import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthCubit({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _registerUseCase = registerUseCase,
        _logoutUseCase = logoutUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase,
        super(AuthInitial());

  Future<void> checkAuthStatus() async {
    emit(AuthLoading());
    try {
      final user = await _getCurrentUserUseCase.execute();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (e) {
      emit(Unauthenticated());
    }
  }

  Future<void> login({
    required String employeeId,
    required String password,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _loginUseCase.execute(
        employeeId: employeeId,
        password: password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('ValidationFailure: ', '')));
    }
  }

  Future<void> register({
    required String employeeId,
    required String name,
    required String email,
    required String password,
    required UserRole role,
    required String department,
    required String plantUnit,
  }) async {
    emit(AuthLoading());
    try {
      final user = await _registerUseCase.execute(
        employeeId: employeeId,
        name: name,
        email: email,
        password: password,
        role: role,
        department: department,
        plantUnit: plantUnit,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString().replaceAll('ValidationFailure: ', '')));
    }
  }

  Future<void> logout() async {
    emit(AuthLoading());
    try {
      await _logoutUseCase.execute();
      emit(Unauthenticated());
    } catch (e) {
      emit(Unauthenticated());
    }
  }
}

