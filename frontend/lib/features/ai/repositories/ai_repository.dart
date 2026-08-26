import 'package:frontend/features/ai/services/ai_service.dart';

class AiRepository {
  final AiService aiService;

  AiRepository(this.aiService);

  Future<AiChatResponse> chat({
    required String message,
    List<Map<String, String>>? conversationHistory,
  }) async {
    return await aiService.chat(
      message: message,
      conversationHistory: conversationHistory,
    );
  }
}
