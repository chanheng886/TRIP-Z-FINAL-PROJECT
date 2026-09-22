import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/contact/widgets/contact_header_card.dart';
import 'package:frontend/features/contact/widgets/hotline_card.dart';
import 'package:frontend/features/contact/widgets/interactive_contact_item.dart';
import 'package:frontend/features/contact/widgets/phone_selection_bottom_sheet.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatelessWidget {
  const ContactScreen({super.key});

  static const String telegramUrl = 'https://t.me/ChunChenheng';
  static const String phone1 = '+855 61 308 202';
  static const String phone2 = '+855 92 590 867';
  static const String emailAddress = 'chanheng059@gmail.com';
  static const String mapSearchUrl =
      'https://www.google.com/maps/search/?api=1&query=Chhuk+Meas+Market+Sen+Sokh+Phnom+Penh+Cambodia';

  Future<void> _makePhoneCall(String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    final uri = Uri(scheme: 'tel', path: cleanNumber);
    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Fallback for desktop/unsupported dialer environments
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      Get.snackbar(
        'hotline'.tr,
        '$phoneNumber copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.check_circle, color: Colors.white),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
    }
  }

  Future<void> _openTelegram() async {
    final uri = Uri.parse(telegramUrl);
    try {
      final launched =
          await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: telegramUrl));
      Get.snackbar(
        'telegram_support'.tr,
        'Telegram link copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF0088CC),
        colorText: Colors.white,
        icon: const FaIcon(FontAwesomeIcons.telegram, color: Colors.white),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _sendEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: emailAddress,
      queryParameters: {'subject': 'TRIP-Z Customer Support & Inquiry'},
    );
    try {
      final launched = await launchUrl(uri);
      if (!launched) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: emailAddress));
      Get.snackbar(
        'email_support'.tr,
        '$emailAddress copied to clipboard',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        icon: const Icon(Icons.mail, color: Colors.white),
        margin: const EdgeInsets.all(16),
      );
    }
  }

  Future<void> _openMap() async {
    final uri = Uri.parse(mapSearchUrl);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final background = Theme.of(context).scaffoldBackgroundColor;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final cardColor = isDarkMode ? const Color(0xFF1E222B) : Colors.white;
    final languageController = Get.find<LanguageController>();

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        title: Obx(() {
          final _ = languageController.locale.value;
          return Text(
            'nav_contact'.tr,
            style: AppFonts.dmSans(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryText,
            ),
          );
        }),
      ),
      body: Obx(() {
        final _ = languageController.locale.value;

        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Card
              const ContactHeaderCard(),
              const SizedBox(height: 24),

              // 1. Phone Hotline (Interactive card with selection modal & quick chips)
              HotlineCard(
                cardColor: cardColor,
                isDarkMode: isDarkMode,
                phone1: phone1,
                phone2: phone2,
                onCardTap: () => PhoneSelectionBottomSheet.show(
                  context: context,
                  phone1: phone1,
                  phone2: phone2,
                  isDarkMode: isDarkMode,
                  onSelectPhone: _makePhoneCall,
                ),
                onCallPhone1: () => _makePhoneCall(phone1),
                onCallPhone2: () => _makePhoneCall(phone2),
              ),

              // 2. Telegram Support (Direct link to https://t.me/ChunChenheng)
              InteractiveContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF0088CC),
                iconBg: const Color(0xFF0088CC).withValues(alpha: 0.12),
                icon: FontAwesomeIcons.telegram,
                title: 'telegram_support'.tr,
                subtitle: '@ChunChenheng',
                actionLabel: 'Chat',
                isDarkMode: isDarkMode,
                onTap: _openTelegram,
              ),

              // 3. Email Support (Direct mailto:chanheng059@gmail.com)
              InteractiveContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFF10B981).withValues(alpha: 0.12),
                icon: FontAwesomeIcons.envelope,
                title: 'email_support'.tr,
                subtitle: emailAddress,
                actionLabel: 'Email',
                isDarkMode: isDarkMode,
                onTap: _sendEmail,
              ),

              // 4. Office Address (Opens Google Maps)
              InteractiveContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                icon: FontAwesomeIcons.locationDot,
                title: 'office_address'.tr,
                subtitle: 'Chhuk Meas Market, Sen Sokh, Phnom Penh, Cambodia',
                actionLabel: 'Maps',
                isDarkMode: isDarkMode,
                onTap: _openMap,
              ),

              // 5. Operating Hours
              InteractiveContactItem(
                cardColor: cardColor,
                iconColor: const Color(0xFF8B5CF6),
                iconBg: const Color(0xFF8B5CF6).withValues(alpha: 0.12),
                icon: FontAwesomeIcons.clock,
                title: 'office_hours'.tr,
                subtitle: 'office_hours_val'.tr,
                isDarkMode: isDarkMode,
              ),
              const SizedBox(height: 100),
            ],
          ),
        );
      }),
    );
  }
}
