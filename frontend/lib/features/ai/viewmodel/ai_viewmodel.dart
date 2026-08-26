import 'package:frontend/features/ai/models/ai_message.dart';
import 'package:frontend/features/ai/repositories/ai_repository.dart';
import 'package:get/get.dart';

class AiViewmodel extends GetxController {
  final AiRepository aiRepository;

  AiViewmodel(this.aiRepository);

  final RxList<AiMessage> messages = <AiMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = AiMessage(
      content: text.trim(),
      role: MessageRole.user,
    );
    messages.add(userMessage);

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final history = messages
          .take(messages.length - 1)
          .map((m) => m.toChatJson())
          .toList();

      final response = await aiRepository.chat(
        message: text.trim(),
        conversationHistory: history,
      );

      final recommendations = response.recommendations
          .map((r) => BusRecommendation.fromJson(r))
          .toList();

      final assistantMessage = AiMessage(
        content: response.reply,
        role: MessageRole.assistant,
        recommendations: recommendations,
      );
      messages.add(assistantMessage);
    } catch (e) {
      errorMessage.value = 'Failed to get response. Please try again.';
      final errorReply = AiMessage(
        content: 'Sorry, something went wrong. Please try again.',
        role: MessageRole.assistant,
      );
      messages.add(errorReply);
    } finally {
      isLoading.value = false;
    }
  }

  void clearChat() {
    messages.clear();
    errorMessage.value = '';
  }
}
