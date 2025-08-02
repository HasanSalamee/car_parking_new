import 'package:flutter_secure_storage/flutter_secure_storage.dart'
    show FlutterSecureStorage;

abstract class PaymentLocalDataSource {
  Future<double> getWalletBalanceForDisplay(String userId);

  Future<void> cacheWalletBalance(String userId, double balance);
}

class PaymentLocalDataSourceImpl implements PaymentLocalDataSource {
  final FlutterSecureStorage storage;
  static const _balanceKey = 'wallet_balance_display_';

  PaymentLocalDataSourceImpl({required this.storage});

  @override
  Future<double> getWalletBalanceForDisplay(String userId) async {
    final key = '$_balanceKey$userId';
    final value = await storage.read(key: key);
    return double.tryParse(value ?? '') ?? 0.0;
  }

  @override
  Future<void> cacheWalletBalance(String userId, double balance) async {
    final key = '$_balanceKey$userId';
    await storage.write(key: key, value: balance.toString());
  }
}
