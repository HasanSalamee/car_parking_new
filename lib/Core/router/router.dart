import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:car_parking/features/Parking/Presentation/Pages/HomePage.dart';
import 'package:car_parking/features/Parking/Presentation/Pages/ParkingSpotCard.dart';
import 'package:car_parking/features/auth/presentation/pages/login_screen.dart';
import 'package:car_parking/features/auth/presentation/pages/signuo_screen.dart';
import 'package:car_parking/features/payment/Domain/entity/transaction_entity.dart';
import 'package:car_parking/features/payment/presentation/pages/BookingDetailsScreen.dart';
import 'package:car_parking/features/payment/presentation/pages/PaymentConfirm.dart';
import 'package:car_parking/features/payment/presentation/pages/PaymentScreen.dart';
import 'package:car_parking/features/payment/presentation/pages/PaymentSuccessScreen.dart';
import 'package:car_parking/features/payment/presentation/pages/wallet.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String login = '/login';
  static const String home = '/home';
  static const String search = '/search';
  static const String bookingDetails = '/booking_details';
  static const String payment = '/payment';
  static const String paymentConfirmation = '/payment/confirmation';
  static const String paymentSuccess = '/payment/success';
  static const String signup = '/signup';
  static const String wallet = '/wallet';

  static const Duration routeTransitionDuration = Duration(milliseconds: 300);

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
      case login:
        return _fadeRoute(const LoginScreen(), settings);

      case home:
        return _fadeRoute(const HomeScreen(), settings);

      case search:
        final userId = settings.arguments as String;
        return _fadeRoute(SearchGaragesScreen(userId: userId), settings);

      case bookingDetails:
        if (args is Map<String, dynamic>) {
          return _slideRoute(
            BookingDetailsScreen(
              garage: args['garage'] as GarageEntity,
              arrivalTime: args['arrivalTime'] as DateTime,
              departureTime: args['departureTime'] as DateTime,
              userId: args['userId'] as String,
            ),
            settings,
          );
        }
        return _errorRoute();

      case payment:
        if (args is Map<String, dynamic>) {
          return _slideRoute(
            PaymentScreen(
              userId: args['userId'] as String,
              bookingId: args['bookingId'] as String,
              amount: args['amount'] as double,
              garageName: args['garageName'] as String,
            ),
            settings,
          );
        }
        return _errorRoute();
/*
      case paymentConfirmation:
        if (args is Map<String, dynamic>) {
          return _slideRoute(
            PaymentConfirmationScreen(
              userId: args['userId'] as String,
              bookingId: args['bookingId'] as String,
              amount: args['amount'] as double,
              garageName: args['garageName'] as String,
              paymentMethod: args['paymentMethod'] as String,
            ),
            settings,
          );
        }
        return _errorRoute();
*/
      case paymentSuccess:
        if (args is TransactionEntity) {
          return _fadeRoute(
            PaymentSuccessScreen(transaction: args),
            settings,
          );
        }
        return _errorRoute();

      case signup:
        return _fadeRoute(const SignUpScreen(), settings);

      case wallet:
        return MaterialPageRoute(
          builder: (_) => WalletScreen(),
          settings: settings,
        );

      default:
        return _errorRoute();
    }
  }

  static MaterialPageRoute _fadeRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
      fullscreenDialog: settings.name == signup,
    );
  }

  static MaterialPageRoute _slideRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(
      builder: (_) => page,
      settings: settings,
    );
  }

  static MaterialPageRoute _errorRoute() {
    return MaterialPageRoute(
      builder: (_) => const Scaffold(
        body: Center(child: Text('Route غير معروفة أو بيانات غير صالحة')),
      ),
    );
  }

  static Future<T?> push<T extends Object?>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) async {
    return await Navigator.pushNamed(
      context,
      routeName,
      arguments: arguments,
    );
  }

  static Future<void> pushToBookingDetails({
    required BuildContext context,
    required GarageEntity garage,
    required DateTime arrivalTime,
    required DateTime departureTime,
    required String userId,
  }) async {
    await push(
      context,
      bookingDetails,
      arguments: {
        'garage': garage,
        'arrivalTime': arrivalTime,
        'departureTime': departureTime,
        'userId': userId,
      },
    );
  }

  static Future<void> pushToPayment({
    required BuildContext context,
    required String bookingId,
    required double amount,
    required String garageName,
    required String userId,
  }) async {
    await push(
      context,
      payment,
      arguments: {
        'bookingId': bookingId,
        'amount': amount,
        'garageName': garageName,
        'userId': userId,
      },
    );
  }

  static Future<void> pushToPaymentConfirmation({
    required BuildContext context,
    required String userId,
    required String bookingId,
    required double amount,
    required String garageName,
    required String paymentMethod,
  }) async {
    await push(
      context,
      paymentConfirmation,
      arguments: {
        'userId': userId,
        'bookingId': bookingId,
        'amount': amount,
        'garageName': garageName,
        'paymentMethod': paymentMethod,
      },
    );
  }

  static Future<void> pushToWallet(BuildContext context) async {
    await push(context, wallet);
  }
}
