package com.tripz.backend.bus.utils;
import java.util.ArrayList;
import java.util.List;

public class SeatLabelGenerator {
        private static final int SEATS_PER_ROW = 4;
    public static List<String> generateSeats(long totalSeats) {
        List<String> seats = new ArrayList<>();
        for (int i = 0; i < totalSeats; i++) {
            int row = i / SEATS_PER_ROW;
            int col = (i % SEATS_PER_ROW) + 1;
            char rowLetter = (char) ('A' + row);
            seats.add("" + rowLetter + col);
        }
        return seats;
    }
}