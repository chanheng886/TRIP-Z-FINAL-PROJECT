package com.tripz.backend.bus.utils;
import java.util.ArrayList;
import java.util.List;

public class SeatLabelGenerator {
    public static List<String> generateSeats(long totalSeats) {
        List<String> seats = new ArrayList<>();
        if (totalSeats == 25) {
            // 7 rows of 2 on Left + 1 on Right = 21 seats (A1..A3 to G1..G3)
            for (int r = 0; r < 7; r++) {
                char rowLetter = (char) ('A' + r);
                seats.add("" + rowLetter + "1");
                seats.add("" + rowLetter + "2");
                seats.add("" + rowLetter + "3");
            }
            // Rear bench near luggage: 4 seats (H1, H2, H3, H4)
            seats.add("H1");
            seats.add("H2");
            seats.add("H3");
            seats.add("H4");
            return seats;
        }

        int seatsPerRow = 4;
        for (int i = 0; i < totalSeats; i++) {
            int row = i / seatsPerRow;
            int col = (i % seatsPerRow) + 1;
            char rowLetter = (char) ('A' + row);
            seats.add("" + rowLetter + col);
        }
        return seats;
    }
}