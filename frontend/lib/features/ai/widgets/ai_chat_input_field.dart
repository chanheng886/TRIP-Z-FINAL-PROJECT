import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class AiChatInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSend;
  final VoidCallback? onFocused;

  const AiChatInputField({
    super.key,
    required this.controller,
    required this.isDark,
    required this.onSend,
    this.onFocused,
  });

  @override
  State<AiChatInputField> createState() => _AiChatInputFieldState();
}

class _AiChatInputFieldState extends State<AiChatInputField> {
  late final FocusNode _focusNode;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        widget.onFocused?.call();
      }
    });
    _hasText = widget.controller.text.trim().isNotEmpty;
    widget.controller.addListener(_handleTextChange);
  }

  void _handleTextChange() {
    final has = widget.controller.text.trim().isNotEmpty;
    if (has != _hasText) {
      setState(() => _hasText = has);
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dockBg =
        widget.isDark ? const Color(0xFF161A22) : Colors.white;
    final inputBg =
        widget.isDark ? const Color(0xFF1F2430) : const Color(0xFFF1F5F9);
    final borderColor =
        widget.isDark ? const Color(0xFF2C3444) : const Color(0xFFE2E8F0);
    final textPrimary =
        widget.isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final textSecondary =
        widget.isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    final hasKeyboard = MediaQuery.of(context).viewInsets.bottom > 0;
    final bottomPadding = hasKeyboard
        ? 10.0
        : (MediaQuery.of(context).padding.bottom + 10.0);

    return Container(
      padding: EdgeInsets.only(
        left: 14,
        right: 14,
        top: 10,
        bottom: bottomPadding,
      ),
      decoration: BoxDecoration(
        color: dockBg,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Input pill
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: inputBg,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: _hasText
                      ? AppColors.green.withValues(alpha: 0.5)
                      : borderColor,
                  width: 1.2,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  FaIcon(
                    FontAwesomeIcons.wandMagicSparkles,
                    size: 13,
                    color: _hasText ? AppColors.green : textSecondary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      focusNode: _focusNode,
                      controller: widget.controller,
                      maxLines: 3,
                      minLines: 1,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => widget.onSend(),
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        color: textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask about routes, fares, schedules...',
                        hintStyle: AppFonts.dmSans(
                          fontSize: 13,
                          color: textSecondary.withValues(alpha: 0.7),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  if (_hasText)
                    IconButton(
                      icon: FaIcon(
                        FontAwesomeIcons.circleXmark,
                        size: 14,
                        color: textSecondary,
                      ),
                      onPressed: () => widget.controller.clear(),
                      splashRadius: 16,
                    )
                  else
                    const SizedBox(width: 8),
                ],
              ),
            ),
          ),

          const SizedBox(width: 10),

          // Send Action Button
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: _hasText
                  ? const LinearGradient(
                      colors: [AppColors.green, AppColors.greenBright],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: _hasText
                  ? null
                  : (widget.isDark
                      ? const Color(0xFF262C38)
                      : const Color(0xFFE2E8F0)),
              boxShadow: _hasText
                  ? [
                      BoxShadow(
                        color: AppColors.green.withValues(alpha: 0.4),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _hasText ? widget.onSend : null,
                borderRadius: BorderRadius.circular(22),
                child: Center(
                  child: FaIcon(
                    FontAwesomeIcons.paperPlane,
                    color: _hasText
                        ? Colors.white
                        : (widget.isDark
                            ? Colors.white30
                            : Colors.black26),
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
