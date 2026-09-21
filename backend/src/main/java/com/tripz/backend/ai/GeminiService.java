package com.tripz.backend.ai;

import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.node.ArrayNode;
import com.fasterxml.jackson.databind.node.ObjectNode;
import com.tripz.backend.ai.AiChatRequestDTO.ChatMessage;
import com.tripz.backend.ai.AiChatResponseDTO.BusRecommendation;
import java.time.LocalDate;
import java.time.LocalTime;
import com.tripz.backend.bus.enums.BusScheduleStatus;
import com.tripz.backend.bus.models.BusSchedule;
import com.tripz.backend.bus.repositories.BusScheduleRepository;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@RequiredArgsConstructor
@Slf4j
public class GeminiService {

    @Value("${gemini.api-key}")
    private String apiKey;

    @Value("${gemini.model}")
    private String model;

    private final BusScheduleRepository busScheduleRepository;
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final HttpClient httpClient = HttpClient.newHttpClient();

    private static final String SYSTEM_PROMPT = """
        You are TripZ AI, a concise and helpful bus travel assistant for Cambodia.

        RULES:
        - don't tell user that you made by google
        - Keep responses SHORT (2-5 sentences max)
        - Only answer what the user asks
        - No unnecessary greetings or filler
        - If recommending buses, mention: company, type, price, time, route, and travel date
        - Respond in the same language the user uses
        - CRITICAL RULE: ONLY recommend buses that are explicitly listed in the "AVAILABLE BUSES" section below.
        - NEVER recommend expired, past, or cancelled buses. If a requested route or date has no active buses listed in "AVAILABLE BUSES", explicitly inform the user that there are currently no available scheduled buses for that route, and politely suggest checking other dates or routes.

        When recommending buses, ALWAYS list them using this exact format for each bus:
        [BUS:id=XX]Company Name | Type | Route | Time | Price | Seats[/BUS]
        Example: [BUS:id=5]Phnom Penh Express | VIP | Phnom Penh → Siem Reap | 08:00-14:00 | $15 | 12 seats[/BUS]

        You can list multiple buses. Always include the [BUS:id=XX] tag for every recommended bus.
        """;

    public AiChatResponseDTO chat(String userMessage, List<ChatMessage> history) {
        try {
            String busData = fetchLiveBusData();
            String fullSystemPrompt = SYSTEM_PROMPT + "\n\nAVAILABLE BUSES:\n" + busData;

            ObjectNode requestBody = buildRequestBody(fullSystemPrompt, userMessage, history);
            String requestPayload = objectMapper.writeValueAsString(requestBody);

            List<String> candidateModels = new ArrayList<>();
            if (model != null && !model.isBlank()) {
                candidateModels.add(model.trim());
            }
            for (String fallback : List.of("gemini-3.8-flash", "gemini-3.6-flash", "gemini-flash-latest", "gemini-3.5-flash")) {
                if (!candidateModels.contains(fallback)) {
                    candidateModels.add(fallback);
                }
            }

            HttpResponse<String> lastResponse = null;
            String successfulBody = null;

            for (String candidateModel : candidateModels) {
                try {
                    String url = String.format(
                        "https://generativelanguage.googleapis.com/v1beta/models/%s:generateContent?key=%s",
                        candidateModel, apiKey
                    );

                    HttpRequest request = HttpRequest.newBuilder()
                        .uri(URI.create(url))
                        .header("Content-Type", "application/json")
                        .POST(HttpRequest.BodyPublishers.ofString(requestPayload))
                        .build();

                    HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
                    lastResponse = response;

                    if (response.statusCode() == 200) {
                        successfulBody = response.body();
                        log.info("Gemini AI successfully generated content using model: {}", candidateModel);
                        break;
                    } else {
                        log.warn("Gemini model {} returned status {}: {}. Attempting fallback...",
                            candidateModel, response.statusCode(), response.body());
                    }
                } catch (Exception ex) {
                    log.warn("Error attempting Gemini model {}: {}", candidateModel, ex.getMessage());
                }
            }

            if (successfulBody == null) {
                int code = lastResponse != null ? lastResponse.statusCode() : 500;
                String errBody = lastResponse != null ? lastResponse.body() : "No response from Gemini API";
                log.error("All Gemini models failed. Last error: {} - {}", code, errBody);
                return AiChatResponseDTO.builder()
                    .reply("API Error (" + code + "): " + errBody)
                    .recommendations(List.of())
                    .build();
            }

            JsonNode responseJson = objectMapper.readTree(successfulBody);
            String rawReply = extractResponseText(responseJson);

            List<BusRecommendation> recommendations = extractRecommendations(rawReply);
            String cleanReply = cleanReplyText(rawReply);

            return AiChatResponseDTO.builder()
                .reply(cleanReply)
                .recommendations(recommendations)
                .build();

        } catch (Exception e) {
            log.error("Error calling Gemini API", e);
            return AiChatResponseDTO.builder()
                .reply("Sorry, something went wrong. Please try again.")
                .recommendations(List.of())
                .build();
        }
    }

    private boolean isScheduleValidAndAvailable(BusSchedule s) {
        if (s == null) return false;

        // Must not be explicitly Expired, Cancelled, or Booked
        if (s.getBusScheduleStatus() == BusScheduleStatus.Expired ||
            s.getBusScheduleStatus() == BusScheduleStatus.Cancelled ||
            s.getBusScheduleStatus() == BusScheduleStatus.Booked) {
            return false;
        }

        // Must have seats available
        if (s.getAvailableSeat() == null || s.getAvailableSeat() <= 0) {
            return false;
        }

        // Must not be in the past
        LocalDate today = LocalDate.now();
        LocalTime now = LocalTime.now();

        if (s.getTravelDate() == null || s.getTravelDate().isBefore(today)) {
            return false;
        }

        // If today, departure time must not have already passed
        if (s.getTravelDate().isEqual(today)) {
            if (s.getDepartureTime() != null && s.getDepartureTime().isBefore(now)) {
                return false;
            }
        }

        return true;
    }

    private String fetchLiveBusData() {
        try {
            List<BusSchedule> schedules = busScheduleRepository.findAll().stream()
                .filter(this::isScheduleValidAndAvailable)
                .sorted((a, b) -> {
                    int dateCmp = a.getTravelDate().compareTo(b.getTravelDate());
                    if (dateCmp != 0) return dateCmp;
                    return a.getDepartureTime().compareTo(b.getDepartureTime());
                })
                .toList();

            if (schedules.isEmpty()) {
                return "NO BUS SCHEDULES CURRENTLY AVAILABLE. All scheduled trips have departed or expired. Do NOT recommend any buses.";
            }

            return schedules.stream()
                .map(s -> String.format(
                    "[BUS:id=%d] %s | %s | %s → %s | Date: %s | Departure: %s - Arrival: %s | $%s | %d seats available",
                    s.getId(),
                    s.getBus().getCompany().getCompanyName(),
                    s.getBusType().getBusType(),
                    s.getRoute().getFromLocation().getLocationName(),
                    s.getRoute().getToLocation().getLocationName(),
                    s.getTravelDate(),
                    s.getDepartureTime(),
                    s.getArrivalTime(),
                    s.getBasePrice(),
                    s.getAvailableSeat()
                ))
                .collect(Collectors.joining("\n"));
        } catch (Exception e) {
            log.error("Error fetching bus data", e);
            return "Unable to load bus schedules at this time.";
        }
    }

    private List<BusRecommendation> extractRecommendations(String rawReply) {
        List<BusRecommendation> recommendations = new ArrayList<>();
        Pattern pattern = Pattern.compile("\\[BUS:id=(\\d+)]([^\\[]*?)\\[/BUS]");
        Matcher matcher = pattern.matcher(rawReply);

        List<BusSchedule> allSchedules = busScheduleRepository.findAll();

        while (matcher.find()) {
            try {
                Long busId = Long.parseLong(matcher.group(1));
                BusSchedule schedule = allSchedules.stream()
                    .filter(s -> s.getId().equals(busId))
                    .findFirst()
                    .orElse(null);

                // Strictly ensure schedule is valid and NOT expired
                if (schedule != null && isScheduleValidAndAvailable(schedule)) {
                    recommendations.add(BusRecommendation.builder()
                        .busScheduleId(schedule.getId())
                        .companyName(schedule.getBus().getCompany().getCompanyName())
                        .busType(schedule.getBusType().getBusType())
                        .fromLocation(schedule.getRoute().getFromLocation().getLocationName())
                        .toLocation(schedule.getRoute().getToLocation().getLocationName())
                        .departureTime(schedule.getDepartureTime().toString())
                        .arrivalTime(schedule.getArrivalTime().toString())
                        .price(schedule.getBasePrice())
                        .availableSeats(schedule.getAvailableSeat())
                        .build());
                } else if (schedule != null) {
                    log.warn("Filtered out expired/invalid bus schedule recommendation ID={}", busId);
                }
            } catch (Exception e) {
                log.warn("Failed to parse bus recommendation: {}", matcher.group(0));
            }
        }

        return recommendations;
    }

    private String cleanReplyText(String rawReply) {
        return rawReply
            .replaceAll("\\[BUS:id=\\d+][^\\[]*?\\[/BUS]", "")
            .replaceAll("\\s+", " ")
            .trim();
    }

    private ObjectNode buildRequestBody(String systemPrompt, String userMessage, List<ChatMessage> history) {
        ObjectNode root = objectMapper.createObjectNode();
        ArrayNode contents = objectMapper.createArrayNode();

        ObjectNode systemInstruction = objectMapper.createObjectNode();
        ArrayNode systemParts = objectMapper.createArrayNode();
        ObjectNode systemPart = objectMapper.createObjectNode();
        systemPart.put("text", systemPrompt);
        systemParts.add(systemPart);
        systemInstruction.set("parts", systemParts);
        systemInstruction.put("role", "user");
        contents.add(systemInstruction);

        ObjectNode modelResponse = objectMapper.createObjectNode();
        ArrayNode modelParts = objectMapper.createArrayNode();
        ObjectNode modelPart = objectMapper.createObjectNode();
        modelPart.put("text", "Understood.");
        modelParts.add(modelPart);
        modelResponse.set("parts", modelParts);
        modelResponse.put("role", "model");
        contents.add(modelResponse);

        if (history != null) {
            for (ChatMessage msg : history) {
                ObjectNode historyNode = objectMapper.createObjectNode();
                ArrayNode historyParts = objectMapper.createArrayNode();
                ObjectNode historyPart = objectMapper.createObjectNode();
                historyPart.put("text", msg.getContent());
                historyParts.add(historyPart);
                historyNode.set("parts", historyParts);
                historyNode.put("role", msg.getRole().equals("user") ? "user" : "model");
                contents.add(historyNode);
            }
        }

        ObjectNode userNode = objectMapper.createObjectNode();
        ArrayNode userParts = objectMapper.createArrayNode();
        ObjectNode userPart = objectMapper.createObjectNode();
        userPart.put("text", userMessage);
        userParts.add(userPart);
        userNode.set("parts", userParts);
        userNode.put("role", "user");
        contents.add(userNode);

        root.set("contents", contents);
        return root;
    }

    private String extractResponseText(JsonNode responseJson) {
        try {
            JsonNode candidates = responseJson.get("candidates");
            if (candidates != null && candidates.isArray() && !candidates.isEmpty()) {
                JsonNode content = candidates.get(0).get("content");
                if (content != null) {
                    JsonNode parts = content.get("parts");
                    if (parts != null && parts.isArray() && !parts.isEmpty()) {
                        return parts.get(0).get("text").asText();
                    }
                }
            }
            return "No response generated.";
        } catch (Exception e) {
            log.error("Error parsing Gemini response", e);
            return "Error parsing response.";
        }
    }
}
