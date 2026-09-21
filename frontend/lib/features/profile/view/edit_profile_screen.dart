import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_avatar_header.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_fields_card.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_image_sheet.dart';
import 'package:frontend/features/profile/widgets/edit_profile/edit_profile_save_button.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProfileViewModel _viewModel = Get.find<ProfileViewModel>();

  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  String _selectedGender = 'Male';
  String? _profileImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = _viewModel.currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedGender = (user?.gender.isNotEmpty == true) ? user!.gender : 'Male';
    _profileImage = user?.profileImage;
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final success = await _viewModel.updateProfile(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _selectedGender,
      profileImage: _profileImage,
    );
    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'profile_updated_success'.tr,
                  style: AppFonts.dmSans(color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      );
      Navigator.of(context).pop();
    }
  }

  void _openImagePicker(BuildContext context, bool isDarkMode) {
    EditProfileImageSheet.show(
      context: context,
      hasPhoto: _profileImage != null && _profileImage!.isNotEmpty,
      isDark: isDarkMode,
      onPickCamera: () async {
        final base64Img = await _viewModel.pickImageBase64(ImageSource.camera);
        if (base64Img != null && mounted) {
          setState(() => _profileImage = base64Img);
        }
      },
      onPickGallery: () async {
        final base64Img = await _viewModel.pickImageBase64(ImageSource.gallery);
        if (base64Img != null && mounted) {
          setState(() => _profileImage = base64Img);
        }
      },
      onRemovePhoto: () {
        setState(() => _profileImage = '');
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDarkMode ? AppColors.darkBg : const Color(0xFFF6F8FA);
    final cardBg = isDarkMode ? AppColors.darkSurface : Colors.white;
    final primaryText = isDarkMode
        ? AppColors.darkPrimaryText
        : AppColors.lightPrimaryText;
    final secondaryText = isDarkMode
        ? AppColors.darkSecondaryText
        : AppColors.lightSecondaryText;
    final borderColor = isDarkMode
        ? const Color(0xFF2A2A2E)
        : const Color(0xFFE5E7EB);
    final fieldBg = isDarkMode
        ? const Color(0xFF1E222A)
        : const Color(0xFFF8FAFC);

    final user = _viewModel.currentUser;
    final username = user?.username.isNotEmpty == true ? user!.username : 'User';
    final email = user?.email.isNotEmpty == true ? user!.email : 'user@tripz.kh';

    return Scaffold(
      backgroundColor: pageBg,
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 1),
            ),
            child: Center(
              child: FaIcon(
                FontAwesomeIcons.angleLeft,
                size: 16,
                color: primaryText,
              ),
            ),
          ),
        ),
        title: Text(
          'edit_profile'.tr,
          style: AppFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: primaryText,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Avatar Preview & Camera Edit Icon (Tap to change)
              EditProfileAvatarHeader(
                profileImage: _profileImage,
                username: _usernameController.text.isNotEmpty
                    ? _usernameController.text
                    : username,
                email: email,
                onTapChangePhoto: () => _openImagePicker(context, isDarkMode),
                pageBg: pageBg,
                primaryText: primaryText,
                secondaryText: secondaryText,
                isDark: isDarkMode,
              ),

              const SizedBox(height: 24),

              // 2. Personal Information Fields Card
              EditProfileFieldsCard(
                usernameController: _usernameController,
                emailController: _emailController,
                phoneController: _phoneController,
                selectedGender: _selectedGender,
                onGenderChanged: (gender) => setState(() => _selectedGender = gender),
                cardBg: cardBg,
                borderColor: borderColor,
                primaryText: primaryText,
                fieldBg: fieldBg,
                isDark: isDarkMode,
              ),

              const SizedBox(height: 32),

              // 3. Save Changes Button
              EditProfileSaveButton(
                isSubmitting: _isSubmitting,
                onSave: _handleSave,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
