import 'dart:math';
import 'dart:ui';

import '../../../shared/utils/platform_info.dart';
import '../enums/paint_editor_enum.dart';
import '../models/painted_model.dart';
import '../utils/paint_element.dart';

/// A manager class responsible for handling hit testing of paint items
/// within the paint editor feature. This class provides functionality
/// to determine whether a specific paint item has been interacted with
/// (e.g., tapped or selected) based on user input or other criteria.
class PaintItemHitTestManager {
  /// Performs a hit test to determine if a given point intersects with a
  /// paint item.
  bool hitTest({
    required PaintedModel item,
    required Offset position,
    bool enabledHitDetection = true,
    bool isSelected = false,
    bool isRoundCensorArea = false,
    required double scaleFactor,
  }) {
    if (!enabledHitDetection) {
      return true;
    } else if (isSelected) {
      item.hit = true;
      return true;
    }

    List<Offset?> offsets = item.offsets;
    double strokeW = isDesktop
        ? item.strokeWidth * scaleFactor
        : max(item.strokeWidth * scaleFactor, 30);
    double strokeHalfW = strokeW / 2;

    switch (item.mode) {
      case PaintMode.line:
      case PaintMode.dashLine:
      case PaintMode.arrow:
        item.hit = _detectLineStrokeHit(
          start: offsets[0]! * scaleFactor,
          end: offsets[1]! * scaleFactor,
          position: position,
          strokeHalfWidth: strokeHalfW,
        );
        break;
      case PaintMode.freeStyle:
        item.hit = false;
        for (int i = 0; i < offsets.length - 1; i++) {
          if (offsets[i] != null && offsets[i + 1] != null) {
            if (_detectFreeStyleHit(
              start: offsets[i]! * scaleFactor,
              end: offsets[i + 1]! * scaleFactor,
              position: position,
              strokeHalfWidth: strokeHalfW,
            )) {
              item.hit = true;
              break;
            }
          } else if (offsets[i] != null && offsets[i + 1] == null) {
            // Check if the position is within touchTolerance of a point
            if (offsets[i]!.distance * scaleFactor <= strokeHalfW) {
              item.hit = true;
              break;
            }
          }
        }
        break;
      case PaintMode.rect:
        item.hit = _detectRectangularHit(
          item: item,
          scaleFactor: scaleFactor,
          strokeW: strokeW,
          position: position,
        );
        break;
      case PaintMode.circle:
        item.hit = _detectCircleHit(
          item: item,
          scaleFactor: scaleFactor,
          strokeW: strokeW,
          position: position,
        );
        break;
      case PaintMode.polygon:
        item.hit = _detectPolygonHit(
          item: item,
          scaleFactor: scaleFactor,
          strokeHalfW: strokeHalfW,
          position: position,
          offsets: offsets,
        );
        break;
      case PaintMode.blur:
      case PaintMode.pixelate:
        item.hit = _detectCensorAreaHit(
          item: item,
          scaleFactor: scaleFactor,
          position: position,
          isRoundArea: isRoundCensorArea,
        );
      default:
        item.hit = true;
    }

    return item.hit;
  }

  bool _detectFreeStyleHit({
    required Offset start,
    required Offset end,
    required double strokeHalfWidth,
    required Offset position,
  }) {
    if (start.dx.isNaN ||
        start.dy.isNaN ||
        end.dx.isNaN ||
        end.dy.isNaN ||
        strokeHalfWidth.isNaN ||
        position.dx.isNaN ||
        position.dy.isNaN) {
      // Handle NaN values gracefully, e.g., return false or throw an error.
      return false;
    }
    final path = Path();

    // Calculate the vector from start to end
    Offset vector = end - start;

    // Calculate the normalized vector
    Offset normalizedVector = vector / max(vector.distance, 0.00001);

    // Calculate the perpendicular vector
    Offset perpendicularVector =
        Offset(-normalizedVector.dy, normalizedVector.dx);

    // Define the four points that represent the rounded line
    Offset startPoint = start + perpendicularVector * strokeHalfWidth;
    Offset endPoint = end + perpendicularVector * strokeHalfWidth;
    Offset startCap = start - perpendicularVector * strokeHalfWidth;
    Offset endCap = end - perpendicularVector * strokeHalfWidth;
    // Move to the starting point
    path
      ..moveTo(startPoint.dx, startPoint.dy)

      // Add a straight line segment to the ending point
      ..lineTo(endPoint.dx, endPoint.dy)

      // Add rounded caps at both ends
      ..arcToPoint(
        startCap,
        radius: Radius.circular(strokeHalfWidth),
        clockwise: false,
      )
      ..arcToPoint(
        endCap,
        radius: Radius.circular(strokeHalfWidth),
        clockwise: false,
      )

      // Close the path
      ..close();

    // Check if the position is inside the path
    return path.contains(position);
  }

  bool _detectRectangularHit({
    required PaintedModel item,
    required double scaleFactor,
    required double strokeW,
    required Offset position,
  }) {
    final rect = Rect.fromPoints(
        item.offsets[0]! * scaleFactor, item.offsets[1]! * scaleFactor);
    if (item.fill) {
      return rect.contains(position);
    } else {
      final path = Path();
      final insideStrokePath = Path();

      var strokeRect = Rect.fromPoints(
          item.offsets[0]! * scaleFactor, item.offsets[1]! * scaleFactor);
      double centerX = (strokeRect.left + strokeRect.right) / 2;
      double centerY = (strokeRect.top + strokeRect.bottom) / 2;

      final innerWidth =
          (strokeRect.width - strokeW).clamp(0.0, double.infinity);
      final innerHeight =
          (strokeRect.height - strokeW).clamp(0.0, double.infinity);

      path.addRect(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: strokeRect.width + strokeW,
          height: strokeRect.height + strokeW,
        ),
      );

      if (innerWidth > 0 && innerHeight > 0) {
        insideStrokePath.addRect(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: strokeRect.width - strokeW,
            height: strokeRect.height - strokeW,
          ),
        );
      }
      return path.contains(position) && !insideStrokePath.contains(position);
    }
  }

  bool _detectCircleHit({
    required PaintedModel item,
    required double scaleFactor,
    required double strokeW,
    required Offset position,
  }) {
    final path = Path();
    final insideStrokePath = Path();
    if (item.fill) {
      path.addOval(Rect.fromPoints(
          item.offsets[0]! * scaleFactor, item.offsets[1]! * scaleFactor));
    } else {
      var ovalRect = Rect.fromPoints(
          item.offsets[0]! * scaleFactor, item.offsets[1]! * scaleFactor);
      double centerX = (ovalRect.left + ovalRect.right) / 2;
      double centerY = (ovalRect.top + ovalRect.bottom) / 2;

      final innerWidth = (ovalRect.width - strokeW).clamp(0.0, double.infinity);
      final innerHeight =
          (ovalRect.height - strokeW).clamp(0.0, double.infinity);

      path.addOval(
        Rect.fromCenter(
          center: Offset(centerX, centerY),
          width: ovalRect.width + strokeW,
          height: ovalRect.height + strokeW,
        ),
      );

      if (innerWidth > 0 && innerHeight > 0) {
        insideStrokePath.addOval(
          Rect.fromCenter(
            center: Offset(centerX, centerY),
            width: ovalRect.width - strokeW,
            height: ovalRect.height - strokeW,
          ),
        );
      }
    }
    return path.contains(position) && !insideStrokePath.contains(position);
  }

  bool _detectPolygonHit({
    required PaintedModel item,
    required double scaleFactor,
    required double strokeHalfW,
    required Offset position,
    required List<Offset?> offsets,
  }) {
    final polygonOffsets =
        offsets.whereType<Offset>().map((o) => o * scaleFactor).toList();

    if (polygonOffsets.length < 2) {
      return false;
    }

    bool isClosed = (polygonOffsets.first - polygonOffsets.last).distance < 0.5;
    final pointCount = polygonOffsets.length;

    item.hit = false;

    // Check if inside if it's a filled polygon
    if (item.fill && polygonOffsets.length >= 3) {
      final path =
          PaintElement().drawPolygon(offsets: offsets, scale: scaleFactor);
      if (path != null && path.contains(position)) {
        return true;
      }
    }

    // Otherwise check each edge
    for (int i = 0; i < pointCount - 1; i++) {
      if (_detectLineStrokeHit(
        start: polygonOffsets[i],
        end: polygonOffsets[i + 1],
        strokeHalfWidth: strokeHalfW,
        position: position,
      )) {
        return true;
      }
    }

    // Also check closing edge if polygon is closed
    if (!item.hit && isClosed && polygonOffsets.length >= 3) {
      if (_detectLineStrokeHit(
        start: polygonOffsets.last,
        end: polygonOffsets.first,
        strokeHalfWidth: strokeHalfW,
        position: position,
      )) {
        return true;
      }
    }
    return false;
  }

  bool _detectLineStrokeHit({
    required Offset start,
    required Offset end,
    required double strokeHalfWidth,
    required Offset position,
  }) {
    final vector = end - start;
    final normalizedVector = vector / vector.distance;
    final perpendicularVector =
        Offset(-normalizedVector.dy, normalizedVector.dx);

    double x = perpendicularVector.dx * strokeHalfWidth;
    double y = perpendicularVector.dy * strokeHalfWidth;

    final path = Path()
      ..moveTo(
        start.dx + x,
        start.dy + y,
      )
      ..lineTo(
        end.dx + x,
        end.dy + y,
      )
      ..lineTo(
        end.dx - x,
        end.dy - y,
      )
      ..lineTo(
        start.dx - x,
        start.dy - y,
      )
      ..close();

    // Check if the position is inside the stroke path
    return path.contains(position);
  }

  bool _detectCensorAreaHit({
    required PaintedModel item,
    required double scaleFactor,
    required Offset position,
    required bool isRoundArea,
  }) {
    final start = item.offsets[0]! * scaleFactor;
    final end = item.offsets[1]! * scaleFactor;

    if (isRoundArea) {
      final path = Path()..addOval(Rect.fromPoints(start, end));
      return path.contains(position);
    } else {
      final rect = Rect.fromPoints(start, end);
      return rect.contains(position);
    }
  }
}
