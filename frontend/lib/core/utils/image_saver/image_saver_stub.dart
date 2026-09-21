import 'dart:typed_data';

Future<bool> saveImagePlatform({
  required Uint8List bytes,
  required String name,
}) async {
  throw UnsupportedError('Saving images is not supported on this platform.');
}
