// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Project imports:
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/features/crop_rotate_editor/enums/crop_mode.enum.dart';

/// A [StatefulWidget] that applies transformations to its [child] widget
/// based on provided transformation and editor configurations.
class TransformedContentGenerator extends StatefulWidget {
  /// Creates an instance of [TransformedContentGenerator] with the given
  /// parameters.
  const TransformedContentGenerator({
    required this.child,
    required this.transformConfigs,
    required this.configs,
    this.isVideoPlayer = false,
    super.key,
  });

  /// The widget to which transformations will be applied.
  final Widget child;

  /// Configuration object for the transformations.
  final TransformConfigs transformConfigs;

  /// Configuration object for the image editor.
  final ProImageEditorConfigs configs;

  /// Indicateds if the child is a video player.
  final bool isVideoPlayer;

  @override
  State<TransformedContentGenerator> createState() =>
      _TransformedContentGeneratorState();
}

class _TransformedContentGeneratorState
    extends State<TransformedContentGenerator> {
  TransformConfigs get _transformConfigs => widget.transformConfigs;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        TransformConfigs configs = _transformConfigs;
        Size size = constraints.biggest;

        double fitHelper = 1;

        if (configs.cropEditorScreenRatio != 0) {
          Size originalImageSize = configs.originalSize;

          double originalImageRatio = originalImageSize.aspectRatio;
          double cropRectRatio = configs.cropRect.size.aspectRatio;

          bool is90DegRotated = configs.is90DegRotated;
          double convertedCropRectRatio =
              !is90DegRotated ? cropRectRatio : (1 / cropRectRatio);

          bool originalFitToWidth = size.aspectRatio <= originalImageRatio;
          bool fitToWidth = size.aspectRatio <= convertedCropRectRatio;

          double w = originalImageSize.width / configs.cropRect.width;
          double h = originalImageSize.height / configs.cropRect.height;

          double w1 = size.width / originalImageSize.width;
          double h1 = size.height / originalImageSize.height;

          if (!originalFitToWidth && fitToWidth) {
            fitHelper = w1 / h1;
          } else if (originalFitToWidth && !fitToWidth) {
            fitHelper = h1 / w1;
          } else if (!fitToWidth && cropRectRatio > originalImageRatio) {
            fitHelper = h / w;
          } else if (fitToWidth && cropRectRatio < originalImageRatio) {
            fitHelper = w / h;
          }

          if (is90DegRotated) {
            if (originalFitToWidth && fitToWidth) {
              fitHelper *= cropRectRatio;
            } else if (!originalFitToWidth && !fitToWidth) {
              fitHelper /= cropRectRatio;
            } else {
              bool useOriginalImageSize = (originalFitToWidth &&
                      cropRectRatio > originalImageRatio) ||
                  (!originalFitToWidth && cropRectRatio < originalImageRatio);

              if (fitToWidth) {
                fitHelper *=
                    useOriginalImageSize ? originalImageRatio : cropRectRatio;
              } else {
                fitHelper /=
                    useOriginalImageSize ? originalImageRatio : cropRectRatio;
              }
            }
          }
        }

        return FittedBox(
          child: SizedBox(
            width: configs.originalSize.isInfinite
                ? null
                : configs.originalSize.width,
            height: configs.originalSize.isInfinite
                ? null
                : configs.originalSize.height,
            child: Transform.scale(
              scale: fitHelper,
              child: _buildRotationTransform(
                child: _buildFlipTransform(
                  child: _buildCropPainter(
                    child: _buildUserScaleTransform(
                      child: _buildTranslate(
                        child: widget.child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Transform _buildRotationTransform({required Widget child}) {
    return Transform.rotate(
      angle: _transformConfigs.angle,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildFlipTransform({required Widget child}) {
    return Transform.flip(
      flipX: _transformConfigs.flipX,
      flipY: _transformConfigs.flipY,
      child: child,
    );
  }

  Widget _buildCropPainter({required Widget child}) {
    if (kIsWeb && widget.isVideoPlayer) return child;

    CropMode cropMode = _transformConfigs.cropMode ??
        widget.configs.cropRotateEditor.initialCropMode;

    final clipper = CutOutsideArea(
      configs: _transformConfigs,
      cropMode: cropMode,
    );

    if (cropMode == CropMode.oval) {
      return ClipOval(clipper: clipper, child: child);
    } else {
      return ClipRect(clipper: clipper, child: child);
    }
  }

  Transform _buildUserScaleTransform({required Widget child}) {
    return Transform.scale(
      scale: _transformConfigs.scaleUser,
      alignment: Alignment.center,
      child: child,
    );
  }

  Transform _buildTranslate({required Widget child}) {
    return Transform.translate(
      offset: _transformConfigs.offset,
      child: child,
    );
  }
}

/// A [CustomClipper] that defines the clipping area based on provided
/// configurations.
class CutOutsideArea extends CustomClipper<Rect> {
  /// Creates an instance of [CutOutsideArea] with the given [configs].
  CutOutsideArea({
    required this.configs,
    required this.cropMode,
  });

  /// Defines the cropping shape to apply to an image or video.
  final CropMode cropMode;

  /// The configuration object that provides the crop rectangle.
  final TransformConfigs configs;

  @override
  Rect getClip(Size size) {
    Rect cropRect = configs.cropRect;
    if (configs.isEmpty && cropMode == CropMode.oval) {
      cropRect = Rect.fromLTWH(0, 0, size.width, size.height);
    }

    return Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cropRect.width,
      height: cropRect.height,
    );
  }

  @override
  bool shouldReclip(covariant CustomClipper<Rect> oldClipper) {
    return oldClipper is! CutOutsideArea ||
        oldClipper.configs != configs ||
        oldClipper.cropMode != cropMode;
  }
}
