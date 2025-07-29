// ignore_for_file: public_member_api_docs

import 'dart:math';

import 'package:flutter/material.dart';

/// Creates a paragraph with rounded background.
///
/// See also:
///
///  * [RichText], which this widget uses to render text.
///  * [TextPainter], which is used to calculate the line metrics.
///  * [TextStyle], used to customize the text look and feel.
///  * [RoundedBackgroundTextPainter], the painter used to draw the background.
class RoundedBackgroundText extends StatelessWidget {
  /// Creates a rounded background text with a single style.
  RoundedBackgroundText(
    String text, {
    super.key,
    TextStyle? style,
    this.textDirection,
    this.textAlign,
    this.backgroundColor,
    this.textWidthBasis,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.textHeightBehavior,
    this.onHitTestResult,
    this.maxTextWidth,
    this.enableHorizontalHitBox = true,
  }) : text = TextSpan(text: text, style: style);

  /// Creates a rounded background text based on an [InlineSpan], that can have
  /// multiple styles
  const RoundedBackgroundText.rich({
    super.key,
    required this.text,
    this.textDirection,
    this.backgroundColor,
    this.textAlign,
    this.textWidthBasis,
    this.ellipsis,
    this.locale,
    this.strutStyle,
    this.textScaler = TextScaler.noScaling,
    this.maxLines,
    this.textHeightBehavior,
    this.onHitTestResult,
    this.maxTextWidth,
    this.enableHorizontalHitBox = true,
  });

  final Function(bool hasHit)? onHitTestResult;

  /// The text to display in this widget.
  final InlineSpan text;

  /// The directionality of the text.
  final TextDirection? textDirection;

  /// {@template rounded_background_text.background_color}
  /// The text background color.
  ///
  /// If null, a transparent color will be used.
  /// {@endtemplate}
  final Color? backgroundColor;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// An optional maximum number of lines for the text to span, wrapping if
  /// necessary.
  /// If the text exceeds the given number of lines, it will be truncated.
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  final int? maxLines;

  /// {@macro flutter.dart:ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// The string used to ellipsize overflowing text.
  final String? ellipsis;

  final double? maxTextWidth;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with
  /// `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// The number of font pixels for each logical pixel.
  ///
  /// For example, if the text scale factor is 1.5, text will be 50% larger than
  /// the specified font size.
  final TextScaler textScaler;

  final bool enableHorizontalHitBox;

  double getLineHeight(TextStyle style) {
    final span = TextSpan(text: 'X', style: style);
    final painter = TextPainter(
      text: span,
      textAlign: TextAlign.left,
      textDirection: TextDirection.ltr,
    )..layout();

    final metrics = painter.computeLineMetrics();
    final actualHeight = metrics.first.ascent + metrics.first.descent;

    return actualHeight;
  }

  @override
  Widget build(BuildContext context) {
    final defaultTextStyle = DefaultTextStyle.of(context);
    final style = text.style ?? defaultTextStyle.style;
    final align = textAlign ?? defaultTextStyle.textAlign ?? TextAlign.start;

    final painter = TextPainter(
      text: TextSpan(
        children: [text],
        style: const TextStyle(
          leadingDistribution: TextLeadingDistribution.proportional,
        ).merge(style),
      ),
      textDirection:
          textDirection ?? Directionality.maybeOf(context) ?? TextDirection.ltr,
      maxLines: maxLines ?? defaultTextStyle.maxLines,
      textAlign: align,
      textWidthBasis: textWidthBasis ?? defaultTextStyle.textWidthBasis,
      textScaler: textScaler,
      strutStyle: strutStyle,
      locale: locale,
      textHeightBehavior:
          textHeightBehavior ?? defaultTextStyle.textHeightBehavior,
      ellipsis: ellipsis,
    );

    double height = getLineHeight(style);
    const horizontalPaddingFactor = 0.3;
    double horizontalSpace =
        enableHorizontalHitBox ? height * horizontalPaddingFactor : 0;
    double bottomSpace = height * 0.0875;

    return LayoutBuilder(builder: (context, constraints) {
      painter.layout(
        maxWidth: maxTextWidth != null
            ? maxTextWidth! - horizontalSpace
            : constraints.maxWidth,
        minWidth: constraints.minWidth,
      );
      return CustomPaint(
        isComplex: true,
        foregroundPainter: RoundedBackgroundTextPainter(
          backgroundColor: backgroundColor ?? Colors.transparent,
          text: painter,
          onHitTestResult: onHitTestResult,
          horizontalPadding: horizontalSpace,
          textAlign: align,
        ),
        child: SizedBox(
          width: painter.width.clamp(0, constraints.maxWidth) +
              horizontalSpace * 2,
          height: painter.height.clamp(0, constraints.maxHeight) + bottomSpace,
        ),
      );
    });
  }
}

class RoundedBackgroundTextPainter extends CustomPainter {
  const RoundedBackgroundTextPainter({
    required this.backgroundColor,
    required this.text,
    this.innerRadius = 8.0,
    this.outerRadius = 10.0,
    required this.onHitTestResult,
    required this.horizontalPadding,
    required this.textAlign,
  });

  final Function(bool hasHit)? onHitTestResult;

  final Color backgroundColor;
  final TextPainter text;
  final TextAlign textAlign;

  final double horizontalPadding;
  final double innerRadius;
  final double outerRadius;

  /// Compute the lines used by [RoundedBackgroundTextPainter].
  ///
  /// The text [painter] must have been already laid out:
  /// ```dart
  /// final painter = TextPainter(
  ///  text: const TextSpan(text: testText),
  /// );
  /// painter.layout();
  /// final lines = RoundedBackgroundTextPainter.computeLines(painter);
  /// ```
  static List<List<LineMetricsHelper>> computeLines(
    TextPainter painter,
    TextAlign textAlign,
  ) {
    final metrics = painter.computeLineMetrics();

    final helpers = metrics.map((lineMetric) {
      return LineMetricsHelper(lineMetric, metrics.length, textAlign);
    });

    final List<List<LineMetricsHelper>> lineInfos = [[]];

    for (final line in helpers) {
      if (line.isEmpty) {
        lineInfos.add([]);
      } else {
        lineInfos.last.add(line);
      }
    }

    return lineInfos;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final lineInfos = computeLines(text, textAlign);
    if (lineInfos.isEmpty) return;
    final metrics = text.computeLineMetrics();

    final painter = Paint()..color = backgroundColor;
    final cornerPainter = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255);
    final path = Path();
    final cornerPath = Path();
    double endY = 0;

    double maxWidth = 0;
    EdgeInsets outsidePadding = EdgeInsets.zero;
    bool isLeftAlign = textAlign == TextAlign.left;
    bool isRightAlign = textAlign == TextAlign.right;
    bool isCenterAlign = textAlign == TextAlign.center;

    final helpers = metrics.map((lineMetric) {
      return LineMetricsHelper(lineMetric, metrics.length, textAlign);
    }).toList();

    double? firstMaximalWidth;

    /// Draw a simple rounded rect behind every text.
    for (int index = 0; index < helpers.length; index++) {
      final info = helpers[index];
      if (info.isEmpty) continue;

      final double paddingHorizontal = info.rawHeight * 0.3;
      final double paddingVertical = info.rawHeight * 0.1;
      final double radius = info.innerRadius(innerRadius);

      final bool hasNoLineBefore = index == 0 || helpers[index - 1].isEmpty;
      final bool hasNoLineAfter =
          index == helpers.length - 1 || helpers[index + 1].isEmpty;

      void connectSimilarLineWidth() {
        final maxLineDifference = radius * (isCenterAlign ? 4 : 2);

        bool shouldConnect(int index) {
          if (index >= helpers.length - 1) return false;

          final currentLine = helpers[index];
          final nextLine = helpers[index + 1];

          /// Check first if it's necessary to calculate the minimum width
          double lineDifference = currentLine.rawWidth - nextLine.rawWidth;
          bool shouldConnect = lineDifference.abs() < maxLineDifference;
          return shouldConnect;
        }

        if (!shouldConnect(index)) return;

        double minimumWidth = info.rawWidth;
        double minimumX = info.x;
        int endIndex = index;

        /// Find the minimum required width
        for (var i = index; i < helpers.length; i++) {
          final helper = helpers[i];
          if (helper.rawWidth > minimumWidth) {
            minimumWidth = helper.rawWidth;
            minimumX = helper.x;
          }
          if (!shouldConnect(i)) {
            endIndex = i;
            break;
          }
        }

        /// Apply changes
        for (var i = index; i <= endIndex; i++) {
          helpers[i]
            ..overrideX = minimumX
            ..overrideWidth = minimumWidth;

          if (i == index) {
            helpers[i]
              ..roundBottomLeft = false
              ..roundBottomRight = false;
          }
          if (i == endIndex) {
            helpers[i]
              ..roundTopLeft = false
              ..roundTopRight = false;
          }
        }
      }

      if (!hasNoLineAfter && !info.isOverriden) connectSimilarLineWidth();

      bool roundTopRight =
          (!isRightAlign || hasNoLineBefore) && info.roundTopRight;
      bool roundTopLeft =
          (!isLeftAlign || hasNoLineBefore) && info.roundTopLeft;
      bool roundBottomRight =
          (!isRightAlign || hasNoLineAfter) && info.roundBottomRight;
      bool roundBottomLeft =
          (!isLeftAlign || hasNoLineAfter) && info.roundBottomLeft;

      final double startX = info.startX - paddingHorizontal;
      late final double endX;
      if (isRightAlign) {
        firstMaximalWidth ??= info.endX + paddingHorizontal;
        endX = firstMaximalWidth;
      } else {
        endX = info.endX + paddingHorizontal;
      }

      final double startY = info.startY - paddingVertical;
      final double endY = info.endY + paddingVertical;

      void generateBackgroundRectangle() {
        path
          ..moveTo(startX + (roundTopLeft ? radius : 0), startY)

          /// Top-Right edge
          ..lineTo(endX - radius, startY);
        if (roundTopRight) {
          path.arcToPoint(
            Offset(endX, startY + radius),
            radius: Radius.circular(radius),
          );
        } else {
          path.lineTo(endX, startY);
        }

        /// Bottom-Right edge
        path.lineTo(endX, endY - (roundBottomRight ? radius : 0));
        if (roundBottomRight) {
          path.arcToPoint(
            Offset(endX - radius, endY),
            radius: Radius.circular(radius),
          );
        } else {
          path.lineTo(endX - radius, endY);
        }

        /// Bottom edge
        path.lineTo(startX + (roundBottomLeft ? radius : 0), endY);
        if (roundBottomLeft) {
          path.arcToPoint(
            Offset(startX, endY - radius),
            radius: Radius.circular(radius),
          );
        } else {
          path.lineTo(startX, endY);
        }

        /// Left edge
        path.lineTo(startX, startY + (roundTopLeft ? radius : 0));
        if (roundTopLeft) {
          path.arcToPoint(
            Offset(startX + radius, startY),
            radius: Radius.circular(radius),
          );
        } else {
          path.lineTo(startX, startY);
        }

        path.close();
      }

      double calculateAdaptiveRadius() {
        final lineBefore = helpers[index - 1];

        double lineDifference = (info.rawWidth - lineBefore.rawWidth).abs();

        if (textAlign == TextAlign.center) {
          lineDifference /= 4;
        } else {
          lineDifference /= 2;
        }

        return min(radius, lineDifference);
      }

      void drawInnerRoundingPath({
        required Offset from,
        required double lineToX,
        required Offset arcEnd,
        required double radius,
        required bool clockwise,
      }) {
        final radiusC = Radius.circular(radius);

        cornerPath
          ..moveTo(from.dx, from.dy)
          ..lineTo(lineToX, from.dy)
          ..arcToPoint(arcEnd, radius: radiusC, clockwise: clockwise)
          ..moveTo(from.dx, from.dy)
          ..lineTo(lineToX, from.dy)
          ..arcToPoint(arcEnd,
              radius: radiusC, clockwise: clockwise, largeArc: true)
          ..close();
      }

      void drawInnerRoundingLeft() {
        final lineBefore = helpers[index - 1];
        if (lineBefore.isEmpty) return;

        final beforeStartX = lineBefore.startX - paddingHorizontal;
        final beforeY = lineBefore.endY + paddingVertical;
        final startX = info.startX - paddingHorizontal;
        final r = calculateAdaptiveRadius();

        if (info.rawWidth > lineBefore.rawWidth) {
          drawInnerRoundingPath(
            from: Offset(beforeStartX, startY),
            lineToX: beforeStartX - r,
            arcEnd: Offset(beforeStartX, startY - r),
            radius: r,
            clockwise: false,
          );
        } else {
          drawInnerRoundingPath(
            from: Offset(startX, beforeY),
            lineToX: startX - r,
            arcEnd: Offset(startX, beforeY + r),
            radius: r,
            clockwise: true,
          );
        }
      }

      void drawInnerRoundingRight() {
        final lineBefore = helpers[index - 1];
        if (lineBefore.isEmpty) return;

        final beforeEndX = lineBefore.endX + paddingHorizontal;
        final beforeY = lineBefore.endY + paddingVertical;
        final endX = info.endX + paddingHorizontal;
        final r = calculateAdaptiveRadius();

        if (info.rawWidth > lineBefore.rawWidth) {
          drawInnerRoundingPath(
            from: Offset(beforeEndX, startY),
            lineToX: beforeEndX + r,
            arcEnd: Offset(beforeEndX, startY - r),
            radius: r,
            clockwise: true,
          );
        } else {
          drawInnerRoundingPath(
            from: Offset(endX, beforeY),
            lineToX: endX + r,
            arcEnd: Offset(endX, beforeY + r),
            radius: r,
            clockwise: false,
          );
        }
      }

      generateBackgroundRectangle();

      if (!hasNoLineBefore) {
        if (!isLeftAlign) drawInnerRoundingLeft();
        if (!isRightAlign) drawInnerRoundingRight();
      }
    }

    /// Close all outside holes where the text align.
    switch (textAlign) {
      case TextAlign.right:
        canvas.drawRect(
          Rect.fromLTRB(
            maxWidth - outsidePadding.left,
            outsidePadding.top,
            maxWidth,
            endY - outsidePadding.vertical,
          ),
          painter,
        );
        break;
      case TextAlign.left:
        canvas.drawRect(
          Rect.fromLTRB(
            -outsidePadding.left,
            outsidePadding.top,
            0,
            endY - outsidePadding.vertical,
          ),
          painter,
        );
        break;
      default:
    }

    canvas
      ..drawPath(path, painter)
      ..drawPath(cornerPath, cornerPainter);
    text.paint(canvas, Offset(horizontalPadding, 0.0));
  }

  @override
  bool shouldRepaint(covariant RoundedBackgroundTextPainter oldDelegate) {
    return oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.text.width != text.width ||
        oldDelegate.text.height != text.height ||
        oldDelegate.text.ellipsis != text.ellipsis ||
        oldDelegate.text.plainText != text.plainText ||
        oldDelegate.text.textAlign != text.textAlign ||
        oldDelegate.text.preferredLineHeight != text.preferredLineHeight ||
        oldDelegate.innerRadius != innerRadius ||
        oldDelegate.outerRadius != outerRadius;
  }

  @override
  bool? hitTest(Offset position) {
    // Retrieve the line information
    /* FIXME: final lineInfos = computeLines(text, textAlign);

    // Check each line
  for (final lineInfo in lineInfos) {
      for (final info in lineInfo) {
        // Construct the rounded rectangle for this line
        final rRect = _getRRect(info);

        // Check if the position is within this rectangle
        if (rRect.contains(position)) {
          onHitTestResult?.call(true);
          return true;
        }
      }
    } */

    // If the position was not within any line's bounding box
    onHitTestResult?.call(false);
    return false;
  }
}

/// A helper class that holds important information about a single line metrics.
/// This is used to calculate the position of the line in the paragraph.
class LineMetricsHelper {
  /// Creates a new line metrics helper
  LineMetricsHelper(this.metrics, this.length, this.textAlign);

  bool get isOverriden => overrideWidth != null || overrideX != null;
  double? overrideWidth;
  double? overrideX;
  bool roundTopLeft = true;
  bool roundBottomLeft = true;
  bool roundTopRight = true;
  bool roundBottomRight = true;

  final TextAlign textAlign;

  /// The original line metrics, which stores the measurements and statistics of
  /// a single line in the paragraph.
  final LineMetrics metrics;

  /// The amount of lines in the text.
  ///
  /// See also:
  ///
  ///  * [isLast], which uses this property to check the amount of lines
  final int length;

  /// Whether this line has no content
  bool get isEmpty => rawWidth == 0.0;

  /// Whether this line is the first line in the paragraph
  bool get isFirst => metrics.lineNumber == 0;

  /// Whether this line is the last line in the paragraph
  bool get isLast => metrics.lineNumber == length - 1;

  /// Dynamically calculate the outer factor based on the provided [outerRadius]
  double outerRadius(double outerRadius) => (rawHeight * outerRadius) / 35;

  /// Dynamically calculate the inner factor based on the provided [innerRadius]
  double innerRadius(double innerRadius) => (rawHeight * innerRadius) / 35;

  double get startX => x;
  double get endX => x + rawWidth;

  double get startY => y;
  double get endY => y + rawHeight;

  /// The x position of the line
  double get x {
    if (overrideX != null) return overrideX!;
    double alignHelper = 0.0;
    if (textAlign == TextAlign.center) {
      alignHelper = 1.5;
    } else if (textAlign == TextAlign.right) {
      alignHelper = 3.0;
    }

    double result = metrics.left - alignHelper;

    return result.roundToDouble();
  }

  /// The y position of the line
  double get y => metrics.baseline - metrics.ascent;

  /// The raw height of the line, without any additional padding
  double get rawHeight => metrics.ascent + metrics.descent;

  /// The raw width of the line, without any additional padding
  double get rawWidth => overrideWidth ?? metrics.width;

  /// The entire width of the line, including the padding and its [x]
  double get fullWidth => x + rawWidth;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is LineMetricsHelper &&
        other.metrics == metrics &&
        other.length == length;
  }

  @override
  int get hashCode {
    return metrics.hashCode ^ length.hashCode;
  }
}
