import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/app/main_app.dart';
import 'package:frontend/app/splash_screen.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/shared/service/auth_service.dart';
import 'package:get/get.dart';

import 'package:frontend/features/home/repository/bus_location_repository.dart';
import 'package:frontend/features/home/viewmodel/bus_location_viewmodel.dart';
import 'package:frontend/shared/service/bus_location_service.dart';
import 'package:frontend/shared/service/user_location_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  Get.put(LanguageController());
  Get.put(ThemeController());
  Get.put(AuthViewmodel(AuthRepository(AuthService())));
  Get.put(BusLocationViewmodel(BusLocationRepository(BusLocationService())));
  Get.put(UserLocationService());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final languageController = Get.find<LanguageController>();
    final themeController = Get.find<ThemeController>();
    return Obx(() {
      final isKhmer = languageController.isKhmer;
      return GetMaterialApp(
        home: const AuthGate(),
        debugShowCheckedModeBanner: false,
        translations: AppTranslations(),
        locale: languageController.locale.value,
        fallbackLocale: const Locale('en', 'US'),
        theme: AppTheme.lightTheme(isKhmer: isKhmer),
        darkTheme: AppTheme.darkTheme(isKhmer: isKhmer),
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
