import 'package:flutter/material.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/app/splash_screen.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/shared/services/auth_service.dart';
import 'package:get/get.dart';

void main() {
  Get.put(ThemeController());
  Get.put(AuthViewmodel(AuthRepository(AuthService())));
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final themeController = Get.find<ThemeController>();
      return GetMaterialApp(
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeController.themeMode.value,
      );
    });
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final authVM = Get.find<AuthViewmodel>();
    return Obx(() {
      if (authVM.isCheckingSession.value) {
        return const SplashScreen();
      }
      return authVM.isLoggedIn ? const MainApp() : const LoginScreen();
    });
  }
}
