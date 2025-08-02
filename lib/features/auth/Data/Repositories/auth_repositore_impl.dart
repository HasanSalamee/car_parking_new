import 'package:car_parking/core/errors/failure.dart';
import 'package:car_parking/features/auth/Data/Datasources/auth_local.dart';
import 'package:car_parking/features/auth/Data/Datasources/auth_remote.dart';
import 'package:car_parking/features/auth/Domain/Entities/token_entity.dart';
import 'package:car_parking/features/auth/Domain/Entities/user_entity.dart';
import 'package:car_parking/features/auth/Domain/Repositories/auth_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });
  @override
  Future<Either<Failure, String>> signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await remoteDataSource.signup(
        password: password,
        email: email,
      );

      // التحقق من أن الرد ليس فارغاً
      if (response == null || response.isEmpty) {
        return Left(WrongDataFailure('فشل الحصول على التوكن من الخادم'));
      }

      await localDataSource.saveToken(response);
      return Right(response);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(OfflineFailure('لا يوجد اتصال بالإنترنت'));
      }

      // معالجة أخطاء الخادم المفصلة
      if (e.response != null && e.response!.data != null) {
        final errorMessage = e.response!.data['message'] ?? 'فشل التسجيل';
        return Left(ServerFailure('خطأ في الخادم: $errorMessage'));
      }

      return Left(ServerFailure('فشل التسجيل: ${e.message}'));
    } catch (e) {
      // معالجة جميع أنواع الأخطاء الأخرى
      return Left(WrongDataFailure('بيانات التسجيل غير صالحة: $e'));
    }
  }

  @override
  Future<Either<Failure, TokenEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      // استدعاء remoteDataSource.login
      final response = await remoteDataSource.login(
        email: email,
        password: password,
      );

      // حفظ قيمة الـ token في التخزين المحلي
      await localDataSource.saveToken(response.value);
      
      return Right(TokenEntity(
        id: /*"99",*/ response.id,
        value: /*"hiih",*/ response.value,
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(OfflineFailure('لا يوجد اتصال بالإنترنت'));
      }
      if (e.response?.statusCode == 401) {
        return Left(WrongDataFailure('بيانات الدخول غير صحيحة'));
      }
      return Left(ServerFailure('ف الدخول: ${e.message}'));
    } catch (e) {
      return Left(WrongDataFailure('خطأ في تسجيل الدخول: $e'));

    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await remoteDataSource.logout();
      await localDataSource.clearToken();
      return const Right(unit);
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.connectionError) {
        return Left(OfflineFailure('لا يوجد اتصال بالإنترنت'));
      }
      return Left(ServerFailure('فشل تسجيل الخروج: ${e.message}'));
    } catch (e) {
      return Left(ServerFailure('خطأ في تسجيل الخروج: $e'));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      final token = await localDataSource.getToken();

      if (token == null || token.isEmpty) {
        return Left(WrongDataFailure('Token غير موجود أو فارغ'));
      }

      final response = await remoteDataSource.getCurrentUser(token);

      return Right(UserEntity(
        id: response.id,
        email: response.email,
      ));
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout) {
        return Left(OfflineFailure('مهلة الاتصال انتهت'));
      } else if (e.type == DioExceptionType.connectionError) {
        return Left(OfflineFailure('خطأ في الاتصال بالخادم'));
      } else if (e.response?.statusCode == 401) {
        await localDataSource.clearToken();
        return Left(WrongDataFailure('انتهت صلاحية التوكن'));
      } else {
        return Left(ServerFailure('خطأ في الخادم: ${e.message}'));
      }
    } catch (e) {
      return Left(ServerFailure('خطأ غير متوقع: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> getToken() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) {
        return Left(WrongDataFailure('لا يوجد رمز متاح'));
      }
      return Right(token);
    } catch (e) {
      return Left(ServerFailure('خطأ في جلب الرمز: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteToken() async {
    try {
      await localDataSource.clearToken();
      return const Right(unit);
    } catch (e) {
      return Left(ServerFailure('خطأ في حذف الرمز: $e'));
    }
  }
}
