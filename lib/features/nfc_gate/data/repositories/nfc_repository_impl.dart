import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/nfc_gate/data/datasources/nfc_local_datasource.dart';
import 'package:car_parking/features/nfc_gate/data/datasources/nfc_remote_datasource.dart';
import 'package:car_parking/features/nfc_gate/domain/entities/nfs_ticket.dart';
import 'package:car_parking/features/nfc_gate/domain/repositories/nfc_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_nfc_kit/flutter_nfc_kit.dart';
import 'dart:convert';

import 'package:ndef/records/well_known/text.dart';

class NfcRepositoryImpl implements NfcRepository {
  final NfcRemoteDatasource remoteDatasource;
  final NfcLocalDatasource localDatasource;

  NfcRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
  });

  @override
  Future<Either<Failure, NfcTicket>> generateTicket({
    required String bookingId,
  }) async {
    try {
      final ticket = await remoteDatasource.fetchTicketFromServer(
        bookingId: bookingId,
      );

      await localDatasource.cacheTicket(ticket);

      return Right(ticket);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'خطأ في الشبكة',
        statusCode: e.response?.statusCode,
      ));
    } catch (e, stackTrace) {
      return Left(UnknownFailure.fromError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> writeTicketToNfc(NfcTicket ticket) async {
    try {
      final cachedTicket = await localDatasource.getCachedTicket();
      if (cachedTicket == null) {
        return Left(NfcFailure(message: 'لا توجد تذكرة مخزنة'));
      }

      final ticketData = _serializeTicket(cachedTicket);

      await FlutterNfcKit.poll();

      final record = TextRecord(text: ticketData);
      final records = [record];

      await FlutterNfcKit.writeNDEFRecords(records);

      await FlutterNfcKit.finish(iosAlertMessage: 'تمت كتابة التذكرة بنجاح');

      return const Right(null);
    } on PlatformException catch (e) {
      return Left(NfcFailure(message: 'خطأ في NFC: ${e.message}'));
    } catch (e, stackTrace) {
      return Left(NfcFailure(message: 'فشل الكتابة: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> sendTicketViaBluetooth(String ticket) async {
    try {
      final cachedTicket = await localDatasource.getCachedTicket();
      if (cachedTicket == null) {
        return Left(NfcFailure(message: 'لا توجد تذكرة مخزنة'));
      }

      final ticketData = _serializeTicket(cachedTicket);
      final encodedData = utf8.encode(ticketData);

      final isBluetoothEnabled = await FlutterBluePlus.isOn;
      if (!isBluetoothEnabled) {
        return Left(NfcFailure(message: 'Bluetooth غير مفعل'));
      }

      await FlutterBluePlus.startScan(timeout: const Duration(seconds: 4));
      final scanResult = await FlutterBluePlus.scanResults.firstWhere(
        (results) => results.isNotEmpty,
        orElse: () => throw Exception('لم يتم العثور على أجهزة'),
      );
      await FlutterBluePlus.stopScan();

      final device = scanResult.first.device;
      await device.connect(timeout: const Duration(seconds: 10));

      final services = await device.discoverServices();
      BluetoothCharacteristic? writableChar;

      for (var service in services) {
        for (var characteristic in service.characteristics) {
          if (characteristic.properties.write) {
            writableChar = characteristic;
            break;
          }
        }
        if (writableChar != null) break;
      }

      if (writableChar == null) {
        await device.disconnect();
        throw Exception('لم يتم العثور على خاصية قابلة للكتابة');
      }

      await writableChar.write(encodedData, withoutResponse: true);
      await device.disconnect();

      return const Right(unit);
    } on PlatformException catch (e) {
      return Left(NfcFailure(message: 'خطأ في Bluetooth: ${e.message}'));
    } catch (e) {
      return Left(
          NfcFailure(message: 'خطأ في إرسال التذكرة عبر Bluetooth: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> validateAccess(NfcTicket ticket) async {
    try {
      if (!ticket.isValid) {
        return const Right(false);
      }

      final isValid = await remoteDatasource.validateTicket(ticket.tokenId);

      if (isValid) {
        ticket.markAsUsed();
        await localDatasource.cacheTicket(ticket);
        await remoteDatasource.reportTicketUsage(ticket.tokenId);
      }

      return Right(isValid);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } on DioException catch (e) {
      return Left(NetworkFailure(
        message1: e.message ?? 'خطأ في الشبكة',
        statusCode: e.response?.statusCode,
      ));
    } catch (e, stackTrace) {
      return Left(UnknownFailure.fromError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, NfcTicket?>> getCachedTicket() async {
    try {
      final ticket = await localDatasource.getCachedTicket();
      return Right(ticket);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      return Left(UnknownFailure.fromError(e, stackTrace));
    }
  }

  @override
  Future<Either<Failure, void>> clearCachedTicket() async {
    try {
      await localDatasource.clearCachedTicket();
      return const Right(null);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    } catch (e, stackTrace) {
      return Left(UnknownFailure.fromError(e, stackTrace));
    }
  }

  String _serializeTicket(NfcTicket ticket) {
    return '${ticket.tokenId}|${ticket.tokenValue}|${ticket.bookingId}|'
        '${ticket.userId}|'
        '${ticket.tokenValidFrom.toIso8601String()}|'
        '${ticket.tokenValidTo.toIso8601String()}|'
        '${ticket.isUsed}';
  }
}
