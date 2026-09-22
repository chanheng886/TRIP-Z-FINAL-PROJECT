import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/localization/db_translator.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/admin/viewmodel/admin_dashboard_viewmodel.dart';
import 'package:frontend/features/admin/widgets/admin_form_fields.dart';
import 'package:frontend/features/admin/widgets/admin_form_hero_header.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AdminLocationFormTab extends StatefulWidget {
  final AdminDashboardViewmodel viewModel;
  final bool isDark;
  final Color cardBackground;
  final Color primaryText;
  final Color secondaryText;
  final Color borderColor;
  final void Function(String message, {required bool isError}) onShowSnack;

  const AdminLocationFormTab({
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
  State<AdminLocationFormTab> createState() => _AdminLocationFormTabState();
}

class _AdminLocationFormTabState extends State<AdminLocationFormTab> {
  final _locationKey = GlobalKey<FormState>();
  final _locationNameController = TextEditingController();
  final _locationImageUrlController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _locationImageBytes;

  @override
  void dispose() {
    _locationNameController.dispose();
    _locationImageUrlController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadLocationImage() async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (file == null) return;

      final bytes = await file.readAsBytes();
      setState(() {
        _locationImageBytes = bytes;
      });

      final url = await widget.viewModel.uploadImage(
        bytes: bytes,
        filename: file.name,
        folder: 'tripz/locations',
      );

      if (!mounted) return;
      if (url != null && url.isNotEmpty) {
        setState(() {
          _locationImageUrlController.text = url;
        });
        widget.onShowSnack(
          'Image uploaded to Cloudinary successfully!',
          isError: false,
        );
      } else {
        widget.onShowSnack(
          widget.viewModel.errorMessage.value.isNotEmpty
              ? widget.viewModel.errorMessage.value
              : 'Failed to upload image to Cloudinary',
          isError: true,
        );
      }
    } catch (e) {
      if (!mounted) return;
      widget.onShowSnack('Error picking image: $e', isError: true);
    }
  }

  Future<void> _submitLocation() async {
    if (!_locationKey.currentState!.validate()) return;
    final ok = await widget.viewModel.createLocation(
      locationName: _locationNameController.text.trim(),
      imageUrl: _locationImageUrlController.text.trim(),
    );
    if (!mounted) return;
    if (ok) {
      _locationNameController.clear();
      _locationImageUrlController.clear();
      setState(() {
        _locationImageBytes = null;
      });
      widget.onShowSnack('location_added_success'.tr, isError: false);
      widget.viewModel.loadOptions();
    } else {
      widget.onShowSnack(
        widget.viewModel.errorMessage.value.isEmpty
            ? 'failed_add_location'.tr
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
            title: 'location_registry'.tr,
            subtitle: 'register_terminal_cities'.tr,
            icon: FontAwesomeIcons.locationDot,
            count: widget.viewModel.locations.length,
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
              key: _locationKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'add_new_destination'.tr,
                    style: AppFonts.dmSans(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.primaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _locationNameController,
                    textInputAction: TextInputAction.next,
                    decoration: adminFieldDecoration(
                      label: 'location_name_label'.tr,
                      icon: FontAwesomeIcons.mapLocationDot,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'location_name_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Destination Photo',
                    style: AppFonts.dmSans(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: widget.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() {
                    final isUploading = widget.viewModel.isUploadingImage.value;
                    final hasImage =
                        _locationImageBytes != null ||
                        _locationImageUrlController.text.trim().isNotEmpty;

                    if (hasImage) {
                      return Container(
                        height: 170,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.green.withValues(alpha: 0.4),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              if (_locationImageBytes != null)
                                Image.memory(
                                  _locationImageBytes!,
                                  fit: BoxFit.cover,
                                )
                              else
                                Image.network(
                                  _locationImageUrlController.text.trim(),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                    color: widget.isDark
                                        ? AppColors.darkSurface
                                        : const Color(0xFFF1F5F9),
                                    child: const Center(
                                      child: FaIcon(
                                        FontAwesomeIcons.triangleExclamation,
                                        color: Colors.orange,
                                      ),
                                    ),
                                  ),
                                ),
                              if (isUploading)
                                Container(
                                  color: Colors.black54,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(
                                        color: AppColors.green,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Uploading to Cloudinary...',
                                        style: AppFonts.dmSans(
                                          color: Colors.white,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Positioned(
                                top: 10,
                                right: 10,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (!isUploading &&
                                        _locationImageUrlController.text
                                            .trim()
                                            .isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 5,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.7,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: AppColors.green,
                                            width: 1,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.circleCheck,
                                              color: AppColors.green,
                                              size: 11,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Cloudinary Ready',
                                              style: AppFonts.dmSans(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: isUploading
                                          ? null
                                          : _pickAndUploadLocationImage,
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 6,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.75,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: Colors.white24,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const FaIcon(
                                              FontAwesomeIcons.penToSquare,
                                              color: Colors.white,
                                              size: 11,
                                            ),
                                            const SizedBox(width: 5),
                                            Text(
                                              'Change',
                                              style: AppFonts.dmSans(
                                                color: Colors.white,
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    InkWell(
                                      onTap: isUploading
                                          ? null
                                          : () {
                                              setState(() {
                                                _locationImageBytes = null;
                                                _locationImageUrlController
                                                    .clear();
                                              });
                                            },
                                      borderRadius: BorderRadius.circular(20),
                                      child: Container(
                                        padding: const EdgeInsets.all(7),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(
                                            alpha: 0.8,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const FaIcon(
                                          FontAwesomeIcons.xmark,
                                          color: Colors.white,
                                          size: 11,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return InkWell(
                      onTap: isUploading ? null : _pickAndUploadLocationImage,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        height: 130,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? const Color(0xFF1A1C23)
                              : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: widget.borderColor,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: AppColors.green.withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.cloudArrowUp,
                                  color: AppColors.green,
                                  size: 18,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Upload image from computer',
                              style: AppFonts.dmSans(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: widget.primaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'JPG, PNG, or WebP (Saved to Cloudinary)',
                              style: AppFonts.dmSans(
                                fontSize: 11,
                                color: widget.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  TextFormField(
                    controller: _locationImageUrlController,
                    textInputAction: TextInputAction.done,
                    decoration: adminFieldDecoration(
                      label: 'image_url_label'.tr,
                      icon: FontAwesomeIcons.image,
                      isDark: widget.isDark,
                      secondaryText: widget.secondaryText,
                      borderColor: widget.borderColor,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'image_url_required'.tr;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  Obx(
                    () => AdminSubmitButton(
                      isLoading: widget.viewModel.isSubmitting.value,
                      onPressed: _submitLocation,
                      label: 'add_location_destination'.tr,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          if (widget.viewModel.locations.isNotEmpty) ...[
            Text(
              '${'existing_destinations'.tr} (${widget.viewModel.locations.length})',
              style: AppFonts.dmSans(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.primaryText,
              ),
            ),
            const SizedBox(height: 10),
            ...widget.viewModel.locations.map(
              (loc) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: widget.cardBackground,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.borderColor, width: 1),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 38,
                        height: 38,
                        color: AppColors.green.withValues(alpha: 0.12),
                        child: (loc.imageUrl != null && loc.imageUrl!.isNotEmpty)
                            ? Image.network(
                                loc.imageUrl!,
                                width: 38,
                                height: 38,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const Center(
                                  child: FaIcon(
                                    FontAwesomeIcons.locationPin,
                                    size: 13,
                                    color: AppColors.green,
                                  ),
                                ),
                              )
                            : const Center(
                                child: FaIcon(
                                  FontAwesomeIcons.locationPin,
                                  size: 13,
                                  color: AppColors.green,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        loc.locationName.trDb,
                        style: AppFonts.dmSans(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: widget.primaryText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'ID: #${loc.id}',
                      style: AppFonts.dmSans(
                        fontSize: 11,
                        color: widget.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
