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
          curve: Curves.easeOutCubic,
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
    final mediaQuery = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF14171E) : Colors.white;
    final borderColor =
        isDark ? const Color(0xFF262C38) : const Color(0xFFE2E8F0);
    final bottomInset = mediaQuery.viewInsets.bottom;
    final screenHeight = mediaQuery.size.height;
    final topSafeArea = mediaQuery.padding.top;

    // Available space from below top notch to top of keyboard
    final maxAvailableHeight = screenHeight - topSafeArea - bottomInset - 16;
    final sheetHeight = (screenHeight * 0.85).clamp(320.0, maxAvailableHeight);

    return AnimatedPadding(
      padding: EdgeInsets.only(bottom: bottomInset),
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOutCubic,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 580),
          child: Container(
            height: sheetHeight,
            decoration: BoxDecoration(
              color: sheetBg,
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(color: borderColor, width: 1.2),
                left: BorderSide(color: borderColor, width: 1),
                right: BorderSide(color: borderColor, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.45 : 0.12),
                  blurRadius: 32,
                  spreadRadius: 2,
                  offset: const Offset(0, -6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              child: Column(
                children: [
                  // Top Drag Indicator Pill & handle
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      if (details.primaryDelta != null &&
                          details.primaryDelta! > 8) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(top: 10, bottom: 4),
                      color: Colors.transparent,
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 4.5,
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white24
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Top Header
                  AiChatHeader(
                    isDark: isDark,
                    onClearChat: _viewmodel.clearChat,
                    onClose: () => Navigator.of(context).pop(),
                  ),

                  // Chat Body (Welcome or Messages)
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => FocusScope.of(context).unfocus(),
                      child: Obx(() {
                        if (_viewmodel.messages.isEmpty) {
                          return AiChatWelcomeView(
                            isDark: isDark,
                            onSelectSuggestion: (s) => _send(s),
                          );
                        }

                        // Auto-scroll when messages update
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _scrollToBottom();
                        });

                        return ListView.builder(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          itemCount: _viewmodel.messages.length +
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
                  ),

                  // Floating Dock Input Bar
                  AiChatInputField(
                    controller: _controller,
                    isDark: isDark,
                    onSend: () => _send(),
                    onFocused: _scrollToBottom,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
