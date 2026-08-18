import 'package:frontend/features/home/models/booking_request.dart';
import 'package:frontend/features/home/models/booking_response.dart';
import 'package:frontend/shared/services/booking_service.dart';

class BookingRepository {
  final BookingService bookingService;

  BookingRepository(this.bookingService);

  Future<BookingResponse> createBooking(BookingRequest request) async {
    final json = await bookingService.createBooking(request.toJson());
    return BookingResponse.fromJson(json);
  }

  Future<List<BookingResponse>> getUserBookings(int userId) async {
    final list = await bookingService.getBookingsByUserId(userId);
    return list.map((json) => BookingResponse.fromJson(json)).toList();
  }
}
