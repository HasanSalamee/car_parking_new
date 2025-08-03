import 'package:car_parking/features/auth/Domain/Repositories/auth_repository.dart';
import 'package:car_parking/features/auth/Domain/Usecases/get_current_user.dart';
import 'package:car_parking/features/auth/Domain/Usecases/login_usecase.dart';
import 'package:car_parking/features/auth/Domain/Usecases/signup_usecase.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_event.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<SignupEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await SignupUseCase(authRepository)(
        email: event.email,
        password: event.password,
      );
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });

    on<LoginEvent>((event, emit) async {
      emit(AuthLoading());
    //  print("🔐 AuthBloc: LoginEvent received");
    // print("📧 Email: ${event.email}, 🔑 Password: ${event.password}");

      final result = await LoginUseCase(authRepository)(
        email: event.email,
        password: event.password,
      );

      result.fold(
        (failure) {
        //  print("❌ Login failed with message: ${failure.message}");
          emit(AuthFailure(failure.message));
        },
        (token) {
        //  print("✅ Login success, token received: $token");
          emit(AuthSuccess(token));
        },
      );
    });
    on<GetCurrentUserEvent>((event, emit) async {
      emit(AuthLoading());
      final result = await GetCurrentUser(authRepository)();
      result.fold(
        (failure) => emit(AuthFailure(failure.message)),
        (user) => emit(AuthSuccess(user)),
      );
    });
  }
}
