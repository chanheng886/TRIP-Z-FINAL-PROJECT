import 'package:frontend/shared/model/booking_request.dart';
import 'package:frontend/shared/model/booking_response.dart';
import 'package:frontend/shared/model/seat_map.dart';
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

  Future<void> loadSeatMap(int busScheduleId, {String? busType}) async {
    try {
      isLoadingSeats.value = true;
      seatMapError.value = "";
      final result = await busScheduleRepository.getSeatMap(busScheduleId);

      // Check if busType specifies a seat count (e.g. "25 Seats Bus" -> 25)
      int expectedCapacity = 0;
      if (busType != null) {
        final match = RegExp(r'(\d+)\s*seat', caseSensitive: false).firstMatch(busType);
        if (match != null) {
          expectedCapacity = int.tryParse(match.group(1)!) ?? 0;
        }
      }

      if (expectedCapacity == 25 && result.allSeats.length < 25) {
        final List<String> fullSeats = [];
        for (int r = 0; r < 7; r++) {
          final row = String.fromCharCode(65 + r); // A..G
          fullSeats.add('${row}1');
          fullSeats.add('${row}2');
          fullSeats.add('${row}3');
        }
        // Rear bench: 4 seats (H1, H2, H3, H4)
        fullSeats.add('H1');
        fullSeats.add('H2');
        fullSeats.add('H3');
        fullSeats.add('H4');

        seatMap.value = SeatMap(
          busScheduleId: result.busScheduleId,
          allSeats: fullSeats,
          bookedSeats: result.bookedSeats,
        );
      } else if (expectedCapacity > 0 && result.allSeats.length < expectedCapacity) {
        final List<String> fullSeats = [];
        const int seatsPerRow = 4;
        for (int i = 0; i < expectedCapacity; i++) {
          final row = String.fromCharCode(65 + (i ~/ seatsPerRow));
          final col = (i % seatsPerRow) + 1;
          fullSeats.add('$row$col');
        }
        seatMap.value = SeatMap(
          busScheduleId: result.busScheduleId,
          allSeats: fullSeats,
          bookedSeats: result.bookedSeats,
        );
      } else {
        seatMap.value = result;
      }
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
