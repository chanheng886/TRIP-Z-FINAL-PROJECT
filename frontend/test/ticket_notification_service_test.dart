import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/shared/service/ticket_notification_service.dart';

void main() {
  group('TicketNotificationService Departure Time Parsing & Math', () {
    test('parses HH:mm and HH:mm:ss departure times correctly', () {
      final travelDate = DateTime(2026, 9, 22);

      final dt1 = TicketNotificationService.parseDepartureDateTime(
          travelDate, '14:30');
      expect(dt1, isNotNull);
      expect(dt1!.hour, 14);
      expect(dt1.minute, 30);
      expect(dt1.day, 22);

      final dt2 = TicketNotificationService.parseDepartureDateTime(
          travelDate, '08:15:45');
      expect(dt2, isNotNull);
      expect(dt2!.hour, 8);
      expect(dt2.minute, 15);
      expect(dt2.day, 22);
    });

    test('correctly identifies 15-30 min remaining threshold', () {
      final now = DateTime(2026, 9, 22, 14, 0);

      // 25 minutes left (inside 15-30 min window)
      final dep25 = DateTime(2026, 9, 22, 14, 25);
      final diff25 = dep25.difference(now).inMinutes;
      expect(diff25 >= 0 && diff25 <= 30, isTrue);

      // 15 minutes left (inside window)
      final dep15 = DateTime(2026, 9, 22, 14, 15);
      final diff15 = dep15.difference(now).inMinutes;
      expect(diff15 >= 0 && diff15 <= 30, isTrue);

      // 45 minutes left (outside window)
      final dep45 = DateTime(2026, 9, 22, 14, 45);
      final diff45 = dep45.difference(now).inMinutes;
      expect(diff45 >= 0 && diff45 <= 30, isFalse);

      // Trip already passed (-5 mins, outside window)
      final depPast = DateTime(2026, 9, 22, 13, 55);
      final diffPast = depPast.difference(now).inMinutes;
      expect(diffPast >= 0 && diffPast <= 30, isFalse);
    });
  });
}
