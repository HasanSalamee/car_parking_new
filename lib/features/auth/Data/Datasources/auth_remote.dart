import 'package:car_parking/Core/network/tok.dart';
import 'package:car_parking/features/auth/Data/Models/token_model.dart';
import 'package:car_parking/features/auth/Data/Models/user_model.dart';
import 'package:dio/dio.dart';

abstract class AuthRemoteDataSource {
  Future<String> signup({
    required String email,
    required String password,
  });

  Future<TokenModel> login({
    required String email,
    required String password,
  });

  Future<void> logout();

  Future<UserModel> getCurrentUser(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;
  final HttpHeadersProvider headersProvider;

  AuthRemoteDataSourceImpl(this.dio, this.headersProvider);

  @override
  Future<String> signup({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        "api/Auth/register",
        data: {
          'email': email,
          'password': password,
          'confirmPassword': password,
          'role': 'Customer',
        },
      );

      if (response.statusCode == 200) {
        return response.data; // التغيير: استخراج التوكن من JSON
      } else {
        throw Exception('فشل التسجيل: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('خطأ في الشبكة أثناء التسجيل: ${e.message}');
    }
  }

  

  @override
  Future<TokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await dio.post(
        'api/Auth/login',
        data: {
          'email': email,
          'password': password,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode == 200) {
        return TokenModel.fromJson(
            response.data); // التغيير: تحويل JSON إلى TokenModel
      } else {
        throw Exception(
            'فشل تسجيل الدخول: ${response.data?['message'] ?? 'خطأ غير معروف'}');
      }
    } on DioException catch (e) {
      throw Exception('خطأ في الشبكة أثناء تسجيل الدخول: ${e.message}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final response = await dio.post('api/Auth/logout');
      if (response.statusCode != 200) {
        throw Exception('فشل تسجيل الخروج');
      }
    } on DioException catch (e) {
      throw Exception('خطأ في الشبكة أثناء تسجيل الخروج: ${e.message}');
    }
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    final headers = await headersProvider.getAuthHeaders();

    try {
      print(token);
      final response = await dio.get(
        "api/Auth/me",
        options: Options(headers: headers),
      );
      print(response);

      if (response.statusCode == 200) {
        return UserModel.fromJson(
            response.data); // التغيير: تحويل JSON إلى UserModel
      } else {
        throw Exception('فشل جلب بيانات المستخدم');
      }
    } on DioException catch (e) {
      throw Exception('خطأ في الشبكة أثناء جلب بيانات المستخدم: ${e.message}');
    }
  }
}
