import 'dart:typed_data';
import 'image_saver_stub.dart'
    if (dart.library.html) 'image_saver_web.dart'
    if (dart.library.io) 'image_saver_io.dart';

abstract class ImageSaver {
  static Future<bool> saveImage({
    required Uint8List bytes,
    required String name,
  }) {
    return saveImagePlatform(bytes: bytes, name: name);
  }
}
