import 'dart:async';
import 'dart:convert';

import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_bloc.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_event.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_state.dart';
import 'package:car_parking/features/Parking/Presentation/Pages/BookingDetailsScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as dio;
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlong;

class LocationPickerScreen extends StatefulWidget {
  final latlong.LatLng? initialLocation;

  const LocationPickerScreen({Key? key, this.initialLocation})
      : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  latlong.LatLng? _selectedLocation;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('اختر موقعًا'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center:
                  _selectedLocation ?? const latlong.LatLng(24.7136, 46.6753),
              zoom: 12.0,
              onTap: (tapPosition, point) {
                setState(() {
                  _selectedLocation = point;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.car_parking',
              ),
              MarkerLayer(
                markers: _selectedLocation != null
                    ? [
                        Marker(
                          point: _selectedLocation!,
                          width: 50,
                          height: 50,
                          builder: (ctx) => const Icon(
                            Icons.location_pin,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ]
                    : [],
              ),
            ],
          ),
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'ابحث عن عنوان...',
                        border: InputBorder.none,
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: _searchLocation,
                        ),
                      ),
                      onSubmitted: (value) => _searchLocation(),
                    ),
                  ),
                  if (_isSearching)
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_selectedLocation != null) {
                    Navigator.pop(context, _selectedLocation);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("يرجى تحديد موقع على الخريطة"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check),
                label:
                    const Text('تأكيد الموقع', style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: Colors.blue,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Future<void> _searchLocation() async {
    if (_searchController.text.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      List<Location> locations =
          await locationFromAddress(_searchController.text);
      if (locations.isNotEmpty) {
        latlong.LatLng newLocation =
            latlong.LatLng(locations.first.latitude, locations.first.longitude);
        setState(() {
          _selectedLocation = newLocation;
        });
        _mapController.move(newLocation, 15);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على العنوان')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء البحث: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('خدمة الموقع غير مفعلة')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('تم رفض إذن الموقع')),
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('يجب تفعيل إذن الموقع من الإعدادات')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      latlong.LatLng currentLocation =
          latlong.LatLng(position.latitude, position.longitude);
      setState(() {
        _selectedLocation = currentLocation;
      });
      _mapController.move(currentLocation, 15);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('فشل الحصول على الموقع الحالي: ${e.toString()}')),
      );
    }
  }
}

class SearchGaragesScreen extends StatefulWidget {
  final String userId;

  const SearchGaragesScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<SearchGaragesScreen> createState() => _SearchGaragesScreenState();
}

class _SearchGaragesScreenState extends State<SearchGaragesScreen> {
  DateTime? arrivalTime;
  DateTime? departureTime;
  latlong.LatLng? _selectedLocation;
  String? _selectedCity;
  bool _isLocationLoading = false;
  String? _locationError;
  final Map<latlong.LatLng, String> _addressCache = {};

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
      _selectedCity = null;
    });

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = "خدمة الموقع غير مفعلة";
          _isLocationLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationError = "تم رفض إذن الموقع";
            _isLocationLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = "يجب تفعيل إذن الموقع من الإعدادات";
          _isLocationLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      ).timeout(const Duration(seconds: 15));

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
            locality: data['address']['city'] ??
                data['address']['town'] ??
                data['address']['village'],
            administrativeArea:
                data['address']['state'] ?? data['address']['county'],
            country: data['address']['country'],
          ),
        );
        return;
      }
    } catch (e) {
      print("المحاولة الثانية فشلت: $e");
    }

    _updateLocationData(lat, lng, null);
  }

  void _updateLocationData(double lat, double lng, Placemark? place) {
    setState(() {
      _selectedLocation = latlong.LatLng(lat, lng);
      _selectedCity = place != null
          ? "${place.locality ?? place.administrativeArea ?? 'موقع غير معروف'}"
          : "الإحداثيات: ${lat.toStringAsFixed(4)}, ${lng.toStringAsFixed(4)}";
    });
  }

  Future<void> _selectLocationManually() async {
    final latlong.LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            LocationPickerScreen(initialLocation: _selectedLocation),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedLocation = result;
        _isLocationLoading = true;
      });

      try {
        await _convertCoordinatesWithFallback(
            result.latitude, result.longitude);
      } catch (e) {
        setState(() => _locationError = "خطأ في تحديد الموقع: ${e.toString()}");
      } finally {
        setState(() => _isLocationLoading = false);
      }
    }
  }

  Widget _buildLocationStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_isLocationLoading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            ),
          )
        else if (_locationError != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_off, color: Colors.red, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _locationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 14),
                  ),
                ),
              ],
            ),
          )
        else if (_selectedCity != null && _selectedLocation != null)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.green, size: 24),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "الموقع: $_selectedCity",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "الإحداثيات: ${_selectedLocation!.latitude.toStringAsFixed(5)}, ${_selectedLocation!.longitude.toStringAsFixed(5)}",
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_searching,
                    color: Colors.blue, size: 24),
                const SizedBox(width: 10),
                const Text(
                  "جاري تحديد الموقع",
                  style: TextStyle(color: Colors.blue, fontSize: 14),
                ),
              ],
            ),
          ),
        const SizedBox(height: 15),
        ElevatedButton.icon(
          onPressed: _selectLocationManually,
          icon: const Icon(Icons.map),
          label: const Text("اختر موقعًا يدويًا على الخريطة"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade800,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Future<String> _getAddressFromLatLng(latlong.LatLng location) async {
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
                    padding: const EdgeInsets.all(16.0),
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
                        const SizedBox(height: 20),
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
                      height: 55,
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
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.list,
                          color: Colors.indigo, size: 26),
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
                            const SizedBox(height: 20),
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
                                  size: 70, color: Colors.grey.shade400),
                              const SizedBox(height: 20),
                              const Text(
                                "لا توجد مواقف متاحة في الوقت المحدد",
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "جرب تغيير أوقات البحث أو موقع البحث",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        itemCount: state.garages.length,
                        separatorBuilder: (context, index) => const Divider(
                            height: 12, indent: 20, endIndent: 20),
                        itemBuilder: (context, index) {
                          final garage = state.garages[index];

                          // حل مشكلة نوع LatLng بالتحويل
                          final locationForAddress = latlong.LatLng(
                            garage.location.latitude,
                            garage.location.longitude,
                          );

                          return AnimatedContainer(
                            duration:
                                Duration(milliseconds: 300 + (index * 100)),
                            curve: Curves.easeOut,
                            transform: Matrix4.translationValues(
                                0, index == 0 ? 0 : 20, 0),
                            child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: FutureBuilder<String>(
                                future:
                                    _getAddressFromLatLng(locationForAddress),
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
                                            width: 60,
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade50,
                                              borderRadius:
                                                  BorderRadius.circular(15),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  garage.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 17,
                                                    color: Colors.indigo,
                                                  ),
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  children: [
                                                    const Icon(Icons.car_rental,
                                                        size: 16,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "السعة: ${garage.capacity}",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.attach_money,
                                                        size: 16,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "السعر: ${garage.pricePerHour} ريال/ساعة",
                                                      style: const TextStyle(
                                                          fontSize: 14,
                                                          color: Colors.grey),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                        Icons.location_on,
                                                        size: 16,
                                                        color: Colors.grey),
                                                    const SizedBox(width: 6),
                                                    Flexible(
                                                      child: Text(
                                                        addressText,
                                                        style: const TextStyle(
                                                          fontSize: 14,
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
                                              color: Colors.blue, size: 30),
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
                                  size: 60, color: Colors.red.shade700),
                            ),
                            const SizedBox(height: 20),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Text(
                                state.error,
                                style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.red.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 25),
                            ElevatedButton(
                              onPressed: () =>
                                  context.read<ParkingBookingBloc>().add(
                                        SearchGaragesEvent1(
                                          arrivalTime: arrivalTime!,
                                          departureTime: departureTime!,
                                          city: _selectedCity!,
                                        ),
                                      ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15),
                                ),
                              ),
                              child: const Text("إعادة المحاولة",
                                  style: TextStyle(fontSize: 16)),
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
                                  size: 60, color: Colors.blue.shade700),
                            ),
                            const SizedBox(height: 25),
                            const Text(
                              "حدد أوقات البحث ثم اضغط على زر البحث",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.blueGrey,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 30),
                              child: Text(
                                "يمكنك أيضًا تحديد موقع البحث يدويًا باستخدام الخريطة",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey.shade600,
                                ),
                                textAlign: TextAlign.center,
                              ),
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
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.blue, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16),
      ),
      subtitle: Text(
        dateTime != null
            ? DateFormat('yyyy/MM/dd - hh:mm a').format(dateTime)
            : "اضغط لتحديد الوقت",
        style: TextStyle(
          color: dateTime != null ? Colors.grey.shade800 : Colors.grey,
          fontWeight: dateTime != null ? FontWeight.w500 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.edit_calendar, color: Colors.blue, size: 24),
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
          duration: const Duration(seconds: 3),
        ),
      );
      return;
    }

    if (_selectedLocation == null || _selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("يرجى تحديد موقع البحث"),
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
            city: _selectedCity!,
          ),
        );
  }
}
