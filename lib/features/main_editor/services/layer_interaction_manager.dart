// Dart imports:
import 'dart:async';
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '/core/models/editor_callbacks/main_editor/helper_lines/helper_lines_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/history/last_layer_interaction_position.dart';
import '/core/models/layers/layer.dart';
import '/shared/utils/debounce.dart';

/// A helper class responsible for managing layer interactions in the editor.
///
/// The `LayerInteractionManager` class provides methods for handling various
/// interactions with layers in an image editing environment, including
/// scaling, rotating, flipping, and zooming. It also manages the display of
/// helper lines and provides haptic feedback when interacting with these lines
/// to enhance the user experience.
class LayerInteractionManager {
  /// Creates an instance of [LayerInteractionManager].
  ///
  /// - [helperLinesCallbacks]: An optional instance of [HelperLinesCallbacks]
  ///   to handle helper line hit events.
  LayerInteractionManager({
    required this.helperLinesCallbacks,
    this.onSelectedLayerChanged,
  });

  /// An optional instance of [HelperLinesCallbacks] that defines callback
  ///  functions for handling helper line interactions.
  final HelperLinesCallbacks? helperLinesCallbacks;

  /// Callback function to be called when the selected layer changes.
  final ValueChanged<String>? onSelectedLayerChanged;

  /// Debounce for scaling actions in the editor.
  late Debounce scaleDebounce;

  /// Y-coordinate of the rotation helper line.
  double rotationHelperLineY = 0;

  /// X-coordinate of the rotation helper line.
  double rotationHelperLineX = 0;

  /// Rotation angle of the rotation helper line.
  double rotationHelperLineDeg = 0;

  /// The base scale factor from the layer;
  double baseScaleFactor = 1.0;

  /// The base angle factor from the layer;
  double baseAngleFactor = 0;

  /// X-coordinate where snapping started.
  double snapStartPosX = 0;

  /// Y-coordinate where snapping started.
  double snapStartPosY = 0;

  /// Initial rotation angle when snapping started.
  double snapStartRotation = 0;

  /// Last recorded rotation angle during snapping.
  double snapLastRotation = 0;

  /// Flag indicating if vertical helper lines should be displayed.
  bool showVerticalHelperLine = false;

  /// Flag indicating if horizontal helper lines should be displayed.
  bool showHorizontalHelperLine = false;

  /// Flag indicating if rotation helper lines should be displayed.
  bool showRotationHelperLine = false;

  /// Whether to show the vertical alignment line for the active layer.
  bool isVerticalGuideVisible = false;

  /// Whether to show the horizontal alignment line for the active layer.
  bool isHorizontalGuideVisible = false;

  /// Offset of the horizontal alignment line relative to the editor center.
  Offset horizontalGuideOffset = Offset.zero;

  /// Offset of the vertical alignment line relative to the editor center.
  Offset verticalGuideOffset = Offset.zero;

  /// Flag indicating if rotation helper lines have started.
  bool _rotationStartedHelper = false;

  /// Flag indicating if helper lines should be displayed.
  bool showHelperLines = false;

  /// Flag indicating if the remove button is hovered.
  bool hoverRemoveBtn = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the painted layer.
  bool enabledHitDetection = true;

  /// Controls high-performance scaling for free-style drawing.
  /// When `true`, enables optimized scaling for improved performance.
  bool freeStyleHighPerformanceScaling = false;

  /// Controls high-performance for layers when editor zoom.
  bool freeStyleHighPerformanceEditorZoom = false;

  /// Controls high-performance moving for free-style drawing.
  /// When `true`, enables optimized moving for improved performance.
  bool freeStyleHighPerformanceMoving = false;

  /// Controls high-performance hero animation for free-style drawing.
  /// When `true`, enables optimized hero-animation for improved performance.
  bool freeStyleHighPerformanceHero = false;

  /// Determines if any high-performance mode is enabled for free style editing.
  bool get freeStyleHighPerformance =>
      freeStyleHighPerformanceEditorZoom ||
      freeStyleHighPerformanceScaling ||
      freeStyleHighPerformanceMoving ||
      freeStyleHighPerformanceHero;

  /// Flag indicating if the scaling tool is active.
  bool _activeScale = false;

  /// Span for detecting hits on layers.
  final double hitSpan = 10;

  /// The ID of the currently selected layer.
  String _selectedLayerId = '';

  /// Returns the ID of the currently selected layer.
  String get selectedLayerId => _selectedLayerId;

  /// Sets the ID of the currently selected layer.
  set selectedLayerId(String id) {
    _selectedLayerId = id;
    onSelectedLayerChanged?.call(_selectedLayerId);
  }

  /// Helper variable for scaling during rotation of a layer.
  double? rotateScaleLayerScaleHelper;

  /// Helper variable for storing the size of a layer during rotation and
  /// scaling operations.
  Size? rotateScaleLayerSizeHelper;

  /// Last recorded X-axis position for layers.
  LayerLastPosition lastPositionX = LayerLastPosition.center;

  /// Last recorded Y-axis position for layers.
  LayerLastPosition lastPositionY = LayerLastPosition.center;

  Offset? _rotateScaleButtonStartPosition;

  double? _helperFocalX;
  double? _helperFocalY;

  /// Resets the state of the layer interaction manager by:
  ///
  /// - Setting `_rotateScaleButtonStartPosition` to `null`.
  /// - Setting `_rotationStartedHelper` to `false`.
  /// - Enabling the display of helper lines by setting `showHelperLines` to
  /// `true`.
  reset() {
    _rotateScaleButtonStartPosition = null;
    _rotationStartedHelper = false;
    showHelperLines = true;
  }

  /// Determines if layers are selectable based on the configuration and device
  /// type.
  bool layersAreSelectable(ProImageEditorConfigs configs) {
    if (configs.layerInteraction.selectable ==
        LayerInteractionSelectable.auto) {
      return isDesktop;
    }
    return configs.layerInteraction.selectable ==
        LayerInteractionSelectable.enabled;
  }

  /// Calculates scaling and rotation based on user interactions.
  calculateInteractiveButtonScaleRotate({
    required double editorScaleFactor,
    required Offset editorScaleOffset,
    required ProImageEditorConfigs configs,
    required ScaleUpdateDetails details,
    required Layer activeLayer,
    required Size editorSize,
    required LayerInteractionStyle layerTheme,
  }) {
    /// Calculates the rotation angle (in radians) for a button moved to a
    /// new position.
    /// [oldPosition] is the initial button position,
    /// [newPosition] is the final button position.
    double calculateRotation(Offset oldPosition, Offset newPosition) {
      // Calculate the vectors from the origin to the old and new positions
      Offset oldVector = oldPosition;
      Offset newVector = newPosition;

      // Get the angle of each vector relative to the x-axis
      double oldAngle = atan2(oldVector.dy, oldVector.dx);
      double newAngle = atan2(newVector.dy, newVector.dx);

      // Calculate the rotation angle
      double rotation = newAngle - oldAngle;

      // Normalize the rotation angle to be between -pi and pi
      if (rotation > pi) rotation -= 2 * pi;
      if (rotation < -pi) rotation += 2 * pi;

      return rotation; // In radians
    }

    /// Calculates the scale factor based on the movement of a button.
    /// [oldPosition] is the initial button position,
    /// [newPosition] is the final button position.
    double calculateScale(
      Offset oldPosition,
      Offset newPosition,
    ) {
      // Calculate distances from the origin to the old and new positions
      double oldDistance = (oldPosition).distance;
      double newDistance = (newPosition).distance;

      // Calculate the scale factor
      if (oldDistance == 0 || newDistance == 0) {
        return 1;
      }

      return newDistance / oldDistance;
    }

    Offset layerOffset = activeLayer.offset;

    Offset realTouchPosition =
        (details.localFocalPoint - editorScaleOffset) / editorScaleFactor;

    Offset touchPositionFromLayerCenter =
        realTouchPosition - editorSize.center(Offset.zero) - layerOffset;

    if (activeLayer.flipX) {
      touchPositionFromLayerCenter = Offset(
        -touchPositionFromLayerCenter.dx,
        touchPositionFromLayerCenter.dy,
      );
    }
    if (activeLayer.flipY) {
      touchPositionFromLayerCenter = Offset(
        touchPositionFromLayerCenter.dx,
        -touchPositionFromLayerCenter.dy,
      );
    }

    _rotateScaleButtonStartPosition ??= touchPositionFromLayerCenter;

    if (activeLayer.interaction.enableScale) {
      activeLayer.scale = baseScaleFactor *
          calculateScale(
            _rotateScaleButtonStartPosition!,
            touchPositionFromLayerCenter,
          );
      _setMinMaxScaleFactor(configs, activeLayer);
    }

    if (activeLayer.interaction.enableRotate) {
      activeLayer.rotation = baseAngleFactor +
          calculateRotation(
            _rotateScaleButtonStartPosition!,
            touchPositionFromLayerCenter,
          );

      if (editorScaleFactor != 1) return;
      checkRotationLine(
        activeLayer: activeLayer,
        editorSize: editorSize,
      );
    }
  }

  /// Calculates movement of a layer based on user interactions, considering
  /// various conditions such as hit areas and screen boundaries.
  calculateMovement({
    required double editorScaleFactor,
    required BuildContext context,
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required List<Layer> layerList,
    required GlobalKey removeAreaKey,
    required Function(bool) onHoveredRemoveChanged,
    required StreamController<void> helperLineCtrl,
  }) {
    if (_activeScale || !activeLayer.interaction.enableMove) return;

    RenderBox? box =
        removeAreaKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null) {
      Offset position = box.localToGlobal(Offset.zero);
      bool hit = Rect.fromLTWH(
        position.dx,
        position.dy,
        box.size.width,
        box.size.height,
      ).contains(detail.focalPoint);
      if (hoverRemoveBtn != hit) {
        hoverRemoveBtn = hit;
        onHoveredRemoveChanged.call(hoverRemoveBtn);
      }
    }

    activeLayer.offset = Offset(
      activeLayer.offset.dx + detail.focalPointDelta.dx / editorScaleFactor,
      activeLayer.offset.dy + detail.focalPointDelta.dy / editorScaleFactor,
    );

    if (editorScaleFactor > 1) return;

    bool hasLineHit = false;
    double posX = activeLayer.offset.dx;
    double posY = activeLayer.offset.dy;

    bool hitAreaX = detail.focalPoint.dx >= snapStartPosX - hitSpan &&
        detail.focalPoint.dx <= snapStartPosX + hitSpan;
    bool hitAreaY = detail.focalPoint.dy >= snapStartPosY - hitSpan &&
        detail.focalPoint.dy <= snapStartPosY + hitSpan;

    bool helperGoNearLineLeft =
        posX >= 0 && lastPositionX == LayerLastPosition.left;
    bool helperGoNearLineRight =
        posX <= 0 && lastPositionX == LayerLastPosition.right;
    bool helperGoNearLineTop =
        posY >= 0 && lastPositionY == LayerLastPosition.top;
    bool helperGoNearLineBottom =
        posY <= 0 && lastPositionY == LayerLastPosition.bottom;

    /// Calc vertical helper line
    if ((!showVerticalHelperLine &&
            (helperGoNearLineLeft || helperGoNearLineRight)) ||
        (showVerticalHelperLine && hitAreaX)) {
      if (!showVerticalHelperLine) {
        hasLineHit = true;
        snapStartPosX = detail.focalPoint.dx;
      }
      showVerticalHelperLine = true;
      activeLayer.offset = Offset(0, activeLayer.offset.dy);
      lastPositionX = LayerLastPosition.center;
    } else {
      showVerticalHelperLine = false;
      lastPositionX =
          posX <= 0 ? LayerLastPosition.left : LayerLastPosition.right;
    }

    /// Calc horizontal helper line
    if ((!showHorizontalHelperLine &&
            (helperGoNearLineTop || helperGoNearLineBottom)) ||
        (showHorizontalHelperLine && hitAreaY)) {
      if (!showHorizontalHelperLine) {
        hasLineHit = true;
        snapStartPosY = detail.focalPoint.dy;
      }
      showHorizontalHelperLine = true;
      activeLayer.offset = Offset(activeLayer.offset.dx, 0);
      lastPositionY = LayerLastPosition.center;
    } else {
      showHorizontalHelperLine = false;
      lastPositionY =
          posY <= 0 ? LayerLastPosition.top : LayerLastPosition.bottom;
    }

    _updateAlignmentGuides(
      detail: detail,
      layerList: layerList,
      activeLayer: activeLayer,
      helperLineCtrl: helperLineCtrl,
    );

    if (hasLineHit) {
      if (showHorizontalHelperLine) {
        helperLinesCallbacks?.handleHorizontalLineHit();
      }
      if (showVerticalHelperLine) {
        helperLinesCallbacks?.handleVerticalLineHit();
      }
    }
  }

  /// Calculates scaling and rotation of a layer based on user interactions.
  calculateScaleRotate({
    required double editorScaleFactor,
    required ProImageEditorConfigs configs,
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required Size editorSize,
    required EdgeInsets screenPaddingHelper,
  }) {
    _activeScale = true;

    if (activeLayer.interaction.enableScale) {
      activeLayer.scale = baseScaleFactor * detail.scale;
      _setMinMaxScaleFactor(configs, activeLayer);
    }
    if (activeLayer.interaction.enableRotate) {
      activeLayer.rotation = baseAngleFactor + detail.rotation;

      if (editorScaleFactor == 1) {
        checkRotationLine(
          activeLayer: activeLayer,
          editorSize: editorSize,
        );
      }
    }

    scaleDebounce(() => _activeScale = false);
  }

  /// Checks the rotation line based on user interactions, adjusting rotation
  /// accordingly.
  checkRotationLine({
    required Layer activeLayer,
    required Size editorSize,
  }) {
    double rotation = activeLayer.rotation - baseAngleFactor;
    double hitSpanX = hitSpan / 2;
    double deg = activeLayer.rotation * 180 / pi;
    double degChange = rotation * 180 / pi;
    double degHit = (snapStartRotation + degChange) % 45;

    bool hitAreaBelow = degHit <= hitSpanX;
    bool hitAreaAfter = degHit >= 45 - hitSpanX;
    bool hitArea = hitAreaBelow || hitAreaAfter;

    if ((!showRotationHelperLine &&
            ((degHit > 0 && degHit <= hitSpanX && snapLastRotation < deg) ||
                (degHit < 45 &&
                    degHit >= 45 - hitSpanX &&
                    snapLastRotation > deg))) ||
        (showRotationHelperLine && hitArea)) {
      if (_rotationStartedHelper) {
        activeLayer.rotation =
            (deg - (degHit > 45 - hitSpanX ? degHit - 45 : degHit)) / 180 * pi;
        rotationHelperLineDeg = activeLayer.rotation;

        double posY = activeLayer.offset.dy;
        double posX = activeLayer.offset.dx;

        rotationHelperLineX = posX + editorSize.width / 2;
        rotationHelperLineY = posY + editorSize.height / 2;
        if (!showRotationHelperLine) {
          helperLinesCallbacks?.handleRotateLineHit();
        }
        showRotationHelperLine = true;
      }
      snapLastRotation = deg;
    } else {
      showRotationHelperLine = false;
      _rotationStartedHelper = true;
    }
  }

  /// Handles the initialization logic when a scaling gesture starts on a layer.
  onScaleStart({
    required Layer selectedLayer,
  }) {
    baseScaleFactor = selectedLayer.scale;
    baseAngleFactor = selectedLayer.rotation;
    snapStartRotation = selectedLayer.rotation * 180 / pi;
    snapLastRotation = snapStartRotation;
    reset();

    double posX = selectedLayer.offset.dx;
    double posY = selectedLayer.offset.dy;

    lastPositionY = posY <= -hitSpan
        ? LayerLastPosition.top
        : posY >= hitSpan
            ? LayerLastPosition.bottom
            : LayerLastPosition.center;
    lastPositionX = posX <= -hitSpan
        ? LayerLastPosition.left
        : posX >= hitSpan
            ? LayerLastPosition.right
            : LayerLastPosition.center;
  }

  /// Handles cleanup and resets various flags and states after scaling
  /// interaction ends.
  onScaleEnd() {
    enabledHitDetection = true;
    freeStyleHighPerformanceScaling = false;
    freeStyleHighPerformanceMoving = false;
    showHorizontalHelperLine = false;
    showVerticalHelperLine = false;
    showRotationHelperLine = false;
    isVerticalGuideVisible = false;
    isHorizontalGuideVisible = false;
    showHelperLines = false;
    hoverRemoveBtn = false;
  }

  /// Rotate a layer.
  ///
  /// This method rotates a layer based on various factors, including flip and
  /// angle.
  void rotateLayer({
    required Layer layer,
    required bool beforeIsFlipX,
    required double newImgW,
    required double newImgH,
    required double rotationScale,
    required double rotationRadian,
    required double rotationAngle,
  }) {
    if (beforeIsFlipX) {
      layer.rotation -= rotationRadian;
    } else {
      layer.rotation += rotationRadian;
    }

    if (rotationAngle == 90) {
      layer
        ..scale /= rotationScale
        ..offset = Offset(
          newImgW - layer.offset.dy / rotationScale,
          layer.offset.dx / rotationScale,
        );
    } else if (rotationAngle == 180) {
      layer.offset = Offset(
        newImgW - layer.offset.dx,
        newImgH - layer.offset.dy,
      );
    } else if (rotationAngle == 270) {
      layer
        ..scale /= rotationScale
        ..offset = Offset(
          layer.offset.dy / rotationScale,
          newImgH - layer.offset.dx / rotationScale,
        );
    }
  }

  /// Handles zooming of a layer.
  ///
  /// This method calculates the zooming of a layer based on the specified
  /// parameters.
  /// It checks if the layer should be zoomed and performs the necessary
  /// transformations.
  ///
  /// Returns `true` if the layer was zoomed, otherwise `false`.
  bool zoomedLayer({
    required Layer layer,
    required double scale,
    required double scaleX,
    required double oldFullH,
    required double oldFullW,
    required double pixelRatio,
    required Rect cropRect,
    required bool isHalfPi,
  }) {
    var paddingTop = cropRect.top / pixelRatio;
    var paddingLeft = cropRect.left / pixelRatio;
    var paddingRight = oldFullW - cropRect.right;
    var paddingBottom = oldFullH - cropRect.bottom;

    // important to check with < 1 and >-1 cuz crop-editor has rounding bugs
    if (paddingTop > 0.1 ||
        paddingTop < -0.1 ||
        paddingLeft > 0.1 ||
        paddingLeft < -0.1 ||
        paddingRight > 0.1 ||
        paddingRight < -0.1 ||
        paddingBottom > 0.1 ||
        paddingBottom < -0.1) {
      var initialIconX = (layer.offset.dx - paddingLeft) * scaleX;
      var initialIconY = (layer.offset.dy - paddingTop) * scaleX;
      layer
        ..offset = Offset(
          initialIconX,
          initialIconY,
        )
        ..scale *= scale;
      return true;
    }
    return false;
  }

  /// Flip a layer horizontally or vertically.
  ///
  /// This method flips a layer either horizontally or vertically based on the
  /// specified parameters.
  void flipLayer({
    required Layer layer,
    required bool flipX,
    required bool flipY,
    required bool isHalfPi,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (flipY) {
      if (isHalfPi) {
        layer.flipY = !layer.flipY;
      } else {
        layer.flipX = !layer.flipX;
      }
      layer.offset = Offset(
        imageWidth - layer.offset.dx,
        layer.offset.dy,
      );
    }
    if (flipX) {
      layer
        ..flipX = !layer.flipX
        ..offset = Offset(
          layer.offset.dx,
          imageHeight - layer.offset.dy,
        );
    }
  }

  void _setMinMaxScaleFactor(ProImageEditorConfigs configs, Layer layer) {
    if (layer is PaintLayer) {
      layer.scale = layer.scale.clamp(
        configs.paintEditor.minScale,
        configs.paintEditor.maxScale,
      );
    } else if (layer is TextLayer) {
      layer.scale = layer.scale.clamp(
        configs.textEditor.minScale,
        configs.textEditor.maxScale,
      );
    } else if (layer is EmojiLayer) {
      layer.scale = layer.scale.clamp(
        configs.emojiEditor.minScale,
        configs.emojiEditor.maxScale,
      );
    } else if (layer is WidgetLayer) {
      layer.scale = layer.scale.clamp(
        configs.stickerEditor.minScale,
        configs.stickerEditor.maxScale,
      );
    }
  }

  void _updateAlignmentGuides({
    required List<Layer> layerList,
    required Layer activeLayer,
    required ScaleUpdateDetails detail,
    required StreamController<void> helperLineCtrl,
  }) {
    const snapThreshold = 2.0;
    const releaseThreshold = 20.0;

    final wasHorizontalGuideVisible = isHorizontalGuideVisible;
    final wasVerticalGuideVisible = isVerticalGuideVisible;

    // Reset guide visibility
    isHorizontalGuideVisible = false;
    isVerticalGuideVisible = false;

    Offset? horizontalOffset;
    Offset? verticalOffset;

    for (final layer in layerList) {
      if (verticalOffset != null && horizontalOffset != null) break;
      if (layer == activeLayer) continue;

      final dx = (layer.offset.dx - activeLayer.offset.dx).abs();
      final dy = (layer.offset.dy - activeLayer.offset.dy).abs();

      // Vertical snapping (dx axis)
      if (dx <= snapThreshold) {
        if (_helperFocalX == null ||
            (_helperFocalX! - detail.focalPoint.dx).abs() < releaseThreshold) {
          verticalOffset = layer.offset;
          _helperFocalX ??= detail.focalPoint.dx;
        } else if ((_helperFocalX! - detail.focalPoint.dx).abs() >
            releaseThreshold) {
          _helperFocalX = null;
        }
      }

      // Horizontal snapping (dy axis)
      if (dy <= snapThreshold) {
        if (_helperFocalY == null ||
            (_helperFocalY! - detail.focalPoint.dy).abs() < releaseThreshold) {
          horizontalOffset = layer.offset;
          _helperFocalY ??= detail.focalPoint.dy;
        } else if ((_helperFocalY! - detail.focalPoint.dy).abs() >
            releaseThreshold) {
          _helperFocalY = null;
        }
      }
    }

    // Handle vertical snapping
    if (verticalOffset != null) {
      verticalGuideOffset = verticalOffset;
      isVerticalGuideVisible = true;

      activeLayer.offset = Offset(verticalOffset.dx, activeLayer.offset.dy);
    }

    // Handle horizontal snapping
    if (horizontalOffset != null) {
      horizontalGuideOffset = horizontalOffset;
      isHorizontalGuideVisible = true;

      activeLayer.offset = Offset(activeLayer.offset.dx, horizontalOffset.dy);
    }

    // Notify UI only if something changed
    final hasChanged = isHorizontalGuideVisible != wasHorizontalGuideVisible ||
        isVerticalGuideVisible != wasVerticalGuideVisible;

    if (hasChanged) {
      helperLineCtrl.add(null);

      if ((isHorizontalGuideVisible && !wasHorizontalGuideVisible) ||
          (isVerticalGuideVisible && !wasVerticalGuideVisible)) {
        helperLinesCallbacks?.handleLayerAlignLineHit();
      }
    }
  }
}
