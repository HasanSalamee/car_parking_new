import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:car_parking/Core/router/router.dart';
import 'package:car_parking/features/Parking/Domain/Entities/booking_entity.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_bloc.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_event.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_state.dart';
import 'package:car_parking/features/auth/Domain/Entities/user_entity.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_bloc.dart';
import 'package:car_parking/features/auth/Presentation/Bloc/auth_event.dart'; // تأكد من استيراد الأحداث
import 'package:car_parking/features/auth/Presentation/Bloc/auth_state.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userId;
  bool _isLoadingUser = true;

  @override
  void initState() {
    super.initState();
    // إرسال حدث للحصول على المستخدم الحالي
    context.read<AuthBloc>().add(GetCurrentUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // الاستماع لتغيرات حالة المصادقة
        BlocListener<AuthBloc, AuthState>(
          listener: (context, authState) {
            if (authState is AuthSuccess) {
              if (authState.data is UserEntity) {
                final user = authState.data as UserEntity;
                setState(() {
                  _userId = user.id;
                  _isLoadingUser = false;
                });
                // جلب حجوزات المستخدم بمجرد الحصول على الـ user ID
                context.read<ParkingBookingBloc>().add(GetUserBookingsEvent(
                    userId:
                        "d778efd8-a33c-4206-ad6d-bc1621f9a835" /* user.id*/));
              } else {
                print('بيانات المصادقة ليست من نوع UserEntity');
                setState(() => _isLoadingUser = false);
              }
            } else if (authState is AuthFailure) {
              setState(() => _isLoadingUser = false);
              Future.microtask(() {
                //  Navigator.pushReplacementNamed(context, '/login');
              });
            } else if (authState is AuthLoading) {
              setState(() => _isLoadingUser = true);
            }
          },
        ),

        // الاستماع لتغيرات حالة الحجوزات
        BlocListener<ParkingBookingBloc, ParkingBookingState>(
          listener: (context, bookingState) {
            // يمكنك إضافة معالجات إضافية هنا إذا لزم الأمر
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'مرحبًا بك في مواقف السيارات',
            style:
                TextStyle(fontWeight: FontWeight.bold, fontSize: 18, shadows: [
              Shadow(
                blurRadius: 2.0,
                color: Colors.black12,
                offset: Offset(1.0, 1.0),
              )
            ]),
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon:
                  const Icon(Icons.account_balance_wallet, color: Colors.white),
              tooltip: 'محفظتي',
              onPressed: () {
                if (_userId != null) {
                  Navigator.pushNamed(
                    context,
                    AppRouter.wallet,
                    arguments: _userId,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('لم يتم تحديد المستخدم'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              tooltip: 'تسجيل الخروج',
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
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
          child: _isLoadingUser
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // كرت البحث عن موقف
                      Card(
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
                              children: [
                                Icon(
                                  Icons.directions_car,
                                  size: 50,
                                  color: Colors.blue.shade700,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'ابحث عن موقف سيارات',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.indigo,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.blue.shade700,
                                        Colors.indigo.shade700
                                      ],
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
                                  child: InkWell(
                                    onTap: () {
                                      // … بالسطر الآتي:
                                      Navigator.pushNamed(
                                        context,
                                        AppRouter.search,
                                        arguments: _userId, // ✅ يمرِّر userId
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(12),
                                    child: const Center(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.search,
                                              color: Colors.white),
                                          SizedBox(width: 8),
                                          Text(
                                            'ابحث الآن',
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // عنوان قسم الحجوزات
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.indigo.shade50,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.bookmark,
                                  color: Colors.indigo, size: 24),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'حجوزاتك الحالية',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.indigo,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),

                      // قسم الحجوزات الحالية
                      Expanded(
                        child: BlocBuilder<ParkingBookingBloc,
                            ParkingBookingState>(
                          builder: (context, state) {
                            if (state is ParkingBookingLoading) {
                              return const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.indigo),
                                ),
                              );
                            } else if (state is UserBookingsLoadedState) {
                              final activeBookings = state.activeBookings;

                              if (activeBookings.isEmpty) {
                                return _buildNoBookingsCard();
                              }

                              return ListView.builder(
                                itemCount: activeBookings.length,
                                itemBuilder: (context, index) {
                                  final booking = activeBookings[index];
                                  return Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 16.0),
                                    child: _buildBookingCard(booking, index),
                                  );
                                },
                              );
                            } else if (state is ParkingBookingError) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.error_outline,
                                        color: Colors.red.shade700, size: 48),
                                    const SizedBox(height: 16),
                                    Text(
                                      'حدث خطأ: ${state.error}',
                                      style: TextStyle(
                                          color: Colors.red.shade700,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 20),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_userId != null) {
                                          context
                                              .read<ParkingBookingBloc>()
                                              .add(GetUserBookingsEvent(
                                                  userId: /*_userId!*/
                                                      "d778efd8-a33c-4206-ad6d-bc1621f9a835"));
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.indigo,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24, vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        elevation: 3,
                                        shadowColor: Colors.indigo.shade300,
                                      ),
                                      child: const Text('إعادة المحاولة',
                                          style:
                                              TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                ),
                              );
                            } else {
                              return _buildNoBookingsCard();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  // بناء بطاقة الحجز
  Widget _buildBookingCard(BookingEntity booking, int index) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300 + (index * 100)),
      curve: Curves.easeOut,
      transform: Matrix4.translationValues(0, index == 0 ? 0 : 20, 0)
        ..scale(1.0),
      child: Card(
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        shadowColor: Colors.blue.shade100,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade50],
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.local_parking,
                          size: 24, color: Colors.blue),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'موقف: ${booking.garageId ?? "غير محدد"}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                _buildBookingDetailRow(
                  icon: Icons.calendar_today,
                  text:
                      'من: ${DateFormat('yyyy/MM/dd - hh:mm a').format(booking.start)}',
                ),
                const SizedBox(height: 8),
                _buildBookingDetailRow(
                  icon: Icons.calendar_today,
                  text:
                      'إلى: ${DateFormat('yyyy/MM/dd - hh:mm a').format(booking.end)}',
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // زر إلغاء الحجز
                    _buildActionButton(
                      text: 'إلغاء الحجز',
                      icon: Icons.cancel,
                      color: Colors.red,
                      onPressed: () {
                        context
                            .read<ParkingBookingBloc>()
                            .add(CancelBookingEvent(bookingId: booking.id!));
                      },
                    ),
                    const SizedBox(width: 12),
                    // زر تمديد الحجز
                    _buildActionButton(
                      text: 'تمديد الحجز',
                      icon: Icons.timer,
                      color: Colors.green,
                      onPressed: () {
                        // وظيفة التمديد
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // صف تفاصيل الحجز
  Widget _buildBookingDetailRow(
      {required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Text(
          text,
          style: TextStyle(fontSize: 15, color: Colors.grey.shade800),
        ),
      ],
    );
  }

  // زر الإجراءات
  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          colors: [color.withOpacity(0.9), color],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 6,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(10),
          splashColor: Colors.white.withOpacity(0.3),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // بناء بطاقة عدم وجود حجوزات
  Widget _buildNoBookingsCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: const Padding(
          padding: EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 60, color: Colors.blueGrey),
                SizedBox(height: 20),
                Text(
                  'لا يوجد حجوزات حالية',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'استخدم زر "ابحث الآن" لحجز موقف جديد',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
