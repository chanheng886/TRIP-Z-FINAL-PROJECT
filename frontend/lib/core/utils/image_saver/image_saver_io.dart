import 'dart:typed_data';
import 'package:gal/gal.dart';

Future<bool> saveImagePlatform({
  required Uint8List bytes,
  required String name,
}) async {
  try {
    // 1. Try to save directly first.
    // Modern Android (API 29+ / Android 10+) uses Scoped Storage / MediaStore
    // which does not require WRITE_EXTERNAL_STORAGE permission.
    await Gal.putImageBytes(bytes, name: name);
    return true;
  } on GalException catch (e) {
    if (e.type == GalExceptionType.accessDenied) {
      final granted = await Gal.requestAccess();
      if (granted) {
        await Gal.putImageBytes(bytes, name: name);
        return true;
      }
      throw Exception('Gallery access permission denied');
    }
    rethrow;
  } catch (e) {
    // Fallback: try requesting access if direct save threw permission error
    try {
      final granted = await Gal.requestAccess();
      if (granted) {
        await Gal.putImageBytes(bytes, name: name);
        return true;
      }
    } catch (_) {}
    rethrow;
  }
}
