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
        title: Text(
          'تفاصيل الحجز - ${garage.name}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.indigo.shade900],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: const [0.2, 0.8],
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(0, 4),
              )
            ],
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Color(0xFFE6F0FF)],
          ),
        ),
        child: BlocListener<ParkingBookingBloc, ParkingBookingState>(
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
      ),
    );
  }

  Widget _buildGarageInfo() {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.blue.shade200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.local_parking,
                      color: Colors.blue,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          garage.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${garage.location.latitude.toStringAsFixed(5)}, ${garage.location.longitude.toStringAsFixed(5)}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.car_rental, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'السعة: ${garage.capacity} مركبات',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeInfo(int totalHours) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.blue.shade200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, color: Colors.blue, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'تفاصيل الوقت',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1, height: 20),
              const SizedBox(height: 8),
              _buildTimeRow('الوصول:', arrivalTime),
              const SizedBox(height: 12),
              _buildTimeRow('المغادرة:', departureTime),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المدة:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  Text(
                    '$totalHours ساعة',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeRow(String label, DateTime time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
        Text(
          DateFormat('yyyy-MM-dd HH:mm').format(time),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(double totalAmount) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      shadowColor: Colors.blue.shade200,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.attach_money, color: Colors.blue, size: 24),
                  SizedBox(width: 10),
                  Text(
                    'ملخص الدفع',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 1, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('سعر الساعة:',
                      style: TextStyle(fontSize: 16, color: Colors.grey)),
                  Text(
                    '${garage.pricePerHour} ر.س',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'المبلغ الإجمالي:',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
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
      ),
    );
  }

  Widget _buildBookButton(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.indigo.shade700],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade300,
            blurRadius: 8,
            spreadRadius: 1,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {
            context.read<ParkingBookingBloc>().add(
                  ReserveGarageEvent(
                    garageId: garage.id,
                    userId: userId, // ← عيّن الـ user الحقيقي هنا
                    startTime: arrivalTime,
                    endTime: departureTime,
                  ),
                );
          },
          borderRadius: BorderRadius.circular(12),
          splashColor: Colors.white.withOpacity(0.3),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: const Center(
              child: Text(
                'انتقل للدفع',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
