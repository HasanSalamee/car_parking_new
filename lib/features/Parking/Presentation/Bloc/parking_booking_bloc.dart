import 'package:bloc/bloc.dart';
import 'package:car_parking/features/Parking/Domain/Repositories/Bookind_Reposiory.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/CalculateBookingPriceUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/CancelBookingUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/ConfirmBookingUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/ExtendBookingTimeUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/GetUserBookingsUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/HandleEarlyLateArrivalUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/ReserveGarageUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/SearchAvailableGaragesUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/SearchAvailableGaragesUseCase1.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/SendBookingNotificationUseCase.dart';
import 'package:car_parking/features/Parking/Domain/Usecases/ValidateParkingAccessUseCase.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_event.dart';
import 'package:car_parking/features/Parking/Presentation/Bloc/parking_booking_state.dart';

class ParkingBookingBloc
    extends Bloc<ParkingBookingEvent, ParkingBookingState> {
  final ParkingBookingRepository repository;

  ParkingBookingBloc({required this.repository})
      : super(ParkingBookingInitial()) {
    // معالجة أحداث البحث
    on<SearchGaragesEvent>(_handleSearchGarages);
    on<SearchGaragesEvent1>(_handleSearchGarages1);

    on<CalculatePriceEvent>(_handleCalculatePrice);

    // معالجة أحداث الحجز
    on<ReserveGarageEvent>(_handleReserveGarage);
    on<ConfirmBookingEvent>(_handleConfirmBooking);
    on<CancelBookingEvent>(_handleCancelBooking);
    on<ExtendBookingEvent>(_handleExtendBooking);
    on<GetUserBookingsEvent>(_handleGetUserBookings);

    // معالجة أحداث التحقق
    on<ValidateParkingEvent>(_handleValidateParking);
    on<HandleEarlyArrivalEvent>(_handleEarlyArrival);
    on<SendNotificationEvent>(_handleSendNotification);
  }

  // 1. معالجة البحث عن مواقف
  Future<void> _handleSearchGarages(
    SearchGaragesEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await SearchAvailableGaragesUseCase(repository)(
      arrivalTime: event.arrivalTime,
      departureTime: event.departureTime,
      userLocation: event.userLocation,
      maxDistance: event.maxDistance,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (garages) => emit(GaragesLoadedState(
        garages: garages,
        userLocation: event.userLocation,
      )),
    );
  }

  // 1. معالجة البحث عن مواقف
  Future<void> _handleSearchGarages1(
    SearchGaragesEvent1 event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await SearchAvailableGaragesUseCase1(repository)(
      arrivalTime: event.arrivalTime,
      departureTime: event.departureTime,
      city: event.city,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (garages) => emit(GaragesLoadedState1(
        garages: garages,
        city: event.city,
      )),
    );
  }

  // 2. معالجة حساب السعر
  Future<void> _handleCalculatePrice(
    CalculatePriceEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await CalculateBookingPriceUseCase()(
      garage: event.garage,
      arrivalTime: event.arrivalTime,
      departureTime: event.departureTime,
    );

    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (totalPrice) => emit(PriceCalculatedState(
        totalPrice: totalPrice,
        basePrice: totalPrice / 1.15, // إذا كانت الضريبة 15%
        taxes: totalPrice * 0.15,
      )),
    );
  }

  // 3. معالجة حجز الموقف
  Future<void> _handleReserveGarage(
    ReserveGarageEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await ReserveGarageUseCase(repository)(
      garageId: event.garageId,
      userId: event.userId,
      startTime: event.startTime,
      endTime: event.endTime,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (booking) => emit(GarageReservedState(
        temporaryBooking: booking,
        validFor: const Duration(minutes: 15),
      )),
    );
  }

  // 4. معالجة تأكيد الحجز
  Future<void> _handleConfirmBooking(
    ConfirmBookingEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await ConfirmBookingUseCase(repository)(
      bookingId: event.bookingId,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (booking) => emit(BookingConfirmedState(
        confirmedBooking: booking,
      )),
    );
  }

  // 5. معالجة إلغاء الحجز
  Future<void> _handleCancelBooking(
    CancelBookingEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await CancelBookingUseCase(repository)(
      bookingId: event.bookingId,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (_) => emit(BookingCancelledState(
        bookingId: event.bookingId,
        refundAmount: null, // يتم تعبئته من الـ Repository
      )),
    );
  }

  // 6. معالجة تمديد الحجز
  Future<void> _handleExtendBooking(
    ExtendBookingEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await ExtendBookingUseCase(repository)(
      bookingId: event.bookingId,
      newEndTime: event.newEndTime,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (booking) => emit(BookingExtendedState(
        updatedBooking: booking,
      )),
    );
  }

  // 7. معالجة جلب حجوزات المستخدم
  Future<void> _handleGetUserBookings(
    GetUserBookingsEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result =
        await GetUserBookingsUseCase(repository)(userId: event.userId);

    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (bookings) {
        // التصنيف حسب الوقت الحالي
        final now = DateTime.now();
        final active = bookings.where((b) => b.end.isAfter(now)).toList();
        final past = bookings.where((b) => !b.end.isAfter(now)).toList();

        emit(UserBookingsLoadedState(
          activeBookings: active,
          pastBookings: past,
        ));
      },
    );
  }

  // 8. معالجة التحقق من صحة الحجز
  Future<void> _handleValidateParking(
    ValidateParkingEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await ValidateParkingUseCase(repository)(
      token: event.token,
      garageId: event.garageId,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (isValid) => emit(ParkingValidatedState(
        isValid: isValid,
        garageId: event.garageId,
      )),
    );
  }

  // 9. معالجة الوصول المبكر
  Future<void> _handleEarlyArrival(
    HandleEarlyArrivalEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await HandleEarlyArrivalUseCase(repository)(
      bookingId: event.bookingId,
      actualArrivalTime: event.actualArrivalTime,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (booking) => emit(EarlyArrivalHandledState(
        updatedBooking: booking,
        actualArrivalTime: event.actualArrivalTime,
      )),
    );
  }

  // 10. معالجة إرسال الإشعارات
  Future<void> _handleSendNotification(
    SendNotificationEvent event,
    Emitter<ParkingBookingState> emit,
  ) async {
    emit(ParkingBookingLoading());
    final result = await SendNotificationUseCase(repository)(
      userId: event.userId,
      message: event.message,
      notificationType: event.notificationType,
    );
    result.fold(
      (failure) => emit(ParkingBookingError(failure.message)),
      (_) => emit(NotificationSentState(
        userId: event.userId,
        notificationType: event.notificationType,
      )),
    );
  }
}
