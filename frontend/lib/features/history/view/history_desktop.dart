import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/history/viewmodel/booking_history_viewmodel.dart';
import 'package:frontend/features/history/widgets/desktop/admin_desktop_header.dart';
import 'package:frontend/features/history/widgets/desktop/admin_desktop_kpi_cards.dart';
import 'package:frontend/features/history/widgets/desktop/admin_desktop_tabs_section.dart';
import 'package:frontend/features/history/widgets/desktop/customer_desktop_booking_section.dart';
import 'package:frontend/features/history/widgets/desktop/customer_desktop_header.dart';
import 'package:frontend/features/history/widgets/desktop/history_desktop_error_state.dart';
import 'package:frontend/features/history/widgets/history_empty_state.dart';
import 'package:frontend/features/history/widgets/history_guest_view.dart';
import 'package:frontend/features/home/repository/booking_repository.dart';
import 'package:frontend/shared/service/booking_service.dart';
import 'package:get/get.dart';

class HistoryDesktop extends StatefulWidget {
  const HistoryDesktop({super.key});

  @override
  State<HistoryDesktop> createState() => _HistoryDesktopState();
}

class _HistoryDesktopState extends State<HistoryDesktop> {
  final controller = Get.put(
    BookingHistoryViewmodel(BookingRepository(BookingService())),
  );

  String _customerFilter = 'all'; // 'all', 'confirmed', 'pending'

  @override
  void initState() {
    super.initState();
    controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    if (controller.isAdmin) {
      return _buildAdminDesktop(context, theme, colorScheme, isDark);
    }
    return _buildCustomerDesktop(context, theme, colorScheme, isDark);
  }

  // =========================================================================
  // ADMIN DESKTOP WORKSTATION
  // =========================================================================
  Widget _buildAdminDesktop(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C3240)
        : const Color(0xFFE2E8F0);
    final textPrimary = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1320),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AdminDesktopHeader(
                    onSync: () => controller.loadData(),
                    isDark: isDark,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => AdminDesktopKpiCards(
                      busCount: controller.buses.length,
                      routeCount: controller.routes.length,
                      scheduleCount: controller.schedules.length,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textPrimary: textPrimary,
                      textSecondary: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => AdminDesktopTabsSection(
                      buses: controller.buses,
                      routes: controller.routes,
                      schedules: controller.schedules,
                      isLoading: controller.isLoading.value,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textSecondary: textSecondary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // CUSTOMER DESKTOP BOOKINGS & E-TICKETS
  // =========================================================================
  Widget _buildCustomerDesktop(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    bool isDark,
  ) {
    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final borderColor = isDark
        ? const Color(0xFF2C3240)
        : const Color(0xFFE2E8F0);
    final textPrimary = isDark
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final textSecondary = isDark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomerDesktopHeader(
                  onRefresh: () => controller.loadData(),
                  isDark: isDark,
                  cardBg: cardBg,
                  borderColor: borderColor,
                  textPrimary: textPrimary,
                  textSecondary: textSecondary,
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.green,
                        ),
                      );
                    }

                    if (controller.isGuest) {
                      return Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: HistoryGuestView(
                            onLoginSuccess: () => controller.loadData(),
                          ),
                        ),
                      );
                    }

                    if (controller.error.value.isNotEmpty) {
                      return HistoryDesktopErrorState(
                        errorMessage: controller.error.value,
                        onRetry: () => controller.loadData(),
                        textPrimary: textPrimary,
                        textSecondary: textSecondary,
                      );
                    }

                    if (controller.bookings.isEmpty) {
                      return HistoryEmptyState(
                        icon: FontAwesomeIcons.ticket,
                        title: 'no_history_title'.tr,
                        subtitle: 'no_history_subtitle'.tr,
                      );
                    }

                    return CustomerDesktopBookingSection(
                      allBookings: controller.bookings,
                      selectedFilter: _customerFilter,
                      onFilterChanged: (filter) {
                        setState(() => _customerFilter = filter);
                      },
                      cardBg: cardBg,
                      borderColor: borderColor,
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
