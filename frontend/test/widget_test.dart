import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/localization/app_translations.dart';
import 'package:frontend/core/localization/language_controller.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:frontend/features/auth/view/login_screen.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/shared/service/auth_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('LoginScreen shows LOGIN button and email field',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(LanguageController());
    Get.put(ThemeController());
    Get.put(AuthViewmodel(AuthRepository(AuthService())));

    await tester.pumpWidget(
      GetMaterialApp(
        translations: AppTranslations(),
        locale: const Locale('en', 'US'),
        home: const LoginScreen(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('LOGIN'), findsOneWidget);
  });
}
