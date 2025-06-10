// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '/core/models/editor_configs/paint_editor/paint_editor_configs.dart';
import '/shared/widgets/censor/blur_area_item.dart';
import '/shared/widgets/censor/pixelate_area_item.dart';
import '../controllers/paint_controller.dart';
import '../enums/paint_editor_enum.dart';
import '../models/painted_model.dart';
import 'draw_paint_item.dart';

/// A widget for creating a canvas for paint on images.
///
/// This widget allows you to create a canvas for paint on images loaded
/// from various sources, including network URLs, asset paths, files, or memory
/// (Uint8List).
/// It provides customization options for appearance and behavior.
class PaintCanvas extends StatefulWidget {
  /// Constructs a `PaintCanvas` widget.
  const PaintCanvas({
    super.key,
    this.onStart,
    this.onCreated,
    this.onRemoveLayer,
    this.freeStyleHighPerformance = false,
    required this.drawAreaSize,
    required this.paintCtrl,
    required this.paintEditorConfigs,
  });

  /// Callback function when the active paint is done.
  final VoidCallback? onCreated;

  /// Callback invoked when layers are removed.
  ///
  /// Receives a list of layer identifiers that have been removed.
  final ValueChanged<List<String>>? onRemoveLayer;

  /// Callback invoked when paint starts.
  final VoidCallback? onStart;

  /// Size of the image.
  final Size drawAreaSize;

  /// The `PaintController` class is responsible for managing and controlling
  /// the paint state.
  final PaintController paintCtrl;

  /// Controls high-performance for free-style drawing.
  final bool freeStyleHighPerformance;

  /// Configuration settings for the paint editor.
  /// This field holds an instance of [PaintEditorConfigs] which contains
  /// various settings and options used to customize the behavior and
  /// appearance of the paint editor.
  final PaintEditorConfigs paintEditorConfigs;

  @override
  PaintCanvasState createState() => PaintCanvasState();
}

/// State class for managing the paint canvas.
class PaintCanvasState extends State<PaintCanvas> {
  /// Getter for accessing the [PaintController] instance provided by the
  /// parent widget.
  PaintController get _paintCtrl => widget.paintCtrl;

  /// Stream controller for updating paint events.
  late final StreamController<void> _activePaintStreamCtrl;

  @override
  void initState() {
    super.initState();
    _activePaintStreamCtrl = StreamController.broadcast();
  }

  @override
  void dispose() {
    _activePaintStreamCtrl.close();
    super.dispose();
  }

  /// This method is called when a scaling gesture for paint begins. It
  /// captures the starting point of the gesture.
  ///
  /// It is not meant to be called directly but is an event handler for scaling
  /// gestures.
  void _onScaleStart(ScaleStartDetails details) {
    final offset = details.localFocalPoint;
    switch (widget.paintCtrl.mode) {
      case PaintMode.moveAndZoom:
        return;
      case PaintMode.eraser:
        setState(() {});
        return;
      case PaintMode.polygon:
        if (_paintCtrl.offsets.isEmpty) {
          _paintCtrl
            ..setStart(offset)
            ..setInProgress(true);
          widget.onStart?.call();
        }
        _paintCtrl.addOffsets(offset);
        _activePaintStreamCtrl.add(null);
        return;
      default:
        _paintCtrl
          ..setStart(offset)
          ..addOffsets(offset);
        _activePaintStreamCtrl.add(null);
        break;
    }
  }

  /// Fires while the user is interacting with the screen to record paint.
  ///
  /// This method is called during an ongoing scaling gesture to record
  /// paint actions. It captures the current position and updates the
  /// paint controller accordingly.
  ///
  /// It is not meant to be called directly but is an event handler for scaling
  /// gestures.
  void _onScaleUpdate(ScaleUpdateDetails details) {
    switch (widget.paintCtrl.mode) {
      case PaintMode.moveAndZoom:
      case PaintMode.polygon:
        return;
      case PaintMode.eraser:
        List<String> removeIds = [];
        for (var item in _paintCtrl.activePaintItemList) {
          if (item.mode == PaintMode.blur || item.mode == PaintMode.pixelate) {
            List<Offset?> offsets = item.offsets;
            if (offsets.length != 2) continue;

            var topLeft = offsets[0];
            if (topLeft == null) continue;

            var bottomRight = offsets[1];
            if (bottomRight == null) continue;

            double width = (bottomRight.dx - topLeft.dx);
            double height = (bottomRight.dy - topLeft.dy);

            double left = width >= 0 ? topLeft.dx : topLeft.dx + width;
            double top = height >= 0 ? topLeft.dy : topLeft.dy + height;

            var dx = details.localFocalPoint.dx;
            var dy = details.localFocalPoint.dy;

            bool horizontalHit = dx >= left && dx <= left + width.abs();
            bool verticalHit = dy >= top && dy <= top + height.abs();
            if (horizontalHit && verticalHit) {
              removeIds.add(item.id);
            }
          } else {
            final painter = item.key.currentContext?.findRenderObject()
                as RenderCustomPaint?;
            final hasHit =
                painter?.painter?.hitTest(details.localFocalPoint) ?? false;

            if (hasHit || item.hit) removeIds.add(item.id);
          }
        }
        if (removeIds.isNotEmpty) widget.onRemoveLayer?.call(removeIds);
        break;
      default:
        final offset = details.localFocalPoint;
        if (!_paintCtrl.busy) {
          widget.onStart?.call();
          _paintCtrl.setInProgress(true);
        }

        if (_paintCtrl.start == null) {
          _paintCtrl.setStart(offset);
        }

        if (_paintCtrl.mode == PaintMode.freeStyle) {
          _paintCtrl.addOffsets(offset);
        }

        _paintCtrl.setEnd(offset);

        _activePaintStreamCtrl.add(null);
    }
  }

  /// Fires when the user stops interacting with the screen.
  ///
  /// This method is called when a scaling gesture for paint ends. It
  /// finalizes and records the paint action.
  ///
  /// It is not meant to be called directly but is an event handler for scaling
  /// gestures.
  void _onScaleEnd(ScaleEndDetails details) {
    if (widget.paintCtrl.mode == PaintMode.moveAndZoom ||
        widget.paintCtrl.mode == PaintMode.eraser) {
      return;
    }

    List<Offset?>? offsets;

    if (_paintCtrl.start != null && _paintCtrl.end != null) {
      if (_paintCtrl.mode == PaintMode.freeStyle) {
        offsets = [..._paintCtrl.offsets];
      } else if (_paintCtrl.start != null && _paintCtrl.end != null) {
        offsets = [_paintCtrl.start, _paintCtrl.end];
      }
    } else if (_paintCtrl.mode == PaintMode.polygon) {
      List<Offset?> rawOffsets = [..._paintCtrl.offsets];

      if (rawOffsets.length >= 2 &&
          rawOffsets.first != null &&
          rawOffsets.last != null) {
        final p1 = rawOffsets.first!;
        final p2 = rawOffsets.last!;

        final threshold = widget.paintEditorConfigs.polygonConnectionThreshold;

        if ((p1 - p2).distance < threshold) {
          // Connect them by replacing the last point with the first one
          rawOffsets[rawOffsets.length - 1] = rawOffsets.first;
          offsets = rawOffsets;
        }
      }
      if (offsets == null || offsets.isEmpty) return;
    }
    if (offsets != null) {
      _paintCtrl.addPaintInfo(
        PaintedModel(
          offsets: offsets,
          mode: _paintCtrl.mode,
          color: _paintCtrl.color,
          strokeWidth: _paintCtrl.scaledStrokeWidth,
          fill: _paintCtrl.fill,
          opacity: _paintCtrl.opacity,
        ),
      );
      widget.onCreated?.call();
    }

    _paintCtrl
      ..setInProgress(false)
      ..reset();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: _paintCtrl.mode == PaintMode.moveAndZoom,
      child: Stack(
        fit: StackFit.expand,
        children: [..._buildPaintings(), _buildActiveItem()],
      ),
    );
  }

  List<Widget> _buildPaintings() {
    return [
      for (final item in _paintCtrl.activePaintItemList)
        if (item.mode == PaintMode.blur || item.mode == PaintMode.pixelate)
          _buildCensorItem(item)
        else
          Opacity(
            opacity: item.opacity,
            child: CustomPaint(
              key: item.key,
              willChange: false,
              isComplex: item.mode == PaintMode.freeStyle,
              painter: DrawPaintItem(
                item: item,
                freeStyleHighPerformance: widget.freeStyleHighPerformance,
                enabledHitDetection: _paintCtrl.mode == PaintMode.eraser,
              ),
            ),
          )
    ];
  }

  Widget _buildActiveItem() {
    return StreamBuilder(
      stream: _activePaintStreamCtrl.stream,
      builder: (context, snapshot) {
        return GestureDetector(
          behavior: HitTestBehavior.translucent,
          onScaleStart: _onScaleStart,
          onScaleUpdate: _onScaleUpdate,
          onScaleEnd: _onScaleEnd,
          child: _paintCtrl.busy
              ? _paintCtrl.mode == PaintMode.blur ||
                      _paintCtrl.mode == PaintMode.pixelate
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        _buildCensorItem(_paintCtrl.paintedModel),
                      ],
                    )
                  : Opacity(
                      opacity: _paintCtrl.opacity,
                      child: CustomPaint(
                        size: widget.drawAreaSize,
                        willChange: true,
                        isComplex: true,
                        painter: DrawPaintItem(item: _paintCtrl.paintedModel),
                      ),
                    )
              : const SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildCensorItem(PaintedModel item) {
    List<Offset?> offsets = item.offsets;
    if (offsets.length != 2) return const SizedBox.shrink();

    var topLeft = offsets[0];
    if (topLeft == null) return const SizedBox.shrink();

    var bottomRight = offsets[1];
    if (bottomRight == null) return const SizedBox.shrink();

    double width = (bottomRight.dx - topLeft.dx);
    double height = (bottomRight.dy - topLeft.dy);

    double left = width >= 0 ? topLeft.dx : topLeft.dx + width;
    double top = height >= 0 ? topLeft.dy : topLeft.dy + height;

    var censorConfigs = widget.paintEditorConfigs.censorConfigs;

    return Positioned(
      left: left,
      top: top,
      width: width.abs(),
      height: height.abs(),
      child: MouseRegion(
        onEnter: (event) {
          item.hit = true;
        },
        onExit: (event) {
          item.hit = false;
        },
        child: item.mode == PaintMode.pixelate
            ? PixelateAreaItem(censorConfigs: censorConfigs)
            : BlurAreaItem(censorConfigs: censorConfigs),
      ),
    );
  }
}
