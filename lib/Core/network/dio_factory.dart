/*// lib/Core/network/dio_factory.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:dio/io.dart';

class DioFactory {
  Future<Dio> createDio() async {
    final dio = Dio();

    // تحميل شهادة SSL من مجلد assets
    final sslCert = await rootBundle.load('assets/certs/localhost.pem');

    // إعداد Dio لاستخدام الشهادة
    (dio.httpClientAdapter as IOHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
      final SecurityContext sc = SecurityContext(withTrustedRoots: false);
      sc.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());

      return HttpClient(context: sc)
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
    };

    //dio.options.baseUrl = 'http://localhost:3000';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 10);
    return dio;
  }
}

*/

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/io.dart';

class DioFactory {
  Future<Dio> createDio() async {
    final dio = Dio();

    dio.options.baseUrl = 'https://f3fb8850a641.ngrok-free.app/';
    dio.options.connectTimeout = const Duration(seconds: 5);
    dio.options.receiveTimeout = const Duration(seconds: 5);
    return dio;
  }
}
