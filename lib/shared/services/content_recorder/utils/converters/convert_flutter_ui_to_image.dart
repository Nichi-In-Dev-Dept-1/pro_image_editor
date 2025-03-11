import 'dart:ui' as ui;

import '/plugins/image/src/image/image.dart' as img;

/// Converts a Flutter ui.Image to img.Image suitable for processing.
///
/// [uiImage] - The image to be converted.
Future<img.Image> convertFlutterUiToImage(ui.Image uiImage) async {
  final uiBytes = await uiImage.toByteData(format: ui.ImageByteFormat.rawRgba);

  final image = img.Image.fromBytes(
    width: uiImage.width,
    height: uiImage.height,
    bytes: uiBytes!.buffer,
    numChannels: 4,
  );

  return image;
}
