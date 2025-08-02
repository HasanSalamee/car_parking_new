import 'package:car_parking/Core/errors/Failure.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:dartz/dartz.dart';

class CalculateBookingPriceUseCase {
  Future<Either<Failure, double>> call({
    required GarageEntity garage,
    required DateTime arrivalTime,
    required DateTime departureTime,
  }) async {
    // 1. التحقق من صحة المدخلات
    if (arrivalTime.isAfter(departureTime)) {
      return Left(InvalidTimeRangeFailure());
    }

    // 2. حساب المدة بالساعات
    final duration = departureTime.difference(arrivalTime);
    final hours = duration.inMinutes / 60.0; // دقة أكثر من .inHours

    // 3. حساب السعر الأساسي
    double basePrice = garage.pricePerHour * hours;

    // 4. تطبيق الضريبة (مثال: 15%)
    const taxRate = 0.15;
    final totalPrice = basePrice * (1 + taxRate);

    // 5. التقريب إلى منزلتين عشريتين
    final roundedPrice = double.parse(totalPrice.toStringAsFixed(2));

    return Right(roundedPrice);
  }
}
