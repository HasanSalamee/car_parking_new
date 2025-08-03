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
    return '${ticket.id}|${ticket.token}|${ticket.bookingId}|'
        '${ticket.userId}|'
        '${ticket.validFrom.toIso8601String()}|'
        '${ticket.validTo.toIso8601String()}|'
        '${ticket.isUsed}';
  }

  NfcTicket _deserializeTicket(String data) {
    final parts = data.split('|');
    return NfcTicket(
      id: parts[0],
      token: parts[1],
      bookingId: parts[2],
      userId: parts[3],
      validFrom: DateTime.parse(parts[4]),
      validTo: DateTime.parse(parts[5]),
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
