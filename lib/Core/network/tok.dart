import 'package:dio/dio.dart'; // استيراد حزمة Dio
import 'package:car_parking/features/auth/Data/Datasources/auth_local.dart';

class HttpHeadersProvider {
  final AuthLocalDataSource authLocalDataSource;

  HttpHeadersProvider({required this.authLocalDataSource});

  Future<Map<String, dynamic>> getAuthHeaders() async {
    final token = await authLocalDataSource.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // دالة إضافية للحصول على كائن Options المطلوب في Dio
  Future<Options> getDioOptions() async {
    final headers = await getAuthHeaders();
    return Options(headers: headers);
  }
}


