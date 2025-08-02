import 'dart:ui';
import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/Parking/Domain/Entities/garage_entity.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_bloc.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_event.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BookingDetailsScreen extends StatelessWidget {
  final GarageEntity garage;
  final DateTime arrivalTime;
  final DateTime departureTime;
  final String userId;

  const BookingDetailsScreen({
    super.key,
    required this.garage,
    required this.arrivalTime,
    required this.departureTime,
    required this.userId,
  });

  @override
  Widget build(BuildContext context) {
    final totalHours = departureTime.difference(arrivalTime).inHours;
    final totalAmount = garage.pricePerHour * totalHours;

    return Scaffold(
      appBar: AppBar(
        title: Text('تفاصيل الحجز - ${garage.name}'),
        centerTitle: true,
      ),
      body: BlocListener<ParkingBookingBloc, ParkingBookingState>(
        listener: (context, state) {
          if (state is GarageReservedState) {
            // تم الحجز بنجاح → ننتقل للدفع
            AppRouter.pushToPayment(
              context: context,
              bookingId: state.temporaryBooking.id,
              amount: totalAmount.toDouble(),
              garageName: garage.name,
              userId: userId,
            );
          } else if (state is ParkingBookingError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGarageInfo(),
              const SizedBox(height: 20),
              _buildTimeInfo(totalHours),
              const SizedBox(height: 20),
              _buildPaymentSummary(totalAmount.toDouble()),
              const Spacer(),
              _buildBookButton(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGarageInfo() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              garage.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "${garage.location.latitude.toStringAsFixed(5)}, ${garage.location.longitude.toStringAsFixed(5)}",
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              'السعة: ${garage.capacity} مركبات',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeInfo(int totalHours) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'تفاصيل الوقت',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            const SizedBox(height: 8),
            _buildTimeRow('الوصول:', arrivalTime),
            const SizedBox(height: 12),
            _buildTimeRow('المغادرة:', departureTime),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('المدة:', style: TextStyle(fontSize: 16)),
                Text(
                  '$totalHours ساعة',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Text(
          DateFormat('yyyy-MM-dd HH:mm').format(time),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(double totalAmount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ملخص الدفع',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('سعر الساعة:', style: TextStyle(fontSize: 16)),
                Text(
                  '${garage.pricePerHour} ر.س',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(thickness: 1),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المبلغ الإجمالي:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  '$totalAmount ر.س',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: () {
          context.read<ParkingBookingBloc>().add(
                ReserveGarageEvent(
                  garageId: garage.id,
                  userId: userId, // ← عيّن الـ user الحقيقي هنا
                  startTime: arrivalTime,
                  endTime: departureTime,
                ),
              );
        },
        child: const Text(
          'انتقل للدفع',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
