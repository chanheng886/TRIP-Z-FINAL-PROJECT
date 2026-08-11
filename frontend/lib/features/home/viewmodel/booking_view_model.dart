import 'package:frontend/features/home/models/booking_request.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/features/home/models/seat_map.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:frontend/features/home/repository/bus_schedule_repository.dart';
import 'package:get/get.dart';

class BookingViewmodel extends GetxController {
  final BusScheduleRepository busScheduleRepository;
  final BookingRepository bookingRepository;

  BookingViewmodel(this.busScheduleRepository, this.bookingRepository);

  final RxBool isLoadingSeats = false.obs;
  final RxString seatMapError = "".obs;
  final Rx<SeatMap?> seatMap = Rx<SeatMap?>(null);

  final RxList<String> selectedSeats = <String>[].obs;

  final RxBool isSubmitting = false.obs;
  final RxString submitError = "".obs;
  final Rx<BookingResponse?> bookingResult = Rx<BookingResponse?>(null);

  Future<void> loadSeatMap(int busScheduleId) async {
    try {
      isLoadingSeats.value = true;
      seatMapError.value = "";
      final result = await busScheduleRepository.getSeatMap(busScheduleId);
      seatMap.value = result;
    } catch (e) {
      seatMapError.value = e.toString();
    } finally {
      isLoadingSeats.value = false;
    }
  }

  void toggleSeat(String seat) {
    if (seatMap.value == null) return;
    if (seatMap.value!.isBooked(seat)) return; // can't select taken seats

    if (selectedSeats.contains(seat)) {
      selectedSeats.remove(seat);
    } else {
      selectedSeats.add(seat);
    }
  }

  Future<bool> submitBooking(BookingRequest request) async {
    try {
      isSubmitting.value = true;
      submitError.value = "";
      final result = await bookingRepository.createBooking(request);
      bookingResult.value = result;
      return true;
    } catch (e) {
      submitError.value = e.toString();
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }
}
