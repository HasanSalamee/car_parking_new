// lib/features/nfc_gate/data/datasources/nfc_remote_datasource.dart
import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:dio/dio.dart';

class NfcRemoteDatasource {
  final Dio dio;

  NfcRemoteDatasource({
    required this.dio,
  });

  Future<NfcTicket> fetchTicketFromServer({
    required String bookingId,
  }) async {
    try {
      final response = await dio.post(
        '/tickets/generate',
        data: {
          'booking_id': bookingId,
        },
        options: Options(
          contentType: Headers.jsonContentType,
          responseType: ResponseType.json,
        ),
      );

      return _parseTicketResponse(response.data);
    } on DioException catch (e) {
      throw ServerException(
          message:
              'فشل في توليد التذكرة: ${e.response?.statusCode} - ${e.message}');
    }
  }

  Future<bool> validateTicket(String ticketId) async {
    try {
      final response = await dio.get(
        '/tickets/validate/$ticketId',
        options: Options(
          responseType: ResponseType.json,
        ),
      );

      return response.data['is_valid'] as bool;
    } on DioException catch (e) {
      throw ServerException(
          message:
              'فشل في التحقق من التذكرة: ${e.response?.statusCode} - ${e.message}');
    }
  }

  Future<void> reportTicketUsage(String ticketId) async {
    try {
      await dio.post(
        '/tickets/report-usage',
        data: {'ticket_id': ticketId},
        options: Options(
          contentType: Headers.jsonContentType,
        ),
      );
    } on DioException catch (e) {
      throw ServerException(
          message:
              'فشل في تسجيل استخدام التذكرة: ${e.response?.statusCode} - ${e.message}');
    }
  }

  NfcTicket _parseTicketResponse(Map<String, dynamic> data) {
    return NfcTicket(
      tokenId: data['tokenId'],
      tokenValue: data['tokenValue'],
      bookingId: data['bookingId'],
      userId: data['userId'],
      tokenValidFrom: DateTime.parse(data['tokenValidFrom'] as String),
      tokenValidTo: DateTime.parse(data['tokenValidTo'] as String),
      isUsed: data['isUsed'] ?? false,
    );
  }
}
