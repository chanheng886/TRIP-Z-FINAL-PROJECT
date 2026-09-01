import 'dart:convert';
import 'package:frontend/shared/service/base_url.dart';
import 'package:http/http.dart' as http;

class AiChatResponse {
  final String reply;
  final List<Map<String, dynamic>> recommendations;

  AiChatResponse({required this.reply, required this.recommendations});

  factory AiChatResponse.fromJson(Map<String, dynamic> json) {
    return AiChatResponse(
      reply: json['reply'] ?? '',
      recommendations: (json['recommendations'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }
}

class AiService {
  final String baseUrl = BaseUrl.ai;

  Future<AiChatResponse> chat({
    required String message,
    List<Map<String, String>>? conversationHistory,
  }) async {
    try {
      final body = <String, dynamic>{
        'message': message,
      };

      if (conversationHistory != null && conversationHistory.isNotEmpty) {
        body['conversationHistory'] = conversationHistory;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AiChatResponse.fromJson(data);
      } else {
        throw Exception('Failed to get AI response');
      }
    } catch (e) {
      rethrow;
    }
  }
}
