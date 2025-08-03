import 'package:car_parking/Core/network/tok.dart';
import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/Core/network/dio_factory.dart';
import 'package:car_parking/features/Parking/Data/Datasources/Booking_remotly.dart';
import 'package:car_parking/features/Parking/Data/Repositories/Booking_rep.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_bloc.dart';
import 'package:car_parking/features/auth/Data/Datasources/auth_local.dart';
import 'package:car_parking/features/auth/Data/Datasources/auth_remote.dart';
import 'package:car_parking/features/auth/Data/Repositories/auth_repositore_impl.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_bloc.dart';
import 'package:car_parking/features/nfc_gate/data/datasources/nfc_local_datasource.dart';
import 'package:car_parking/features/nfc_gate/data/datasources/nfc_remote_datasource.dart';
import 'package:car_parking/features/nfc_gate/data/repositories/nfc_repository_impl.dart';
import 'package:car_parking/features/nfc_gate/presentation/bloc/nfc_bloc.dart';
import 'package:car_parking/features/payment/Data/repository/Payment_repository_impl.dart';
import 'package:car_parking/features/payment/data/datasources/payment_local_datasource.dart';
import 'package:car_parking/features/payment/data/datasources/payment_remote_datasource.dart';
import 'package:car_parking/features/payment/presentation/bolc/payment_bloc.dart';
import 'package:car_parking/logger.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logging/logging.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  initRootLogger();

  final dioFactory = DioFactory();
  final dio = await dioFactory.createDio();

  runApp(MyApp(dio: dio));
}

class MyApp extends StatelessWidget {
  static final _log = Logger('SiteInfo');
  final Dio? dio;

  const MyApp({super.key, this.dio});

  @override
  Widget build(BuildContext context) {
    final Dio _dio = dio ?? Dio();
    const storage = FlutterSecureStorage();

    // إنشاء مصادر البيانات المحلية أولاً
    final authLocalDataSource = AuthLocalDataSourceImpl(storage);

    // إنشاء HttpHeadersProvider
    final httpHeadersProvider =
        HttpHeadersProvider(authLocalDataSource: authLocalDataSource);

    // auth
    final authRemoteDataSource = AuthRemoteDataSourceImpl(
      _dio,
      httpHeadersProvider,
    );
    final authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
    );

    // payment
    final paymentLocalDataSource = PaymentLocalDataSourceImpl(storage: storage);
    final paymentRemoteDataSource =
        PaymentRemoteDataSourceImpl(_dio, httpHeadersProvider);
    final paymentRepository = PaymentRepositoryImpl(
      remoteDataSource: paymentRemoteDataSource,
      localDataSource: paymentLocalDataSource,
    );

    // booking
    final bookingRemoteDataSource =
        ParkingRemoteDataSourceImpl(_dio, httpHeadersProvider);
    final bookingRepository =
        BookingParkingRepositoryImpl(bookingRemoteDataSource);

    // NFC
    final nfcRemoteDataSource = NfcRemoteDatasource(dio: _dio);
    final nfcLocalDataSource = NfcLocalDatasource(storage: storage);
    final nfcRepository = NfcRepositoryImpl(
      remoteDatasource: nfcRemoteDataSource,
      localDatasource: nfcLocalDataSource,
    );

    _log.info("✅ Application started");

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: authRepository),
        ),
        BlocProvider<ParkingBookingBloc>(
          create: (context) =>
              ParkingBookingBloc(repository: bookingRepository),
        ),
        BlocProvider<PaymentWalletBloc>(
          create: (context) => PaymentWalletBloc(repository: paymentRepository),
        ),
        BlocProvider<NfcBloc>(
          create: (context) => NfcBloc(nfcRepository),
        ),
      ],
      child: MaterialApp(
        title: 'Car Parking',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: AppRouter.login,
        onGenerateRoute: AppRouter.generateRoute,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
