import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/theme/theme_controller.dart';
import 'package:frontend/features/auth/repository/auth_repository.dart';
import 'package:frontend/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:frontend/main.dart';
import 'package:frontend/shared/service/auth_service.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App shows login screen when no session is saved',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    Get.reset();
    Get.put(ThemeController());
    Get.put(AuthViewmodel(AuthRepository(AuthService())));

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
  });
}
