import 'dart:isolate';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';

/// This class is for fetching image and calculating the auto tune value for
/// the user-selected image
class HeuristicRequest {
  /// contractor
  HeuristicRequest(this.imageBytes);

  /// variable for storing the selected image
  final Uint8List imageBytes;
}

/// This function fetches the image and cal the auto tune value.
Future<Map<String, double>?> computeHeuristicAdjustmentsIsolate(
    Uint8List imageBytes) async {
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

    final brightness = 0.299 * r + 0.587 * g + 0.114 * b;
    totalBrightness += brightness;
    luminanceValues.add(brightness);

    final maxRGB = [r, g, b].reduce(max);
    final minRGB = [r, g, b].reduce(min);
    final lightness = (maxRGB + minRGB) / 2;

    double saturation = 0.0;
    final delta = maxRGB - minRGB;
    if (delta != 0) {
      saturation = (lightness == 0 || lightness == 255)
          ? 0
          : delta / (1 - ((2 * lightness / 255.0) - 1).abs());
    }
    totalSaturation += saturation;

    double hue = 0;
    if (delta != 0) {
      if (maxRGB == r) {
        hue = ((g - b) / delta) % 6;
      } else if (maxRGB == g) {
        hue = ((b - r) / delta) + 2;
      } else {
        hue = ((r - g) / delta) + 4;
      }
      hue *= 60;
      if (hue < 0) hue += 360;
    }
    totalHue += hue;

    totalRed += r;
    totalBlue += b;

    if (i + 8 < length) {
      final rNext = pixels[i + 4].toDouble();
      final gNext = pixels[i + 5].toDouble();
      final bNext = pixels[i + 6].toDouble();

      final rNext2 = pixels[i + 8].toDouble();
      final gNext2 = pixels[i + 9].toDouble();
      final bNext2 = pixels[i + 10].toDouble();

      final sharpness =
          ((r - rNext).abs() + (g - gNext).abs() + (b - bNext).abs()) +
              ((r - rNext2).abs() + (g - gNext2).abs() + (b - bNext2).abs());
      sharpnessScore += sharpness / 2;
    }

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
  final sumSquareDiffs = luminanceValues.fold(
    0.0,
    (acc, l) => acc + pow(l - mean, 2),
  );
  final contrastStdDev = sqrt(sumSquareDiffs / validPixelCount);

  final avgBrightnessNormalized = avgBrightness / 255.0;

  double brightnessValue = (0.6 - avgBrightnessNormalized).clamp(0.0, 0.2);
  double contrastValue =
      ((contrastStdDev < 60) ? (60 - contrastStdDev) / 128.0 : 0.0)
          .clamp(0.0, 0.4);
  double saturationValue = (0.6 - avgSaturation).clamp(-0.1, 0.2);
  double exposureValue = ((avgBrightness - 127.5) / 127.5).clamp(-0.2, 0.2);
  double hueValue = ((avgHue - 120) / 180).clamp(-0.25, 0.25);
  double temperatureValue = avgTemperature.clamp(-0.1, 0.1);
  double sharpnessValue = ((avgSharpness - 20) / 100).clamp(0.0, 0.3);
  double fadeValue = (contrastStdDev > 80)
      ? ((contrastStdDev - 80) / 200).clamp(0.0, 0.1)
      : 0.0;
  double luminanceValue = (avgBrightnessNormalized - 0.5).clamp(-0.2, 0.2);

  debugPrint('validPixelCount: $validPixelCount\n'
      'avgBrightnessNormalized; $avgBrightnessNormalized,\n'
      'avgbrightnessValue:$avgBrightness,\n'
      'brightnessValue: $brightnessValue \n'
      'sumSquareDiffs: $sumSquareDiffs,\n'
      'avgConstrastValue: $contrastStdDev,\n'
      'contrastValue: $contrastValue \n'
      'exposureValue: $exposureValue \n'
      'totalHue: $totalHue,\n'
      'avgHue: $avgHue,\n'
      'hueValue: $hueValue \n'
      'avgRed: $avgRed,\n'
      'avgRed: $avgBlue,\n'
      'avgTemperature: $avgTemperature,\n'
      'temperatureValue: $temperatureValue \n'
      'sharpnessScore: $sharpnessScore,\n'
      'avgSharpness: $avgSharpness,\n'
      'sharpnessValue: $sharpnessValue \n'
      'contrastStdDev: $contrastStdDev,\n'
      'fadeValue: $fadeValue \n');

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
