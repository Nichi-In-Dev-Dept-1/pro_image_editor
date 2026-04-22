import 'package:flutter/material.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/core/models/layers/paint_layer.dart';
import '/features/paint_editor/models/painted_model.dart';
import 'draw_paint_item.dart';

/// Paints image eraser strokes directly onto the editor canvas so they can
/// clear already rendered image pixels.
class PaintEditorImageEraserOverlay extends StatelessWidget {
  const PaintEditorImageEraserOverlay({
    super.key,
    required this.child,
    required this.layers,
    this.activeItem,
    required this.editorBodySize,
    required this.layerStackScaleFactor,
    required this.paintEditorConfigs,
    this.useClearBlend = false,
  });

  final Widget child;
  final List<PaintLayer> layers;
  final PaintedModel? activeItem;
  final Size editorBodySize;
  final double layerStackScaleFactor;
  final PaintEditorConfigs paintEditorConfigs;
  final bool useClearBlend;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: CustomPaint(
        foregroundPainter: layers.isEmpty
            ? (activeItem == null
                  ? null
                  : _PaintEditorImageEraserPainter(
                      layers: layers,
                      activeItem: activeItem,
                      editorBodySize: editorBodySize,
                      layerStackScaleFactor: layerStackScaleFactor,
                      paintEditorConfigs: paintEditorConfigs,
                      useClearBlend: useClearBlend,
                    ))
            : _PaintEditorImageEraserPainter(
                layers: layers,
                activeItem: activeItem,
                editorBodySize: editorBodySize,
                layerStackScaleFactor: layerStackScaleFactor,
                paintEditorConfigs: paintEditorConfigs,
                useClearBlend: useClearBlend,
              ),
        child: child,
      ),
    );
  }
}

class _PaintEditorImageEraserPainter extends CustomPainter {
  const _PaintEditorImageEraserPainter({
    required this.layers,
    required this.activeItem,
    required this.editorBodySize,
    required this.layerStackScaleFactor,
    required this.paintEditorConfigs,
    required this.useClearBlend,
  });

  final List<PaintLayer> layers;
  final PaintedModel? activeItem;
  final Size editorBodySize;
  final double layerStackScaleFactor;
  final PaintEditorConfigs paintEditorConfigs;
  final bool useClearBlend;

  @override
  void paint(Canvas canvas, Size size) {
    final halfBodySize = editorBodySize / 2;

    for (final layer in layers) {
      final layerSize = layer.size * layerStackScaleFactor;

      canvas
        ..save()
        ..translate(
          halfBodySize.width + layer.offset.dx * layerStackScaleFactor,
          halfBodySize.height + layer.offset.dy * layerStackScaleFactor,
        )
        ..rotate(layer.rotation)
        ..scale(
          layer.flipX ? -1.0 : 1.0,
          layer.flipY ? -1.0 : 1.0,
        )
        ..translate(-layerSize.width / 2, -layerSize.height / 2);

      DrawPaintItem(
        item: layer.item,
        scale: layer.scale * layerStackScaleFactor,
        paintEditorConfigs: paintEditorConfigs,
        blendMode: useClearBlend ? BlendMode.clear : null,
      ).paint(canvas, layerSize);

      canvas.restore();
    }

    if (activeItem != null && activeItem!.offsets.length > 1) {
      DrawPaintItem(
        item: activeItem!,
        scale: 1,
        paintEditorConfigs: paintEditorConfigs,
        blendMode: useClearBlend ? BlendMode.clear : null,
      ).paint(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant _PaintEditorImageEraserPainter oldDelegate) {
    return oldDelegate.layers != layers ||
        oldDelegate.activeItem != activeItem ||
        oldDelegate.editorBodySize != editorBodySize ||
        oldDelegate.layerStackScaleFactor != layerStackScaleFactor ||
        oldDelegate.useClearBlend != useClearBlend ||
        oldDelegate.paintEditorConfigs != paintEditorConfigs;
  }
}
