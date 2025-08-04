// lib/features/nfc_gate/data/datasources/nfc_local_datasource.dart
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class NfcLocalDatasource {
  final FlutterSecureStorage _storage;
  static const String _ticketKey = 'cached_nfc_ticket';

  NfcLocalDatasource({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> cacheTicket(NfcTicket ticket) async {
    await _storage.write(
      key: _ticketKey,
      value: _serializeTicket(ticket),
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  Future<NfcTicket?> getCachedTicket() async {
    final data = await _storage.read(
      key: _ticketKey,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );

    if (data == null) return null;
    return _deserializeTicket(data);
  }

  Future<void> clearCachedTicket() async {
    await _storage.delete(
      key: _ticketKey,
      aOptions: _getAndroidOptions(),
      iOptions: _getIOSOptions(),
    );
  }

  String _serializeTicket(NfcTicket ticket) {
    return '${ticket.tokenId}|${ticket.tokenValue}|${ticket.bookingId}|'
        '${ticket.userId}|'
        '${ticket.tokenValidFrom.toIso8601String()}|'
        '${ticket.tokenValidTo.toIso8601String()}|'
        '${ticket.isUsed}';
  }

  NfcTicket _deserializeTicket(String data) {
    final parts = data.split('|');
    return NfcTicket(
      tokenId: parts[0],
      tokenValue: parts[1],
      bookingId: parts[2],
      userId: parts[3],
      tokenValidFrom: DateTime.parse(parts[4]),
      tokenValidTo: DateTime.parse(parts[5]),
      isUsed: parts[6] == 'true',
    );
  }

  AndroidOptions _getAndroidOptions() => const AndroidOptions(
        encryptedSharedPreferences: true,
      );

  IOSOptions _getIOSOptions() => const IOSOptions(
        accessibility: KeychainAccessibility.passcode,
      );
}
