import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:math';

class HeuristicRequest {
  final Uint8List imageBytes;
  HeuristicRequest(this.imageBytes);
}

Future<Map<String, double>?> computeHeuristicAdjustmentsIsolate(Uint8List imageBytes) async {
  final codec = await ui.instantiateImageCodec(imageBytes);
  final frame = await codec.getNextFrame();
  final image = frame.image;

  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  if (byteData == null) return null;

  final pixels = byteData.buffer.asUint8List();

  final receivePort = ReceivePort();
  await Isolate.spawn(_heuristicIsolateEntry, [receivePort.sendPort, pixels]);
  final result = await receivePort.first;
  return result as Map<String, double>;
}

Future<void> _heuristicIsolateEntry(List<dynamic> args) async {
  final SendPort sendPort = args[0];
  final Uint8List pixels = args[1];
  final int length = pixels.lengthInBytes;

  double totalBrightness = 0;
  double totalSaturation = 0;
  double totalHue = 0;
  double totalRed = 0;
  double totalBlue = 0;
  List<double> luminanceValues = [];
  double sharpnessScore = 0;

  int validPixelCount = 0;

  for (int i = 0; i < length - 8; i += 4) {
    final r = pixels[i].toDouble();
    final g = pixels[i + 1].toDouble();
    final b = pixels[i + 2].toDouble();
    final a = pixels[i + 3];

    if (a == 0) continue;

    // Brightness & Luminance
    final brightness = 0.299 * r + 0.587 * g + 0.114 * b;
    totalBrightness += brightness;
    luminanceValues.add(brightness);

    // Saturation (from lightness)
    final maxRGB = [r, g, b].reduce(max);
    final minRGB = [r, g, b].reduce(min);
    final lightness = (maxRGB + minRGB) / 2;
    double saturation = (maxRGB - minRGB);
    if (lightness != 0) saturation /= lightness;
    totalSaturation += saturation;

    // Hue calculation
    double hue = 0;
    if (maxRGB != minRGB) {
      if (maxRGB == r) {
        hue = (g - b) / (maxRGB - minRGB);
      } else if (maxRGB == g) {
        hue = 2.0 + (b - r) / (maxRGB - minRGB);
      } else {
        hue = 4.0 + (r - g) / (maxRGB - minRGB);
      }
      hue *= 60;
      if (hue < 0) hue += 360;
    }
    totalHue += hue;

    // Temperature (red-blue balance)
    totalRed += r;
    totalBlue += b;

    // Sharpness (high-frequency variation between adjacent pixels)
    final rNext = pixels[i + 4].toDouble();
    final gNext = pixels[i + 5].toDouble();
    final bNext = pixels[i + 6].toDouble();
    final sharpness = (r - rNext).abs() + (g - gNext).abs() + (b - bNext).abs();
    sharpnessScore += sharpness;

    validPixelCount++;
  }

  if (validPixelCount == 0) {
    sendPort.send({});
    return;
  }

  final avgBrightness = totalBrightness / validPixelCount;
  final avgSaturation = totalSaturation / validPixelCount;
  final avgHue = totalHue / validPixelCount;
  final avgRed = totalRed / validPixelCount;
  final avgBlue = totalBlue / validPixelCount;
  final avgTemperature = (avgRed - avgBlue) / 255.0;
  final avgSharpness = sharpnessScore / validPixelCount;

  final mean = avgBrightness;
  final sumSquareDiffs =
  luminanceValues.fold(0.0, (acc, l) => acc + pow(l - mean, 2));
  final contrastStdDev = sqrt(sumSquareDiffs / validPixelCount);

  // Heuristic Adjustments
  double brightnessValue = ((128 - avgBrightness) / 255).clamp(-0.5, 0.5);
  double contrastValue = ((50 - contrastStdDev) / 100).clamp(-0.3, 0.5);
  double saturationValue = ((0.6 - avgSaturation) / 1.0).clamp(-0.3, 0.5);
  double exposureValue = ((200 - avgBrightness) / 255).clamp(-0.5, 0.5);
  double hueValue = ((180 - avgHue).abs() / 180).clamp(-0.3, 0.3); // shift if hue is too far from neutral
  double temperatureValue = avgTemperature.clamp(-0.3, 0.3);
  double sharpnessValue = ((avgSharpness - 10) / 100).clamp(-0.3, 0.3);
  double fadeValue = (1 - contrastStdDev / 100).clamp(-0.3, 0.3);
  double luminanceValue = avgBrightness / 255.0;

  sendPort.send({
    'brightness': brightnessValue,
    'contrast': contrastValue,
    'saturation': saturationValue,
    'exposure': exposureValue,
    'hue': hueValue,
    'temperature': temperatureValue,
    'sharpness': sharpnessValue,
    'fade': fadeValue,
    'luminance': luminanceValue,
  });
}


