// Flutter imports:
import 'package:flutter/material.dart';

/// A custom painter for drawing the crop layer background and overlay.
///
/// This class extends [CustomPainter] and is used to draw the crop layer's
/// background and overlay for a crop and rotate editor. It supports both
/// rectangular and round crop shapes and handles image rotation effects.
class CropLayerPainter extends CustomPainter {
  /// Creates an instance of [CropLayerPainter].
  ///
  /// The constructor initializes various parameters needed to draw the crop
  /// layer's background and overlay, such as the image ratio, rotation
  /// settings, and visual appearance.
  ///
  /// Example:
  /// ```
  /// CropLayerPainter(
  ///   imgRatio: 1.5,
  ///   isRoundCropper: false,
  ///   is90DegRotated: true,
  ///   backgroundColor: Colors.black.withOpacity(0.5),
  ///   opacity: 0.8,
  /// )
  /// ```
  CropLayerPainter({
    required this.imgRatio,
    required this.isRoundCropper,
    required this.is90DegRotated,
    required this.backgroundColor,
    required this.opacity,
    this.interactiveViewerScale = 1,
    this.interactiveViewerOffset = Offset.zero,
    this.showCutOutFrame = false,
  });

  /// The aspect ratio of the image.
  ///
  /// This double value represents the aspect ratio of the image being edited,
  /// affecting how the crop layer is drawn and scaled.
  final double imgRatio;

  /// Indicates whether the image is rotated by 90 degrees.
  ///
  /// This boolean flag determines whether the image is currently rotated by 90
  /// degrees, affecting the orientation of the crop layer.
  final bool is90DegRotated;

  /// The background color of the crop layer.
  ///
  /// This [Color] is used to fill the background of the crop layer, providing
  /// contrast and focus for the cropping area.
  final Color backgroundColor;

  /// Indicates whether the crop shape is round.
  ///
  /// This boolean flag determines whether the crop layer should be drawn with
  /// a round shape, affecting the visual appearance of the cropping area.
  final bool isRoundCropper;

  /// The opacity of the crop layer.
  ///
  /// This double value represents the opacity of the crop layer, allowing for
  /// adjustable transparency to enhance the visual experience.
  final double opacity;

  /// The current scale factor of the InteractiveViewer.
  final double interactiveViewerScale;

  /// The current offset of the InteractiveViewer relative to its
  /// initial position.
  final Offset interactiveViewerOffset;

  /// Whether to show cut out frame
  final bool showCutOutFrame;

  @override
  void paint(Canvas canvas, Size size) {
    // if (opacity == 0 || imgRatio <= 0) return;
    _drawDarkenOutside(canvas: canvas, rawSize: size);
  }

  void _drawDarkenOutside({
    required Canvas canvas,
    required Size rawSize,
  }) {
    debugPrint('interactiveViewerOffset: $interactiveViewerOffset}');
    Size size = rawSize * interactiveViewerScale;
    var center = Offset(
          size.width / 2,
          size.height / 2,
        ) +
        interactiveViewerOffset;

    debugPrint('center: $center');
    Path path = Path()
      // FillType "evenOdd" is important for the canvas web renderer
      ..fillType = PathFillType.evenOdd
      ..addRect(Rect.fromCenter(
        center: center,
        width: size.width,
        height: size.height,
      ));

    double ratio = is90DegRotated ? 1 / imgRatio : imgRatio;

    double w = 0;
    double h = 0;

    size = Size(size.width, size.height);

    if (size.aspectRatio > ratio) {
      h = size.height;
      w = size.height * ratio;
    } else {
      w = size.width;
      h = size.width / ratio;
    }

    if (isRoundCropper) {
      Path rectPath = Path()
        ..addOval(
          Rect.fromCenter(
            center: center,
            width: w,
            height: h,
          ),
        );

      /// Subtract the area of the current rectangle from the path for the
      /// entire canvas
      path = Path.combine(PathOperation.difference, path, rectPath);

      /// Draw the darkened area
      canvas.drawPath(
        path,
        Paint()
          ..color = backgroundColor.withValues(alpha: opacity)
          ..style = PaintingStyle.fill,
      );
    } else {
     Size size = rawSize * interactiveViewerScale;
      Offset center = Offset(size.width / 2, size.height / 2) + interactiveViewerOffset;

      Path overlay = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

      double ratio = is90DegRotated ? 1 / imgRatio : imgRatio;
      double w, h;

      if (size.aspectRatio > ratio) {
        h = size.height;
        w = h * ratio;
      } else {
        w = size.width;
        h = w / ratio;
      }

      Rect cropRect = Rect.fromCenter(center: center, width: w, height: h);

      // subtract crop area
      overlay = Path.combine(
        PathOperation.difference,
        overlay,
        Path()..addRect(cropRect),
      );

      // Draw dark outside area
      canvas.drawPath(
        overlay,
        Paint()
          ..color = backgroundColor.withValues(alpha:opacity)
          ..style = PaintingStyle.fill,
      );
      debugPrint('show cut off frame : $showCutOutFrame');
      if(showCutOutFrame)
      _drawCornerHandles(canvas, cropRect);
    }
    debugPrint('draw dark area $backgroundColor & opacity $opacity');
  }

  /// Draw corner handles for the crop rectangle.
  void _drawCornerHandles(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = Colors.blueAccent
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.square;

    double L = 22;
    double t = 2.5;

    // Top Left
    canvas..drawLine(
        Offset(rect.left + t, rect.top + t),
        Offset(rect.left + t + L, rect.top + t),
        paint)
    ..drawLine(
        Offset(rect.left + t, rect.top + t),
        Offset(rect.left + t, rect.top + t + L),
        paint)

    // Top Right
    ..drawLine(
        Offset(rect.right - t, rect.top + t),
        Offset(rect.right - t - L, rect.top + t),
        paint)
    ..drawLine(
        Offset(rect.right - t, rect.top + t),
        Offset(rect.right - t, rect.top + t + L),
        paint)

    // Bottom Left
    ..drawLine(
        Offset(rect.left + t, rect.bottom - t),
        Offset(rect.left + t + L, rect.bottom - t),
        paint)
    ..drawLine(
        Offset(rect.left + t, rect.bottom - t),
        Offset(rect.left + t, rect.bottom - t - L),
        paint)

    // Bottom Right
    ..drawLine(
        Offset(rect.right - t, rect.bottom - t),
        Offset(rect.right - t - L, rect.bottom - t),
        paint)
    ..drawLine(
        Offset(rect.right - t, rect.bottom - t),
        Offset(rect.right - t, rect.bottom - t - L),
        paint);
  }


  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    debugPrint('inside should repaint: \noldDelegate & CropLayer changed ${ oldDelegate is! CropLayerPainter ||
        oldDelegate.imgRatio != imgRatio ||
        oldDelegate.is90DegRotated != is90DegRotated ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.opacity != opacity ||
        oldDelegate.interactiveViewerScale != interactiveViewerScale ||
        oldDelegate.interactiveViewerOffset != interactiveViewerOffset ||
        oldDelegate.is90DegRotated != is90DegRotated} '
        '\nimgRatio: $imgRatio is90DegRotated: $is90DegRotated & backgroundColor: $backgroundColor & opacity: $opacity');
    return oldDelegate is! CropLayerPainter ||
        oldDelegate.imgRatio != imgRatio ||
        oldDelegate.is90DegRotated != is90DegRotated ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.opacity != opacity ||
        oldDelegate.interactiveViewerScale != interactiveViewerScale ||
        oldDelegate.interactiveViewerOffset != interactiveViewerOffset ||
        oldDelegate.is90DegRotated != is90DegRotated;
  }
}
