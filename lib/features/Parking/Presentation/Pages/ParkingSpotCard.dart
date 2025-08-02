import 'dart:async';
import 'dart:convert';

import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_bloc.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_event.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_state.dart';
import 'package:car_parking/features/payment/presentation/pages/BookingDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as dio;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class SearchGaragesScreen extends StatefulWidget {
  final String userId;

  const SearchGaragesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SearchGaragesScreen> createState() => _SearchGaragesScreenState();
}

class _SearchGaragesScreenState extends State<SearchGaragesScreen> {
  DateTime? arrivalTime;
  DateTime? departureTime;
  LatLng userLocation = const LatLng(0, 0);
  bool _isLocationLoading = false;
  String? _locationError;
  String? _currentCity;
  final Map<LatLng, String> _addressCache = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
      _currentCity = null;
    });

    try {
      // جلب الإحداثيات
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 15));

      // محاولة التحويل مع حلول بديلة
      await _convertCoordinatesWithFallback(
          position.latitude, position.longitude);
    } on TimeoutException {
      setState(
          () => _locationError = "استجابة بطيئة. جرب في مكان به إشارة أفضل");
    } catch (e) {
      setState(() => _locationError = "خطأ فني: ${e.toString()}");
    } finally {
      setState(() => _isLocationLoading = false);
    }
  }

  Future<void> _convertCoordinatesWithFallback(double lat, double lng) async {
    try {
      // المحاولة الأولى: استخدام geocoding
      List<Placemark> placemarks =
          await placemarkFromCoordinates(lat, lng, localeIdentifier: 'ar')
              .timeout(const Duration(seconds: 10));

      if (placemarks.isNotEmpty) {
        _updateLocationData(lat, lng, placemarks.first);
        return;
      }
    } catch (e) {
      print("المحاولة الأولى فشلت: $e");
    }

    try {
      // المحاولة الثانية: استخدام OpenStreetMap API
      final response = await dio.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&accept-language=ar'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _updateLocationData(
          lat,
          lng,
          Placemark(
            locality: data['address']['city'] ?? data['address']['town'],
            administrativeArea: data['address']['state'],
            country: data['address']['country'],
          ),
        );
        return;
      }
    } catch (e) {
      print("المحاولة الثانية فشلت: $e");
    }

    // الحل البديل النهائي
    _updateLocationData(lat, lng, null);
  }

  void _updateLocationData(double lat, double lng, Placemark? place) {
    setState(() {
      userLocation = LatLng(lat, lng);
      _currentCity = place != null
          ? "${place.locality ?? place.administrativeArea ?? 'موقع غير معروف'}"
          : "الإحداثيات: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    });
  }

  Widget _buildLocationStatus() {
    if (_isLocationLoading) {
      return const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
      );
    } else if (_locationError != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.location_off, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    _locationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _getCurrentLocation,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Text("إعادة المحاولة", style: TextStyle(fontSize: 12)),
          ),
        ],
      );
    } else if (_currentCity != null) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.location_on, color: Colors.green, size: 20),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                "المدينة: $_currentCity",
                style: const TextStyle(color: Colors.green, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_searching, color: Colors.blue, size: 20),
            SizedBox(width: 4),
            Text("جاري تحديد الموقع",
                style: TextStyle(color: Colors.blue, fontSize: 12)),
          ],
        ),
      );
    }
  }

  Future<String> _getAddressFromLatLng(LatLng location) async {
    if (_addressCache.containsKey(location)) {
      return _addressCache[location]!;
    }

    try {
      final placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
        localeIdentifier: 'ar',
      );

      if (placemarks.isEmpty) return "عنوان غير معروف";

      final Placemark place = placemarks[0];
      final address = _formatAddress(place);

      _addressCache[location] = address;
      return address;
    } catch (e) {
      print("خطأ في تحويل الإحداثيات: $e");
      return "عنوان غير متاح";
    }
  }

  String _formatAddress(Placemark place) {
    final parts = [
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea
    ].where((part) => part != null && part!.isNotEmpty).toList();

    return parts.join('، ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "البحث عن موقف سيارات",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _getCurrentLocation,
            tooltip: "تحديث الموقع",
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF5F9FF), Color(0xFFE6F0FF)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Card(
                elevation: 5,
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
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        _buildDateTimePicker(
                          title: "وقت الوصول",
                          icon: Icons.login,
                          dateTime: arrivalTime,
                          onTap: _pickArrivalTime,
                        ),
                        const Divider(height: 20, thickness: 1),
                        _buildDateTimePicker(
                          title: "وقت المغادرة",
                          icon: Icons.logout,
                          dateTime: departureTime,
                          onTap: _pickDepartureTime,
                        ),
                        const SizedBox(height: 10),
                        _buildLocationStatus(),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Colors.blue, Colors.indigo],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.shade300,
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: _searchGarages,
                    borderRadius: BorderRadius.circular(12),
                    splashColor: Colors.white.withOpacity(0.3),
                    child: Container(
                      width: double.infinity,
                      height: 50,
                      alignment: Alignment.center,
                      child: const Text(
                        "ابحث عن مواقف متاحة",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
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
                      child: const Icon(Icons.list,
                          color: Colors.indigo, size: 24),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      "النتائج",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                flex: 1,
                child: BlocBuilder<ParkingBookingBloc, ParkingBookingState>(
                  builder: (context, state) {
                    if (state is ParkingBookingLoading) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const CircularProgressIndicator(
                              strokeWidth: 3,
                              color: Colors.indigo,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "جاري البحث عن المواقف المتاحة...",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.indigo.shade700,
                              ),
                            ),
                          ],
                        ),
                      );
                    } else if (state is GaragesLoadedState1) {
                      if (state.garages.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.local_parking,
                                  size: 60, color: Colors.grey.shade400),
                              const SizedBox(height: 16),
                              const Text(
                                "لا توجد مواقف متاحة في الوقت المحدد",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "جرب تغيير أوقات البحث",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: state.garages.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 8),
                        itemBuilder: (context, index) {
                          final garage = state.garages[index];
                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOut,
                            transform: Matrix4.translationValues(
                                0, index == 0 ? 0 : 20, 0),
                            child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.only(bottom: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: FutureBuilder<String>(
                                future: _getAddressFromLatLng(garage.location),
                                builder: (context, snapshot) {
                                  String addressText;

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    addressText = "جاري جلب العنوان...";
                                  } else if (snapshot.hasError) {
                                    addressText = "عنوان غير متاح";
                                  } else {
                                    addressText = snapshot.data!;
                                  }

                                  return InkWell(
                                    onTap: () {
                                      if (arrivalTime != null &&
                                          departureTime != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                BookingDetailsScreen(
                                              garage: garage,
                                              arrivalTime: arrivalTime!,
                                              departureTime: departureTime!,
                                              userId: widget.userId,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    borderRadius: BorderRadius.circular(16),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 50,
                                            height: 50,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Icon(
                                              Icons.local_parking,
                                              color: Colors.blue,
                                              size: 30,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  garage.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.indigo,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.car_rental,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "السعة: ${garage.capacity}",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.attach_money,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      "السعر: ${garage.pricePerHour} ريال/ساعة",
                                                      style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.location_on,
                                                        size: 14,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        addressText,
                                                        style: const TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.grey,
                                                        ),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          const Icon(Icons.chevron_right,
                                              color: Colors.blue),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    } else if (state is ParkingBookingError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.error_outline,
                                  size: 50, color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              state.error,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.red.shade700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<ParkingBookingBloc>().add(
                                        SearchGaragesEvent1(
                                          arrivalTime: arrivalTime!,
                                          departureTime: departureTime!,
                                          city: _currentCity!,
                                        ),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text("إعادة المحاولة"),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.search,
                                  size: 50, color: Colors.blue.shade700),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "حدد أوقات البحث ثم اضغط على زر البحث",
                              style: TextStyle(
                                  fontSize: 16, color: Colors.blueGrey),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimePicker({
    required String title,
    required IconData icon,
    required DateTime? dateTime,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
      ),
      subtitle: Text(
        dateTime != null
            ? DateFormat('yyyy/MM/dd - hh:mm a').format(dateTime)
            : "اضغط لتحديد الوقت",
        style: TextStyle(
          color: dateTime != null ? Colors.grey.shade800 : Colors.grey,
          fontWeight: dateTime != null ? FontWeight.w500 : FontWeight.normal,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.edit_calendar, color: Colors.blue, size: 20),
      ),
      onTap: onTap,
    );
  }

  Future<void> _pickArrivalTime() async {
    final picked = await _showDateTimePicker();
    if (picked != null) setState(() => arrivalTime = picked);
  }

  Future<void> _pickDepartureTime() async {
    final picked = await _showDateTimePicker();
    if (picked != null) setState(() => departureTime = picked);
  }

  Future<DateTime?> _showDateTimePicker() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(minutes: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogBackgroundColor: Colors.white,
          ),
          child: child!,
        );
      },
    );
    if (date == null) return null;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  void _searchGarages() {
    if (arrivalTime == null || departureTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("يرجى تحديد أوقات الوصول والمغادرة"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.red.shade400,
          margin: const EdgeInsets.all(20),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    if (_locationError != null || _currentCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_locationError ?? "تعذر تحديد المدينة"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(20),
        ),
      );
      return;
    }

    context.read<ParkingBookingBloc>().add(
          SearchGaragesEvent1(
            arrivalTime: arrivalTime!,
            departureTime: departureTime!,
            city: _currentCity!,
          ),
        );
  }
}
