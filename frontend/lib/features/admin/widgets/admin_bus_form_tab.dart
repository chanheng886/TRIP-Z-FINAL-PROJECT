import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_form_fields.dart';
import 'package:frontend/features/admin/widgets/admin_form_hero_header.dart';
import 'package:frontend/features/admin/widgets/admin_list_tiles.dart';
import 'package:get/get.dart';

class AdminBusFormTab extends StatefulWidget {
  final AdminDashboardViewmodel viewModel;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final void Function(String message, {required bool isError}) onShowSnack;

  const AdminBusFormTab({
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
  State<AdminBusFormTab> createState() => _AdminBusFormTabState();
}

class _AdminBusFormTabState extends State<AdminBusFormTab> {
  final _busKey = GlobalKey<FormState>();
  final _busCompanyNameController = TextEditingController();
  final _busTypeNameController = TextEditingController();
  final _plateController = TextEditingController();
  final _busSeatController = TextEditingController();
  final _busImageUrlController = TextEditingController();

  int? _selectedCompanyId;
  int? _selectedBusTypeId;

  @override
  void dispose() {
    _busCompanyNameController.dispose();
    _busTypeNameController.dispose();
    _plateController.dispose();
    _busSeatController.dispose();
    _busImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _submitBus() async {
    if (!_busKey.currentState!.validate()) return;

    final companyName =
        _busCompanyNameController.text.trim().isNotEmpty
            ? _busCompanyNameController.text.trim()
            : _selectedCompanyId != null && widget.viewModel.companies.isNotEmpty
            ? widget.viewModel.companies
                  .firstWhere((c) => c.id == _selectedCompanyId)
                  .companyName
            : '';
    final busType =
        _busTypeNameController.text.trim().isNotEmpty
            ? _busTypeNameController.text.trim()
            : _selectedBusTypeId != null && widget.viewModel.busTypes.isNotEmpty
            ? widget.viewModel.busTypes
                  .firstWhere((t) => t.id == _selectedBusTypeId)
                  .busType
            : '';

    if (companyName.isEmpty) {
      widget.onShowSnack('fill_bus_fields'.tr, isError: true);
      return;
    }
    if (busType.isEmpty) {
      widget.onShowSnack('fill_bus_fields'.tr, isError: true);
      return;
    }

    final ok = await widget.viewModel.createBus(
      companyName: companyName,
      busType: busType,
      seatCapacity: int.parse(_busSeatController.text.trim()),
      plateNumber: _plateController.text.trim(),
      imageUrl: _busImageUrlController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _selectedCompanyId = null;
        _selectedBusTypeId = null;
        _busCompanyNameController.clear();
        _busTypeNameController.clear();
        _plateController.clear();
        _busSeatController.clear();
        _busImageUrlController.clear();
      });
      widget.onShowSnack('bus_added_success'.tr, isError: false);
      widget.viewModel.loadOptions();
    } else {
      widget.onShowSnack(
        widget.viewModel.errorMessage.value.isEmpty
            ? 'failed_add_bus'.tr
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
            title: 'bus_fleet_registry'.tr,
            subtitle: 'register_new_vehicles'.tr,
            icon: FontAwesomeIcons.bus,
            count: widget.viewModel.buses.length,
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
              key: _busKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'register_new_bus'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.viewModel.companies.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        'no_existing_companies'.tr,
                        style: AppFonts.dmSans(
                          fontSize: 12,
                          color: widget.secondaryText,
                        ),
                      ),
                    ),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedCompanyId,
                    decoration: adminDropdownDecoration(
                      label: 'select_company'.tr,
                      icon: FontAwesomeIcons.building,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    dropdownColor: widget.cardBackground,
                    items: widget.viewModel.companies
                        .map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(
                              c.companyName.trDb,
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
                        _selectedCompanyId = v;
                        if (v != null) {
                          final company = widget.viewModel.companies.firstWhere(
                            (c) => c.id == v,
                          );
                          _busCompanyNameController.text = company.companyName;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _busCompanyNameController,
                    decoration: adminFieldDecoration(
                      label: 'or_type_company'.tr,
                      icon: FontAwesomeIcons.pen,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    onChanged: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() => _selectedCompanyId = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(18),
                    elevation: 8,
                    menuMaxHeight: 300,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 22,
                      color: AppColors.green,
                    ),
                    initialValue: _selectedBusTypeId,
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
                    onChanged: (v) {
                      setState(() {
                        _selectedBusTypeId = v;
                        if (v != null) {
                          final busType = widget.viewModel.busTypes.firstWhere(
                            (t) => t.id == v,
                          );
                          _busTypeNameController.text = busType.busType;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _busTypeNameController,
                    decoration: adminFieldDecoration(
                      label: 'or_type_bus_type'.tr,
                      icon: FontAwesomeIcons.pen,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    onChanged: (v) {
                      if (v.trim().isNotEmpty) {
                        setState(() => _selectedBusTypeId = null);
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _plateController,
                    textInputAction: TextInputAction.next,
                    decoration: adminFieldDecoration(
                      label: 'license_plate_label'.tr,
                      icon: FontAwesomeIcons.idCard,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'plate_number_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _busSeatController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: adminFieldDecoration(
                      label: 'seat_capacity_label'.tr,
                      icon: FontAwesomeIcons.users,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'seat_capacity_required'.tr;
                      }
                      if (int.tryParse(value.trim()) == null) {
                        return 'enter_valid_number'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _busImageUrlController,
                    textInputAction: TextInputAction.done,
                    decoration: adminFieldDecoration(
                      label: 'bus_photo_url_label'.tr,
                      icon: FontAwesomeIcons.image,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => AdminSubmitButton(
                      isLoading: widget.viewModel.isSubmitting.value,
                      onPressed: _submitBus,
                      label: 'register_bus_to_fleet'.tr,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (widget.viewModel.buses.isNotEmpty) ...[
            Text(
              '${'fleet_vehicles'.tr} (${widget.viewModel.buses.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.viewModel.buses.map(
              (bus) => AdminBusListTile(
                bus: bus,
                cardBg: widget.cardBackground,
                primaryText: widget.primaryText,
                secondaryText: widget.secondaryText,
                borderColor: widget.borderColor,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
