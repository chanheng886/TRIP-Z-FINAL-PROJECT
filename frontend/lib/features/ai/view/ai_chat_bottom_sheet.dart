import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/features/ai/model/ai_message.dart';
import 'package:frontend/features/ai/repository/ai_repository.dart';
import 'package:frontend/features/ai/service/ai_service.dart';
import 'package:frontend/features/ai/viewmodel/ai_viewmodel.dart';
import 'package:frontend/features/ai/view/chat_bubble.dart';
import 'package:frontend/features/home/view/pages/seat_selection_screen.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

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
    _viewmodel = Get.put(AiViewmodel(AiRepository(AiService())), permanent: false);
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

  void _send() {
    final text = _controller.text.trim();
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
              _buildHeader(isDark),
              Expanded(
                child: Obx(() {
                  if (_viewmodel.messages.isEmpty) {
                    return _buildWelcomeMessage(isDark);
                  }
                  return ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _viewmodel.messages.length +
                        (_viewmodel.isLoading.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _viewmodel.messages.length) {
                        return _buildTypingIndicator(isDark);
                      }
                      return ChatBubble(
                        message: _viewmodel.messages[index],
                        onBookNow: _navigateToBooking,
                      );
                    },
                  );
                }),
              ),
              _buildInputField(isDark),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xff4FD18B).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: FaIcon(
                FontAwesomeIcons.robot,
                color: Color(0xff4FD18B),
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TripZ AI',
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
                  ),
                ),
                Text(
                  'Your bus travel assistant',
                  style: AppFonts.dmSans(
                    fontSize: 11,
                    color: isDark ? Colors.white54 : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _viewmodel.clearChat();
            },
            icon: FaIcon(
              FontAwesomeIcons.arrowsRotate,
              size: 16,
              color: isDark ? Colors.white54 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: const Color(0xff4FD18B).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.robot,
                  color: Color(0xff4FD18B),
                  size: 28,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Hi! I\'m TripZ AI',
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ask me about bus routes, prices, or get recommendations based on your budget!',
              textAlign: TextAlign.center,
              style: AppFonts.dmSans(
                fontSize: 13,
                color: isDark ? Colors.white54 : Colors.grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            _buildSuggestionChips(isDark),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(bool isDark) {
    final suggestions = [
      'Buses to Siem Reap',
      'Budget under \$15',
      'VIP buses available',
      'Travel tips',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: suggestions.map((s) {
        return GestureDetector(
          onTap: () {
            _controller.text = s;
            _send();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2A2D35)
                  : const Color(0xff4FD18B).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xff4FD18B).withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              s,
              style: AppFonts.dmSans(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xff4FD18B),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 12, top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2D35) : Colors.grey.shade100,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(isDark, 0),
            const SizedBox(width: 4),
            _buildDot(isDark, 1),
            const SizedBox(width: 4),
            _buildDot(isDark, 2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(bool isDark, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: Duration(milliseconds: 600 + (index * 200)),
      builder: (_, value, __) {
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: value)
                : Colors.grey.withValues(alpha: value),
            shape: BoxShape.circle,
          ),
        );
      },
    );
  }

  Widget _buildInputField(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.shade200,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2A2D35) : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _send(),
                style: AppFonts.dmSans(
                  fontSize: 14,
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Ask about buses, routes, prices...',
                  hintStyle: AppFonts.dmSans(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Color(0xff4FD18B),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _send,
              icon: const FaIcon(
                FontAwesomeIcons.paperPlane,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
