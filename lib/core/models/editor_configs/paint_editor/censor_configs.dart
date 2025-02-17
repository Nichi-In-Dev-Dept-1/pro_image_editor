/// A configuration class for defining blur settings for censoring content.
class CensorConfigs {
  /// Creates a new instance of [CensorConfigs].
  ///
  /// - [blurSigmaX]: The standard deviation for the Gaussian blur in the
  ///   horizontal direction.
  /// - [blurSigmaY]: The standard deviation for the Gaussian blur in the
  ///   vertical direction.
  /// - [pixelatePixelSize]: The size of the pixels used for pixelation effect
  ///   in the paint editor.
  /// - [enableRoundArea]: A boolean flag to enable or disable the use of a
  /// round area for the censor tool instant of a rectangle area.
  ///
  /// Both values default to `14.0`.
  const CensorConfigs({
    this.blurSigmaX = 14.0,
    this.blurSigmaY = 14.0,
    this.pixelatePixelSize = 40.0,
    this.enableRoundArea = false,
  });

  /// The standard deviation for the Gaussian blur in the horizontal direction.
  ///
  /// **Default** `14.0`
  final double blurSigmaX;

  /// The standard deviation for the Gaussian blur in the vertical direction.
  ///
  /// **Default** `14.0`
  final double blurSigmaY;

  /// The size of the pixels used for pixelation effect in the paint editor.
  ///
  /// This value determines how large each pixel will be when applying the
  /// pixelation effect to an image. A larger value will result in a more
  /// pronounced pixelation effect, while a smaller value will produce a finer
  /// pixelation.
  ///
  /// **Default** `40.0`
  final double pixelatePixelSize;

  /// A boolean flag to enable or disable the use of a round area for the
  /// censor tool instant of a rectangle area.
  ///
  /// **Default** `false`
  final bool enableRoundArea;

  /// Returns a new [CensorConfigs] instance with updated values.
  ///
  /// If a parameter is not provided, the existing value is retained.
  ///
  /// - [blurSigmaX]: New value for the horizontal blur, if provided.
  /// - [blurSigmaY]: New value for the vertical blur, if provided.
  /// - [enableRoundArea]: New value for the enableRoundArea, if provided.
  CensorConfigs copyWith({
    double? blurSigmaX,
    double? blurSigmaY,
    double? pixelatePixelSize,
    bool? enableRoundArea,
  }) {
    return CensorConfigs(
      blurSigmaX: blurSigmaX ?? this.blurSigmaX,
      blurSigmaY: blurSigmaY ?? this.blurSigmaY,
      pixelatePixelSize: pixelatePixelSize ?? this.pixelatePixelSize,
      enableRoundArea: enableRoundArea ?? this.enableRoundArea,
    );
  }
}
