import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' hide Layer;
import 'package:pro_image_editor/pro_image_editor.dart';

import '/core/mixin/example_helper.dart';

/// The example for custom layer selection designs.
class LayerSelectDesignExample extends StatefulWidget {
  /// Creates a new [LayerSelectDesignExample] widget.
  const LayerSelectDesignExample({super.key});

  @override
  State<LayerSelectDesignExample> createState() =>
      _LayerSelectDesignExampleState();
}

class _LayerSelectDesignExampleState extends State<LayerSelectDesignExample>
    with ExampleHelperState<LayerSelectDesignExample> {
  final _outsideSpace = 5.0;
  final _strokeWidth = 2.0;
  final _handlerLength = !isDesktop ? 36.0 : 20.0;
  final _handlerGap = 10.0;
  final _strokeColor = const Color(0xFFFFFFFF);
  final _positions = const [
    _Position(bottom: 0, left: 0),
    _Position(top: 0, left: 0),
    _Position(top: 0, right: 0),
    _Position(bottom: 0, right: 0),
  ];

  final _overlayCtrl = OverlayPortalController();
  final _transformedLayerKey = GlobalKey();
  final _stackKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    preCacheImage(networkUrl: 'https://picsum.photos/id/19/2000');
  }

  @override
  void dispose() {
    if (_overlayCtrl.isShowing) _overlayCtrl.hide();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return Stack(
      children: [
        ProImageEditor.network(
          'https://picsum.photos/id/19/2000',
          key: editorKey,
          callbacks: ProImageEditorCallbacks(
            onImageEditingStarted: onImageEditingStarted,
            onImageEditingComplete: onImageEditingComplete,
            onCloseEditor: (editorMode) => onCloseEditor(
              editorMode: editorMode,
              enablePop: !isDesktopMode(context),
            ),
            mainEditorCallbacks: MainEditorCallbacks(
              helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
            ),
          ),
          configs: ProImageEditorConfigs(
            mainEditor: MainEditorConfigs(
                widgets: MainEditorWidgets(
              removeLayerArea: (removeAreaKey, editor, rebuildStream) =>
                  const SizedBox.shrink(),
            )),
            layerInteraction: LayerInteractionConfigs(
              selectable: LayerInteractionSelectable.enabled,
              widgets: LayerInteractionWidgets(
                overlayChildBuilder: _overlayChildBuilder,
              ),
            ),
          ),
        ),
      ],
    );
  }

  ReactiveWidget _overlayChildBuilder(
    Stream<void> rebuildStream,
    OverlayChildLayoutInfo info,
    Layer layer,
    LayerItemInteractions interactions,
  ) {
    if (!_overlayCtrl.isShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _overlayCtrl.show();
      });
    }

    final padding = const EdgeInsets.all(16);
    final Matrix4 transform = info.childPaintTransform.clone();

    // The child size
    final childWidth = info.childSize.width;
    final childHeight = info.childSize.height;

    // The new padded size
    final paddedWidth = childWidth + padding.horizontal;
    final paddedHeight = childHeight + padding.vertical;

    // Offset the transform so the center remains aligned
    transform.translate(-padding.left, -padding.top);

    return ReactiveWidget(
      stream: rebuildStream,
      builder: (_) => OverlayPortal(
        controller: _overlayCtrl,
        overlayChildBuilder: (context) {
          double layerTopY = 0.0;
          double layerCenterX = 0.0;

          final renderObject =
              _transformedLayerKey.currentContext?.findRenderObject();
          final renderBox =
              _transformedLayerKey.currentContext?.findRenderObject();
          final parentBox = _stackKey.currentContext?.findRenderObject();

          if (renderBox is RenderBox &&
              parentBox is RenderBox &&
              renderBox.hasSize &&
              parentBox.hasSize) {
            final size = renderBox.size;

            final topLeftGlobal = renderBox.localToGlobal(Offset.zero);
            final topRightGlobal =
                renderBox.localToGlobal(Offset(size.width, 0));
            final bottomLeftGlobal =
                renderBox.localToGlobal(Offset(0, size.height));
            final bottomRightGlobal =
                renderBox.localToGlobal(Offset(size.width, size.height));

            final topLeft = parentBox.globalToLocal(topLeftGlobal);
            final topRight = parentBox.globalToLocal(topRightGlobal);
            final bottomLeft = parentBox.globalToLocal(bottomLeftGlobal);
            final bottomRight = parentBox.globalToLocal(bottomRightGlobal);

            final allX = [
              topLeft.dx,
              topRight.dx,
              bottomLeft.dx,
              bottomRight.dx
            ];
            final allY = [
              topLeft.dy,
              topRight.dy,
              bottomLeft.dy,
              bottomRight.dy
            ];

            final minX = allX.reduce(min);
            final maxX = allX.reduce(max);
            final minY = allY.reduce(min);

            final centerX = (minX + maxX) / 2;

            layerCenterX = centerX;
            layerTopY = minY;
          }
          return Positioned(
            // FIXME: ensure overlay is inside the view area.
            top: max(0, layerTopY - 10),
            left: max(0, layerCenterX),
            child: FractionalTranslation(
              translation: const Offset(-0.5, -1),
              child: _buildActionButtons(layer, interactions),
            ),
          );
        },
        child: Stack(
          key: _stackKey,
          children: [
            Positioned(
              width: paddedWidth,
              height: paddedHeight,
              child: Transform(
                transform: transform,
                child: Transform.flip(
                  key: _transformedLayerKey,
                  flipX: layer.flipX,
                  flipY: layer.flipY,
                  child: _buildSelectionOverlay(interactions),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionOverlay(LayerItemInteractions interactions) {
    return Stack(
      fit: StackFit.passthrough,
      alignment: Alignment.center,
      children: [
        /// Outside border
        CustomPaint(
          foregroundPainter: _BorderPainter(
            borderColor: _strokeColor,
            strokeWidth: _strokeWidth,
            spacer: _handlerLength + _handlerGap,
            outsideSpace: _outsideSpace,
          ),
        ),

        /// Corner resize/rotate handlers
        ...List.generate(
          4,
          (index) {
            double? positionHelper(double? value) {
              if (value == null) return null;

              return value + _outsideSpace;
            }

            final position = _positions[index];

            return Positioned(
              top: positionHelper(position.top),
              left: positionHelper(position.left),
              right: positionHelper(position.right),
              bottom: positionHelper(position.bottom),
              child: _ResizeRotateHandler(
                interactions: interactions,
                handlerLength: _handlerLength,
                rotationCount: index,
                strokeWidth: _strokeWidth * 1.5,
                strokeColor: _strokeColor,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButtons(Layer layer, LayerItemInteractions interactions) {
    final editor = editorKey.currentState!;
    int totalLayers = editor.activeLayers.length;
    // int layerIndex = editor.getLayerStackIndex(layer);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width),
        child: Wrap(
          children: [
            if (layer.isTextLayer)
              _buildToolbarButton('Edit', onTap: interactions.edit),
            /* Optional buttons to directly reorder the layers.

            _buildToolbarButton(
              'Forward',
              onTap: layerIndex < totalLayers - 1
                  ? () => editorKey.currentState!.moveLayerForward(layer)
                  : null,
            ),
            _buildToolbarButton(
              'Backward',
              onTap: layerIndex > 0
                  ? () => editorKey.currentState!.moveLayerBackward(layer)
                  : null,
            ),
            _buildToolbarButton(
              'Move To Front',
              onTap: layerIndex < totalLayers - 1
                  ? () => editorKey.currentState!.moveLayerToFront(layer)
                  : null,
            ),
            _buildToolbarButton(
              'Move To Back',
              onTap: layerIndex > 0
                  ? () => editorKey.currentState!.moveLayerToBack(layer)
                  : null,
            ),
            */
            _buildToolbarButton('Duplicate', onTap: () {
              interactions.duplicated();
              WidgetsBinding.instance.addPostFrameCallback((_) {
                editor.selectLayerByIndex(totalLayers);
              });
            }),
            _buildToolbarButton('Delete', onTap: interactions.remove),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarButton(String text, {VoidCallback? onTap}) {
    final isEnabled = onTap != null;

    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        backgroundColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isEnabled ? Colors.white : Colors.white38,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Utils: Better to separate it into multiple files if you copy/paste that code.
class _ResizeRotateHandler extends StatelessWidget {
  const _ResizeRotateHandler({
    required this.strokeWidth,
    required this.handlerLength,
    required this.rotationCount,
    required this.strokeColor,
    required this.interactions,
  });

  final double strokeWidth;
  final double handlerLength;
  final int rotationCount;
  final Color strokeColor;
  final LayerItemInteractions interactions;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      hitTestBehavior: HitTestBehavior.translucent,
      cursor: rotationCount % 2 == 0
          ? SystemMouseCursors.resizeUpRightDownLeft
          : SystemMouseCursors.resizeUpLeftDownRight,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: interactions.scaleRotateDown,
        onPointerUp: interactions.scaleRotateUp,
        child: _HitTestTransparent(
          child: RotatedBox(
            quarterTurns: rotationCount,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                Container(
                  width: strokeWidth,
                  height: handlerLength,
                  color: strokeColor,
                ),
                Container(
                  width: handlerLength,
                  height: strokeWidth,
                  color: strokeColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Position {
  const _Position({this.top, this.left, this.right, this.bottom});

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
}

class _BorderPainter extends CustomPainter {
  const _BorderPainter({
    required this.borderColor,
    required this.strokeWidth,
    required this.spacer,
    required this.outsideSpace,
  });
  final Color borderColor;
  final double strokeWidth;
  final double spacer;
  final double outsideSpace;

  @override
  void paint(Canvas canvas, Size size) {
    _drawSolidBorder(canvas, size);
  }

  void _drawSolidBorder(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final offset = strokeWidth / 2;

    // Draw top border
    canvas
      ..drawLine(
        Offset(spacer, outsideSpace + offset),
        Offset(size.width - spacer, outsideSpace + offset),
        paint,
      )

      // Draw right border
      ..drawLine(
        Offset(size.width - outsideSpace - offset, spacer),
        Offset(size.width - outsideSpace - offset, size.height - spacer),
        paint,
      )

      // Draw bottom border
      ..drawLine(
        Offset(spacer, size.height - outsideSpace - offset),
        Offset(size.width - spacer, size.height - outsideSpace - offset),
        paint,
      )

      // Draw left border
      ..drawLine(
        Offset(outsideSpace + offset, spacer),
        Offset(outsideSpace + offset, size.height - spacer),
        paint,
      );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

class _HitTestTransparent extends SingleChildRenderObjectWidget {
  const _HitTestTransparent({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderHitTestTransparent();
  }
}

class _RenderHitTestTransparent extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    // Always skip this widget in hit testing
    return false;
  }
}
