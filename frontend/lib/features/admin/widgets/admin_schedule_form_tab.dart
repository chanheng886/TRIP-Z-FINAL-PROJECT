import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/view/admin_all_schedules_screen.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_form_fields.dart';
import 'package:frontend/features/admin/widgets/admin_form_hero_header.dart';
import 'package:frontend/features/admin/widgets/admin_list_tiles.dart';
import 'package:frontend/shared/model/bus_schedule.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class AdminScheduleFormTab extends StatefulWidget {
  final AdminDashboardViewmodel viewModel;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final void Function(String message, {required bool isError}) onShowSnack;

  const AdminScheduleFormTab({
    super.key,
    required this.viewModel,
    required this.isDark,
    required this.cardBackground,
    required this.primaryText,
    required this.secondaryText,
    required this.borderColor,
    required this.onShowSnack,
  });

  @override
  State<AdminScheduleFormTab> createState() => _AdminScheduleFormTabState();
}

class _AdminScheduleFormTabState extends State<AdminScheduleFormTab> {
  final _scheduleKey = GlobalKey<FormState>();
  final _scheduleSeatController = TextEditingController();
  final _priceController = TextEditingController();

  int? _selectedBusId;
  int? _selectedRouteId;
  int? _selectedScheduleBusTypeId;
  DateTime? _travelDate;
  TimeOfDay? _departureTime;
  TimeOfDay? _arrivalTime;
  String _status = 'Available';

  @override
  void dispose() {
    _scheduleSeatController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  Future<void> _pickTravelDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _travelDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _travelDate = picked);
    }
  }

  Future<void> _pickDepartureTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _departureTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _departureTime = picked);
    }
  }

  Future<void> _pickArrivalTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _arrivalTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _arrivalTime = picked);
    }
  }

  Future<void> _submitSchedule() async {
    if (!_scheduleKey.currentState!.validate()) return;
    if (_selectedBusId == null ||
        _selectedRouteId == null ||
        _selectedScheduleBusTypeId == null ||
        _travelDate == null ||
        _departureTime == null ||
        _arrivalTime == null) {
      widget.onShowSnack('fill_all_schedule_fields'.tr, isError: true);
      return;
    }

    final depMinutes = _departureTime!.hour * 60 + _departureTime!.minute;
    final arrMinutes = _arrivalTime!.hour * 60 + _arrivalTime!.minute;
    if (arrMinutes <= depMinutes) {
      widget.onShowSnack('arrival_after_departure_error'.tr, isError: true);
      return;
    }

    final selectedDateStr = DateFormat('yyyy-MM-dd').format(_travelDate!);
    final hasOverlap = widget.viewModel.schedules.any((s) {
      if (s.busId != _selectedBusId) return false;
      if (s.status == BusScheduleStatus.Cancelled) return false;
      final sDateStr = DateFormat('yyyy-MM-dd').format(s.travelDate);
      if (sDateStr != selectedDateStr) return false;

      final sDepParts = s.departureTime.split(':');
      final sArrParts = s.arrivalTime.split(':');
      if (sDepParts.length < 2 || sArrParts.length < 2) return false;
      final sDep = int.parse(sDepParts[0]) * 60 + int.parse(sDepParts[1]);
      final sArr = int.parse(sArrParts[0]) * 60 + int.parse(sArrParts[1]);

      return depMinutes < sArr && arrMinutes > sDep;
    });

    if (hasOverlap) {
      widget.onShowSnack('bus_overlap_error'.tr, isError: true);
      return;
    }

    final selectedBus = widget.viewModel.buses.firstWhereOrNull(
      (b) => b.id == _selectedBusId,
    );
    final availableSeats =
        int.tryParse(_scheduleSeatController.text.trim()) ??
        (selectedBus != null ? int.tryParse(selectedBus.seatCapacity) ?? 0 : 0);

    if (availableSeats <= 0) {
      widget.onShowSnack('select_bus_vehicle'.tr, isError: true);
      return;
    }

    final ok = await widget.viewModel.createBusSchedule(
      busId: _selectedBusId!,
      routeId: _selectedRouteId!,
      travelDate: DateFormat('yyyy-MM-dd').format(_travelDate!),
      departureTime: _formatTime(_departureTime!),
      arrivalTime: _formatTime(_arrivalTime!),
      availableSeat: availableSeats,
      status: _status,
      basePrice: double.parse(_priceController.text.trim()),
      busTypeId: _selectedScheduleBusTypeId!,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _selectedBusId = null;
        _selectedRouteId = null;
        _selectedScheduleBusTypeId = null;
        _travelDate = null;
        _departureTime = null;
        _arrivalTime = null;
        _scheduleSeatController.clear();
        _priceController.clear();
        _status = 'Available';
      });
      widget.onShowSnack('schedule_added_success'.tr, isError: false);
      widget.viewModel.loadOptions();
    } else {
      widget.onShowSnack(
        widget.viewModel.errorMessage.value.isEmpty
            ? 'failed_add_schedule'.tr
            : widget.viewModel.errorMessage.value,
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminFormHeroHeader(
            title: 'trip_scheduler'.tr,
            subtitle: 'schedule_times_routes_fares'.tr,
            icon: FontAwesomeIcons.calendarDays,
            count: widget.viewModel.schedules.length,
            isDark: widget.isDark,
            primaryText: widget.primaryText,
            secondaryText: widget.secondaryText,
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: widget.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: widget.borderColor, width: 1),
            ),
            child: Form(
              key: _scheduleKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'schedule_new_trip'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('bus_$_selectedBusId'),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue:
                        _selectedBusId != null &&
                            widget.viewModel.buses.any(
                              (b) => b.id == _selectedBusId,
                            )
                        ? _selectedBusId
                        : null,
                    decoration: adminDropdownDecoration(
                      label: 'select_bus_vehicle'.tr,
                      icon: FontAwesomeIcons.bus,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    dropdownColor: widget.cardBackground,
                    items: widget.viewModel.buses
                        .map(
                          (b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(
                              '${b.plateNumber} • ${b.companyName.trDb} (${b.seatCapacity} ${'seats'.tr})',
                              style: adminDropdownTextStyle(
                                primaryText: widget.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _selectedBusId = v;
                        if (v != null) {
                          final selectedBus = widget.viewModel.buses
                              .firstWhereOrNull((b) => b.id == v);
                          if (selectedBus != null) {
                            _scheduleSeatController.text =
                                selectedBus.seatCapacity;
                            final matchingType = widget.viewModel.busTypes
                                .firstWhereOrNull(
                                  (t) =>
                                      t.busType.trim().toLowerCase() ==
                                      selectedBus.busType.trim().toLowerCase(),
                                );
                            if (matchingType != null) {
                              _selectedScheduleBusTypeId = matchingType.id;
                            }
                          }
                        } else {
                          _scheduleSeatController.clear();
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('route_$_selectedRouteId'),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue:
                        _selectedRouteId != null &&
                            widget.viewModel.routes.any(
                              (r) => r.id == _selectedRouteId,
                            )
                        ? _selectedRouteId
                        : null,
                    decoration: adminDropdownDecoration(
                      label: 'select_travel_route'.tr,
                      icon: FontAwesomeIcons.road,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    dropdownColor: widget.cardBackground,
                    items: widget.viewModel.routes
                        .map(
                          (r) => DropdownMenuItem(
                            value: r.id,
                            child: Text(
                              '${r.fromLocation.trDb} → ${r.toLocation.trDb}',
                              style: adminDropdownTextStyle(
                                primaryText: widget.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _selectedRouteId = v),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    key: ValueKey('type_$_selectedScheduleBusTypeId'),
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue:
                        _selectedScheduleBusTypeId != null &&
                            widget.viewModel.busTypes.any(
                              (t) => t.id == _selectedScheduleBusTypeId,
                            )
                        ? _selectedScheduleBusTypeId
                        : null,
                    decoration: adminDropdownDecoration(
                      label: 'select_bus_type'.tr,
                      icon: FontAwesomeIcons.sitemap,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    dropdownColor: widget.cardBackground,
                    items: widget.viewModel.busTypes
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Text(
                              t.busType.trDb,
                              style: adminDropdownTextStyle(
                                primaryText: widget.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) =>
                        setState(() => _selectedScheduleBusTypeId = v),
                  ),
                  const SizedBox(height: 16),
                  AdminPickerField(
                    label: 'travel_date_label'.tr,
                    icon: FontAwesomeIcons.calendarDays,
                    value: _travelDate == null
                        ? null
                        : DateFormat('MMM dd, yyyy').format(_travelDate!),
                    onTap: _pickTravelDate,
                    isDark: widget.isDark,
                    primaryText: widget.primaryText,
                    secondaryText: widget.secondaryText,
                    borderColor: widget.borderColor,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AdminPickerField(
                          label: 'departure_label'.tr,
                          icon: FontAwesomeIcons.clock,
                          value: _departureTime == null
                              ? null
                              : _formatTime(_departureTime!).substring(0, 5),
                          onTap: _pickDepartureTime,
                          isDark: widget.isDark,
                          primaryText: widget.primaryText,
                          secondaryText: widget.secondaryText,
                          borderColor: widget.borderColor,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: AdminPickerField(
                          label: 'arrival_label'.tr,
                          icon: FontAwesomeIcons.clock,
                          value: _arrivalTime == null
                              ? null
                              : _formatTime(_arrivalTime!).substring(0, 5),
                          onTap: _pickArrivalTime,
                          isDark: widget.isDark,
                          primaryText: widget.primaryText,
                          secondaryText: widget.secondaryText,
                          borderColor: widget.borderColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _scheduleSeatController,
                          readOnly: true,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.next,
                          decoration: adminFieldDecoration(
                            label: 'available_seats_label'.tr,
                            icon: FontAwesomeIcons.users,
                            isDark: widget.isDark,
                            secondaryText: widget.secondaryText,
                            borderColor: widget.borderColor,
                          ).copyWith(
                            helperText: _selectedBusId != null
                                ? 'auto_filled_from_bus'.tr
                                : null,
                            helperStyle: AppFonts.dmSans(
                              color: AppColors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'select_bus_vehicle'.tr;
                            }
                            if (int.tryParse(value.trim()) == null) {
                              return 'invalid'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.next,
                          decoration: adminFieldDecoration(
                            label: 'base_price_label'.tr,
                            icon: FontAwesomeIcons.moneyBill1,
                            isDark: widget.isDark,
                            secondaryText: widget.secondaryText,
                            borderColor: widget.borderColor,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'required'.tr;
                            }
                            if (double.tryParse(value.trim()) == null) {
                              return 'invalid'.tr;
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 4, bottom: 8),
                        child: Text(
                          'schedule_status'.tr,
                          style: AppFonts.dmSans(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: widget.secondaryText,
                          ),
                        ),
                      ),
                      Row(
                        children: ['Available', 'Booked'].map((s) {
                          final isSelected = _status == s;
                          final isAvailable = s == 'Available';
                          final activeColor = isAvailable
                              ? AppColors.green
                              : (widget.isDark
                                    ? const Color(0xFF8A8A8E)
                                    : const Color(0xFF64748B));

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => _status = s),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                  right: s == 'Available' ? 10 : 0,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 13,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? activeColor.withValues(
                                          alpha: widget.isDark ? 0.2 : 0.12,
                                        )
                                      : widget.cardBackground,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected
                                        ? activeColor
                                        : widget.borderColor,
                                    width: isSelected ? 1.8 : 1.2,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isSelected
                                          ? (isAvailable
                                                ? Icons.check_circle_rounded
                                                : Icons.cancel_rounded)
                                          : Icons.radio_button_unchecked,
                                      size: 16,
                                      color: isSelected
                                          ? activeColor
                                          : (widget.isDark
                                                ? Colors.white38
                                                : Colors.black38),
                                    ),
                                    const SizedBox(width: 7),
                                    Text(
                                      s.trDb,
                                      style: AppFonts.dmSans(
                                        fontSize: 13,
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? activeColor
                                            : widget.secondaryText,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Obx(
                    () => AdminSubmitButton(
                      isLoading: widget.viewModel.isSubmitting.value,
                      onPressed: _submitSchedule,
                      label: 'publish_trip_schedule'.tr,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (widget.viewModel.schedules.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${'scheduled_departures'.tr} (${widget.viewModel.schedules.length})',
                  style: AppFonts.dmSans(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: widget.primaryText,
                  ),
                ),
                if (widget.viewModel.schedules.length > 5)
                  TextButton.icon(
                    onPressed: () => Get.to(
                      () => AdminAllSchedulesScreen(viewModel: widget.viewModel),
                    ),
                    icon: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 15,
                      color: AppColors.green,
                    ),
                    label: Text(
                      'see_more'.tr,
                      style: AppFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.green,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            ...widget.viewModel.schedules
                .take(5)
                .map(
                  (s) => AdminScheduleListTile(
                    schedule: s,
                    isDark: widget.isDark,
                    cardBg: widget.cardBackground,
                    primaryText: widget.primaryText,
                    secondaryText: widget.secondaryText,
                    borderColor: widget.borderColor,
                  ),
                ),
            if (widget.viewModel.schedules.length > 5) ...[
              const SizedBox(height: 8),
              InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => Get.to(
                  () => AdminAllSchedulesScreen(viewModel: widget.viewModel),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: widget.isDark
                        ? const Color(0xFF1E2620)
                        : const Color(0xFFEFFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.green.withValues(alpha: 0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const FaIcon(
                        FontAwesomeIcons.listCheck,
                        size: 15,
                        color: AppColors.green,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${'see_more'.tr} (${widget.viewModel.schedules.length - 5} ${'more'.tr})',
                        style: AppFonts.dmSans(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.green,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: AppColors.green,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ],
      ),
    );
  }
}
