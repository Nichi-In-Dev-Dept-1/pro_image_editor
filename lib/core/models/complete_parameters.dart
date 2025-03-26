import 'dart:typed_data';

/// A data class that contains all parameters needed for applying visual
/// transformations and filters to a video frame or image.
///
/// Includes cropping, rotation, flipping, blur, and color adjustments.
class CompleteParameters {
  /// Creates a [CompleteParameters] instance with all required values.
  CompleteParameters({
    required this.blur,
    required this.colorFilters,
    required this.startTime,
    required this.endTime,
    required this.cropWidth,
    required this.cropHeight,
    required this.rotateTurns,
    required this.cropX,
    required this.cropY,
    required this.flipX,
    required this.flipY,
    required this.image,
  });

  /// The blur strength to apply (in logical pixels).
  final double blur;

  /// A 4x5 color matrix used for color adjustments.
  final List<List<double>> colorFilters;

  /// The time where processing should start.
  final Duration? startTime;

  /// The time where processing should end.
  final Duration? endTime;

  /// The target crop width in pixels (optional).
  final int? cropWidth;

  /// The target crop height in pixels (optional).
  final int? cropHeight;

  /// Number of clockwise 90° rotations to apply.
  final int rotateTurns;

  /// The horizontal crop offset (optional).
  final int? cropX;

  /// The vertical crop offset (optional).
  final int? cropY;

  /// Whether to flip the image horizontally.
  final bool flipX;

  /// Whether to flip the image vertically.
  final bool flipY;

  /// The image data as a [Uint8List].
  final Uint8List image;
}
