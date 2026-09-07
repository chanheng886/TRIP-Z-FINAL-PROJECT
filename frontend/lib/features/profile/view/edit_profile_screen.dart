import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/theme/app_fonts.dart';
import 'package:frontend/features/profile/viewmodel/profile_viewmodel.dart';
import 'package:get/get.dart';

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
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final user = _viewModel.currentUser;
    _usernameController = TextEditingController(text: user?.username ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _selectedGender = (user?.gender.isNotEmpty == true) ? user!.gender : 'Male';
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
    final initial = username.isNotEmpty ? username[0].toUpperCase() : 'U';

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
              // 1. Avatar Preview & Camera Edit Icon
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [AppColors.green, AppColors.limeGradientEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.green.withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initial,
                          style: AppFonts.dmSans(
                            fontSize: 38,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: pageBg,
                            width: 3,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Center(
                          child: FaIcon(
                            FontAwesomeIcons.camera,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  username,
                  style: AppFonts.dmSans(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: primaryText,
                  ),
                ),
              ),
              Center(
                child: Text(
                  user?.email.isNotEmpty == true ? user!.email : 'user@tripz.kh',
                  style: AppFonts.dmSans(
                    fontSize: 12,
                    color: secondaryText,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 2. Personal Information Fields Card
              Text(
                'personal_details'.tr,
                style: AppFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: primaryText,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderColor, width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username Field
                    _buildFieldLabel('username'.tr, primaryText),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _usernameController,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'username_cannot_empty'.tr
                          : null,
                      decoration: _buildInputDecoration(
                        hintText: 'Enter username',
                        icon: FontAwesomeIcons.solidUser,
                        iconColor: AppColors.green,
                        fieldBg: fieldBg,
                        borderColor: borderColor,
                        isDark: isDarkMode,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Email Field
                    _buildFieldLabel('Email', primaryText),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                      decoration: _buildInputDecoration(
                        hintText: 'user@tripz.kh',
                        icon: FontAwesomeIcons.solidEnvelope,
                        iconColor: const Color(0xFF3B82F6),
                        fieldBg: fieldBg,
                        borderColor: borderColor,
                        isDark: isDarkMode,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Phone Field
                    _buildFieldLabel('Phone', primaryText),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: AppFonts.dmSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: primaryText,
                      ),
                      decoration: _buildInputDecoration(
                        hintText: '+855 12 345 678',
                        icon: FontAwesomeIcons.phone,
                        iconColor: const Color(0xFF10B981),
                        fieldBg: fieldBg,
                        borderColor: borderColor,
                        isDark: isDarkMode,
                      ),
                    ),

                    const SizedBox(height: 18),

                    // Gender Selection
                    _buildFieldLabel('select_gender'.tr, primaryText),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildGenderChip(
                          label: 'gender_male'.tr,
                          icon: FontAwesomeIcons.mars,
                          value: 'Male',
                          isDark: isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _buildGenderChip(
                          label: 'gender_female'.tr,
                          icon: FontAwesomeIcons.venus,
                          value: 'Female',
                          isDark: isDarkMode,
                        ),
                        const SizedBox(width: 8),
                        _buildGenderChip(
                          label: 'gender_other'.tr,
                          icon: FontAwesomeIcons.genderless,
                          value: 'Other',
                          isDark: isDarkMode,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // 3. Save Changes Button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.green,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    shadowColor: AppColors.green.withValues(alpha: 0.4),
                  ),
                  onPressed: _isSubmitting ? null : _handleSave,
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const FaIcon(
                              FontAwesomeIcons.solidFloppyDisk,
                              size: 16,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'save_changes'.tr,
                              style: AppFonts.dmSans(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color textColor) {
    return Text(
      label,
      style: AppFonts.dmSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: textColor.withValues(alpha: 0.9),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required FaIconData icon,
    required Color iconColor,
    required Color fieldBg,
    required Color borderColor,
    required bool isDark,
  }) {
    return InputDecoration(
      filled: true,
      fillColor: fieldBg,
      hintText: hintText,
      hintStyle: AppFonts.dmSans(
        fontSize: 13,
        color: const Color(0xFF94A3B8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(left: 12, right: 10),
        child: FaIcon(icon, size: 14, color: iconColor),
      ),
      prefixIconConstraints: const BoxConstraints(minWidth: 38),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: borderColor, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.green, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFEF4444), width: 1.5),
      ),
    );
  }

  Widget _buildGenderChip({
    required String label,
    required FaIconData icon,
    required String value,
    required bool isDark,
  }) {
    final isSelected = _selectedGender == value;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedGender = value),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.green.withValues(alpha: isDark ? 0.22 : 0.12)
                : (isDark ? const Color(0xFF1E222A) : const Color(0xFFF1F5F9)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? AppColors.green
                  : (isDark ? const Color(0xFF2A2A2E) : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FaIcon(
                icon,
                size: 13,
                color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppFonts.dmSans(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected ? AppColors.green : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
