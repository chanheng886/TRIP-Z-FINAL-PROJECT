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

class AdminRouteFormTab extends StatefulWidget {
  final AdminDashboardViewmodel viewModel;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final void Function(String message, {required bool isError}) onShowSnack;

  const AdminRouteFormTab({
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
  State<AdminRouteFormTab> createState() => _AdminRouteFormTabState();
}

class _AdminRouteFormTabState extends State<AdminRouteFormTab> {
  final _routeKey = GlobalKey<FormState>();
  int? _fromLocationId;
  int? _toLocationId;

  Future<void> _submitRoute() async {
    if (!_routeKey.currentState!.validate()) return;
    if (_fromLocationId == null || _toLocationId == null) {
      widget.onShowSnack('select_both_locations'.tr, isError: true);
      return;
    }
    if (_fromLocationId == _toLocationId) {
      widget.onShowSnack('different_locations_error'.tr, isError: true);
      return;
    }
    final from = widget.viewModel.locations.firstWhere(
      (l) => l.id == _fromLocationId,
    );
    final to = widget.viewModel.locations.firstWhere(
      (l) => l.id == _toLocationId,
    );

    final exists = widget.viewModel.routes.any(
      (r) =>
          r.fromLocation.trim().toLowerCase() ==
              from.locationName.trim().toLowerCase() &&
          r.toLocation.trim().toLowerCase() ==
              to.locationName.trim().toLowerCase(),
    );
    if (exists) {
      widget.onShowSnack('route_already_exists'.tr, isError: true);
      return;
    }

    final ok = await widget.viewModel.createRoute(
      fromLocation: from.locationName,
      toLocation: to.locationName,
    );
    if (!mounted) return;
    if (ok) {
      setState(() {
        _fromLocationId = null;
        _toLocationId = null;
      });
      widget.onShowSnack('route_added_success'.tr, isError: false);
      widget.viewModel.loadOptions();
    } else {
      widget.onShowSnack(
        widget.viewModel.errorMessage.value.isEmpty
            ? 'failed_add_route'.tr
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
            title: 'route_network'.tr,
            subtitle: 'create_origin_dest_routes'.tr,
            icon: FontAwesomeIcons.road,
            count: widget.viewModel.routes.length,
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
              key: _routeKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'connect_new_route'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (widget.viewModel.locations.isEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        'no_destinations_available'.tr,
                        style: AppFonts.dmSans(color: widget.secondaryText),
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
                    initialValue: _fromLocationId,
                    decoration: adminDropdownDecoration(
                      label: 'from_origin'.tr,
                      icon: FontAwesomeIcons.locationDot,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    dropdownColor: widget.cardBackground,
                    items: widget.viewModel.locations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(
                              l.locationName.trDb,
                              style: adminDropdownTextStyle(
                                primaryText: widget.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _fromLocationId = v),
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
                    initialValue: _toLocationId,
                    decoration: adminDropdownDecoration(
                      label: 'to_destination'.tr,
                      icon: FontAwesomeIcons.flag,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    dropdownColor: widget.cardBackground,
                    items: widget.viewModel.locations
                        .map(
                          (l) => DropdownMenuItem(
                            value: l.id,
                            child: Text(
                              l.locationName.trDb,
                              style: adminDropdownTextStyle(
                                primaryText: widget.primaryText,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _toLocationId = v),
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => AdminSubmitButton(
                      isLoading: widget.viewModel.isSubmitting.value,
                      onPressed: _submitRoute,
                      label: 'create_route_line'.tr,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (widget.viewModel.routes.isNotEmpty) ...[
            Text(
              '${'active_route_lines'.tr} (${widget.viewModel.routes.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.viewModel.routes.map(
              (route) => AdminRouteListTile(
                route: route,
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
