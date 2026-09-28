import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Automatically uses native configuration (google-services.json / GoogleService-Info.plist)
/// on Android/iOS, and environment variables on Web.
class DefaultFirebaseOptions {
  static FirebaseOptions? get currentPlatform {
    if (kIsWeb) {
      final apiKey = dotenv.env['FIREBASE_WEB_API_KEY']?.trim() ?? '';
      final appId = dotenv.env['FIREBASE_WEB_APP_ID']?.trim() ?? '';
      final messagingSenderId =
          dotenv.env['FIREBASE_MESSAGING_SENDER_ID']?.trim() ?? '';
      final projectId =
          dotenv.env['FIREBASE_PROJECT_ID']?.trim() ?? 'trip-z-web-application';

      if (apiKey.isEmpty || appId.isEmpty) {
        return null;
      }

      return FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
        authDomain: '$projectId.firebaseapp.com',
        storageBucket: '$projectId.firebasestorage.app',
      );
    }

    // On mobile platforms, returning null allows Firebase to load directly
    // from google-services.json (Android) or GoogleService-Info.plist (iOS).
    return null;
  }
}
