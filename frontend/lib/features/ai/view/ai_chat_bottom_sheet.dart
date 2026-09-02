import 'package:flutter/material.dart';
import 'package:frontend/features/ai/model/ai_message.dart';
import 'package:frontend/features/ai/repository/ai_repository.dart';
import 'package:frontend/features/ai/service/ai_service.dart';
import 'package:frontend/features/ai/viewmodel/ai_viewmodel.dart';
import 'package:frontend/features/ai/widgets/ai_chat_header.dart';
import 'package:frontend/features/ai/widgets/ai_chat_input_field.dart';
import 'package:frontend/features/ai/widgets/ai_chat_typing_indicator.dart';
import 'package:frontend/features/ai/widgets/ai_chat_welcome_view.dart';
import 'package:frontend/features/ai/widgets/chat_bubble.dart';
import 'package:frontend/features/home/view/pages/seat_selection_screen.dart';
import 'package:get/get.dart';

class AiChatBottomSheet extends StatefulWidget {
  const AiChatBottomSheet({super.key});

  @override
  State<AiChatBottomSheet> createState() => _AiChatBottomSheetState();
}

class _AiChatBottomSheetState extends State<AiChatBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final AiViewmodel _viewmodel;

  @override
  void initState() {
    super.initState();
    _viewmodel = Get.put(
      AiViewmodel(AiRepository(AiService())),
      permanent: false,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    Get.delete<AiViewmodel>();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send([String? customText]) {
    final text = (customText ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();
    _viewmodel.sendMessage(text);
    _scrollToBottom();
  }

  void _navigateToBooking(BusRecommendation rec) {
    Navigator.of(context).pop();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SeatSelectionScreen(
          busScheduleId: rec.busScheduleId,
          basePrice: rec.price,
          fromLocation: rec.fromLocation,
          toLocation: rec.toLocation,
          busType: rec.busType,
          companyName: rec.companyName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1D24) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Column(
            children: [
              AiChatHeader(isDark: isDark, onClearChat: _viewmodel.clearChat),
              Expanded(
                child: Obx(() {
                  if (_viewmodel.messages.isEmpty) {
                    return AiChatWelcomeView(
                      isDark: isDark,
                      onSelectSuggestion: (s) => _send(s),
                    );
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount:
                        _viewmodel.messages.length +
                        (_viewmodel.isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _viewmodel.messages.length) {
                        return AiChatTypingIndicator(isDark: isDark);
                      }
                      return ChatBubble(
                        message: _viewmodel.messages[index],
                        onBookNow: _navigateToBooking,
                      );
                    },
                  );
                }),
              ),
              AiChatInputField(
                controller: _controller,
                isDark: isDark,
                onSend: () => _send(),
              ),
            ],
          ),
        );
      },
    );
  }
}
