/// Defines the cropping shape to apply to an image or video.
enum CropMode {
  /// Applies an oval crop. The resulting shape is an ellipse that may appear
  /// as a perfect circle when the aspect ratio is 1:1, or as an oval otherwise.
  /// Commonly used for avatars or soft-edged cropping.
  oval,

  /// Applies a bitmap mask crop using the configured mask image.
  ///
  /// The crop rectangle still controls the bounds, but the final visible
  /// pixels are shaped by the alpha channel of the configured mask image.
  mask,

  /// Applies a rectangular crop. The resulting shape is a rectangle
  /// and may include custom aspect ratios or sizes.
  rectangular,
}
