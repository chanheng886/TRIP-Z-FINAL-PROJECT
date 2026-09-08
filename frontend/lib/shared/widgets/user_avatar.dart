import 'dart:convert';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';

class UserAvatar extends StatelessWidget {
  final String? profileImage;
  final String? username;
  final double size;
  final double? fontSize;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final bool showOnlineIndicator;
  final bool isDark;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.profileImage,
    this.username,
    this.size = 48,
    this.fontSize,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 2.0,
    this.showOnlineIndicator = false,
    this.isDark = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveUsername = (username != null && username!.trim().isNotEmpty)
        ? username!.trim()
        : 'User';
    final initial = effectiveUsername.isNotEmpty
        ? effectiveUsername[0].toUpperCase()
        : 'U';
    final effectiveFontSize = fontSize ?? (size * 0.42);

    Widget avatarContent = _buildImageOrFallback(initial, effectiveFontSize);

    Widget widget = Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: showBorder
                ? Border.all(
                    color: borderColor ??
                        (isDark ? const Color(0xFF2C313C) : Colors.white),
                    width: borderWidth,
                  )
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                blurRadius: size > 60 ? 14 : 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(child: avatarContent),
        ),
        if (showOnlineIndicator)
          Positioned(
            bottom: 1,
            right: 1,
            child: Container(
              width: size * 0.22,
              height: size * 0.22,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981),
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF15181E)
                      : const Color(0xFF1C1F2E),
                  width: size > 60 ? 2.5 : 1.8,
                ),
              ),
            ),
          ),
      ],
    );

    if (onTap != null) {
      return InkWell(
        borderRadius: BorderRadius.circular(size / 2),
        onTap: onTap,
        child: widget,
      );
    }

    return widget;
  }

  Widget _buildImageOrFallback(String initial, double effectiveFontSize) {
    final img = profileImage?.trim();

    if (img == null || img.isEmpty) {
      return _buildFallback(initial, effectiveFontSize);
    }

    // 1. Base64 Image (Data URI or raw base64)
    if (img.startsWith('data:image') || img.length > 200 && !img.startsWith('http')) {
      try {
        final cleanBase64 = img.contains(',') ? img.split(',').last : img;
        final bytes = base64Decode(cleanBase64);
        return Image.memory(
          bytes,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _buildFallback(initial, effectiveFontSize),
        );
      } catch (e) {
        return _buildFallback(initial, effectiveFontSize);
      }
    }

    // 2. Remote HTTP/HTTPS Image
    if (img.startsWith('http://') || img.startsWith('https://')) {
      return CachedNetworkImage(
        imageUrl: img,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: isDark ? const Color(0xFF2C313C) : Colors.grey.shade300,
          child: const Center(
            child: FaIcon(
              FontAwesomeIcons.user,
              size: 16,
              color: Colors.white70,
            ),
          ),
        ),
        errorWidget: (context, url, error) =>
            _buildFallback(initial, effectiveFontSize),
      );
    }

    // 3. Local File
    final file = File(img);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            _buildFallback(initial, effectiveFontSize),
      );
    }

    return _buildFallback(initial, effectiveFontSize);
  }

  Widget _buildFallback(String initial, double effectiveFontSize) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.green, AppColors.limeGradientEnd],
        ),
      ),
      child: Center(
        child: Text(
          initial,
          style: AppFonts.dmSans(
            fontSize: effectiveFontSize,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
