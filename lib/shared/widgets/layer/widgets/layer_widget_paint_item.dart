import 'package:flutter/material.dart';

import '/core/models/layers/paint_layer.dart';
import '/features/paint_editor/enums/paint_editor_enum.dart';
import '/features/paint_editor/widgets/draw_paint_item.dart';
import '/shared/utils/platform_info.dart';

/// A widget representing a paint layer in the sticker editor.
class LayerWidgetPaintItem extends StatelessWidget {
  /// Creates a [LayerWidgetPaintItem] with the given paint layer and
  /// configuration settings.
  const LayerWidgetPaintItem({
    super.key,
    required this.layer,
    required this.scale,
    required this.isSelected,
    required this.enableHitDetection,
    required this.isHighPerformanceMode,
    required this.onHitChanged,
  });

  /// The paint layer represented by this widget.
  final PaintLayer layer;

  /// The scaling factor applied to the paint layer.
  final double scale;

  /// Whether the paint layer is currently selected.
  final bool isSelected;

  /// Whether hit detection is enabled for this layer.
  final bool enableHitDetection;

  /// Whether high-performance mode is enabled for free-style drawing.
  final bool isHighPerformanceMode;

  /// Callback function that is triggered when a hit status changes.
  ///
  /// The [onHitChanged] function takes a boolean parameter [hasHit] which
  /// indicates whether a hit has occurred (true) or not (false).
  final Function(bool hasHit) onHitChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Improves hit detection for mobile devices by adding padding.
      padding: EdgeInsets.all(isDesktop ? 0 : 15),
      child: RepaintBoundary(
        child: Opacity(
          opacity: layer.opacity,
          child: CustomPaint(
            size: layer.size,
            willChange: false,
            isComplex: layer.item.mode == PaintMode.freeStyle,
            painter: DrawPaintItem(
              item: layer.item,
              scale: scale,
              selected: isSelected,
              enabledHitDetection: enableHitDetection,
              freeStyleHighPerformance: isHighPerformanceMode,
              onHitChanged: onHitChanged,
            ),
          ),
        ),
      ),
    );
  }
}
