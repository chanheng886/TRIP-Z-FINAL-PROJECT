import 'package:get/get.dart';
import 'languages/en_us.dart';
import 'languages/km_kh.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': enUS,
        'km_KH': kmKH,
      };
}
