import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_list_tiles.dart';
import 'package:frontend/features/admin/widgets/admin_schedule_filter_chip.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';

class AdminAllSchedulesScreen extends StatefulWidget {
  final AdminDashboardViewmodel viewModel;

  const AdminAllSchedulesScreen({
    super.key,
    required this.viewModel,
  });

  @override
  State<AdminAllSchedulesScreen> createState() =>
      _AdminAllSchedulesScreenState();
}

class _AdminAllSchedulesScreenState extends State<AdminAllSchedulesScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All'; // 'All', 'Available', 'Expired', 'Booked'

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? AppColors.darkBg : const Color(0xFFF7F8FA);
    final cardBg = isDark ? const Color(0xFF1E222B) : Colors.white;
    final primaryText =
        isDark ? AppColors.darkPrimaryText : AppColors.lightPrimaryText;
    final secondaryText =
        isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor =
        isDark ? const Color(0xFF2C313C) : const Color(0xFFE2E8F0);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        backgroundColor: cardBg,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: FaIcon(
            FontAwesomeIcons.arrowLeft,
            size: 18,
            color: primaryText,
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'all_schedules'.tr,
              style: AppFonts.dmSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primaryText,
              ),
            ),
            Obx(
              () => Text(
                '${widget.viewModel.schedules.length} ${'scheduled_departures'.tr.toLowerCase()}',
                style: AppFonts.dmSans(
                  fontSize: 12,
                  color: secondaryText,
                ),
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: borderColor, height: 1.0),
        ),
      ),
      body: Obx(() {
        final allSchedules = widget.viewModel.schedules;
        final query = _searchController.text.trim().toLowerCase();

        // Counts
        final availableCount = allSchedules
            .where((s) => !s.isExpired && s.status == BusScheduleStatus.Available)
            .length;
        final expiredCount = allSchedules
            .where((s) => s.isExpired || s.status == BusScheduleStatus.Expired)
            .length;
        final bookedCount = allSchedules
            .where((s) => !s.isExpired && s.status == BusScheduleStatus.Booked)
            .length;

        // Filtered list
        final filteredList = allSchedules.where((s) {
          final isExp =
              s.isExpired || s.status == BusScheduleStatus.Expired;
          final isAvail = !isExp && s.status == BusScheduleStatus.Available;
          final isBook = !isExp && s.status == BusScheduleStatus.Booked;

          // Status filter
          if (_selectedFilter == 'Available' && !isAvail) return false;
          if (_selectedFilter == 'Expired' && !isExp) return false;
          if (_selectedFilter == 'Booked' && !isBook) return false;

          // Search query
          if (query.isNotEmpty) {
            final from = s.fromLocation.toLowerCase();
            final to = s.toLocation.toLowerCase();
            final plate = s.plateNumber.toLowerCase();
            final comp = s.companyName.toLowerCase();
            final type = s.busType.toLowerCase();
            final matches = from.contains(query) ||
                to.contains(query) ||
                plate.contains(query) ||
                comp.contains(query) ||
                type.contains(query);
            if (!matches) return false;
          }
          return true;
        }).toList();

        return Column(
          children: [
            // Search & Filter Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: cardBg,
              child: Column(
                children: [
                  // Search Input
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    style: AppFonts.dmSans(color: primaryText, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: isDark
                          ? const Color(0xFF14171F)
                          : const Color(0xFFF1F5F9),
                      hintText: 'search_schedules'.tr,
                      hintStyle: AppFonts.dmSans(
                        color: secondaryText.withValues(alpha: 0.7),
                        fontSize: 13,
                      ),
                      prefixIcon: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: AppColors.green,
                        ),
                      ),
                      prefixIconConstraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              color: secondaryText,
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 11,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                          color: AppColors.green,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        AdminScheduleFilterChip(
                          label: 'all'.tr,
                          count: allSchedules.length,
                          filterValue: 'All',
                          isSelected: _selectedFilter == 'All',
                          activeColor: AppColors.green,
                          isDark: isDark,
                          onSelected: (val) => setState(() => _selectedFilter = val),
                        ),
                        const SizedBox(width: 8),
                        AdminScheduleFilterChip(
                          label: 'available'.tr,
                          count: availableCount,
                          filterValue: 'Available',
                          isSelected: _selectedFilter == 'Available',
                          activeColor: AppColors.green,
                          isDark: isDark,
                          onSelected: (val) => setState(() => _selectedFilter = val),
                        ),
                        const SizedBox(width: 8),
                        AdminScheduleFilterChip(
                          label: 'expired'.tr,
                          count: expiredCount,
                          filterValue: 'Expired',
                          isSelected: _selectedFilter == 'Expired',
                          activeColor: const Color(0xFFEF4444),
                          isDark: isDark,
                          onSelected: (val) => setState(() => _selectedFilter = val),
                        ),
                        const SizedBox(width: 8),
                        AdminScheduleFilterChip(
                          label: 'booked'.tr,
                          count: bookedCount,
                          filterValue: 'Booked',
                          isSelected: _selectedFilter == 'Booked',
                          activeColor: isDark
                              ? const Color(0xFF8A8A8E)
                              : const Color(0xFF64748B),
                          isDark: isDark,
                          onSelected: (val) => setState(() => _selectedFilter = val),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Schedules List
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.calendarXmark,
                            size: 40,
                            color: secondaryText.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'no_buses_found'.tr,
                            style: AppFonts.dmSans(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: primaryText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'no_buses_found_subtitle'.tr,
                            style: AppFonts.dmSans(
                              fontSize: 13,
                              color: secondaryText,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final s = filteredList[index];
                        return AdminScheduleListTile(
                          schedule: s,
                          isDark: isDark,
                          cardBg: cardBg,
                          primaryText: primaryText,
                          secondaryText: secondaryText,
                          borderColor: borderColor,
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}
