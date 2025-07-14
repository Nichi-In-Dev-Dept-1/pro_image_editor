// Flutter imports:
import 'package:flutter/material.dart';

import '../models/painted_model.dart';
import '../services/paint_item_hit_test_manager.dart';
import '../utils/paint_element.dart';

/// Handles the paint ongoing on the canvas.
class DrawPaintItem extends CustomPainter {
  /// Constructor for the canvas.
  DrawPaintItem({
    this.selected = false,
    required this.item,
    this.onHitChanged,
    this.scale = 1,
    this.enabledHitDetection = false,
    this.freeStyleHighPerformance = false,
  });

  /// The model containing information about the painting.
  final PaintedModel item;

  final PaintElement _paintModeHelper = PaintElement();

  /// The scaling factor applied to the canvas.
  final double scale;

  /// Controls high-performance for free-style drawing.
  bool freeStyleHighPerformance = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the interface.
  bool enabledHitDetection = true;

  /// Indicates whether the layer is currently selected.
  bool selected = true;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit)? onHitChanged;

  final _hitTestManager = PaintItemHitTestManager();

  @override
  void paint(Canvas canvas, Size size) {
    _paintModeHelper.drawElement(
      canvas: canvas,
      size: size,
      item: item,
      scale: scale,
      freeStyleHighPerformance: freeStyleHighPerformance,
    );
  }

  @override
  bool shouldRepaint(DrawPaintItem oldDelegate) {
    return oldDelegate.item != item ||
        oldDelegate.freeStyleHighPerformance != freeStyleHighPerformance;
  }

  @override
  bool hitTest(Offset position) {
    bool hasHit = _hitTestManager.hitTest(
      item: item,
      position: position,
      enabledHitDetection: enabledHitDetection,
      isSelected: selected,
      scaleFactor: scale,
    );
    onHitChanged?.call(hasHit);
    return hasHit;
  }
}
