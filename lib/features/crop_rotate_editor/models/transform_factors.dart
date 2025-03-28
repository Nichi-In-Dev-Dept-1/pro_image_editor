// Flutter imports:
import 'dart:math';

import 'package:flutter/widgets.dart';

import '/features/crop_rotate_editor/enums/crop_rotate_angle_side.dart';
import '/features/crop_rotate_editor/utils/rotate_angle.dart';

/// A class representing configuration settings for image transformation.
///
/// This class provides properties and methods to configure and manage image
/// transformations, such as cropping, rotating, scaling, and flipping.
class TransformConfigs {
  /// Creates a [TransformConfigs] instance with the specified parameters.
  ///
  /// The parameters include properties for angle, crop rectangle, original
  /// size, scaling factors, aspect ratio, flip options, and offset.
  ///
  /// Example:
  /// ```
  /// TransformConfigs(
  ///   angle: 0,
  ///   cropRect: Rect.fromLTWH(0, 0, 100, 100),
  ///   originalSize: Size(200, 200),
  ///   cropEditorScreenRatio: 1.0,
  ///   scaleUser: 1.0,
  ///   scaleRotation: 1.0,
  ///   aspectRatio: 1.0,
  ///   flipX: false,
  ///   flipY: false,
  ///   offset: Offset.zero,
  /// )
  /// ```
  TransformConfigs({
    required this.angle,
    required this.cropRect,
    required this.originalSize,
    required this.cropEditorScreenRatio,
    required this.scaleUser,
    required this.scaleRotation,
    required this.aspectRatio,
    required this.flipX,
    required this.flipY,
    required this.offset,
  });

  /// Creates a [TransformConfigs] instance from a map.
  ///
  /// The map should contain keys corresponding to the properties of
  /// `TransformConfigs`, and each key should map to the appropriate value.
  factory TransformConfigs.fromMap(Map<String, dynamic> map) {
    return TransformConfigs(
      angle: map['angle'] ?? 0,
      cropRect: Rect.fromLTRB(
        map['cropRect']?['left'] ?? 0,
        map['cropRect']?['top'] ?? 0,
        map['cropRect']?['right'] ?? 0,
        map['cropRect']?['bottom'] ?? 0,
      ),
      originalSize: Size(
        map['originalSize']?['width'] ?? 0,
        map['originalSize']?['height'] ?? 0,
      ),
      cropEditorScreenRatio: map['cropEditorScreenRatio'] ?? 0,
      scaleUser: map['scaleUser'] ?? 1,
      scaleRotation: map['scaleRotation'] ?? 1,
      aspectRatio: map['aspectRatio'] ?? -1,
      flipX: map['flipX'] ?? false,
      flipY: map['flipY'] ?? false,
      offset: Offset(
        map['offset']?['dx'] ?? 0,
        map['offset']?['dy'] ?? 0,
      ),
    );
  }

  /// Creates an empty [TransformConfigs] instance with default values.
  ///
  /// This factory constructor initializes all properties with default values,
  /// representing a non-configured state.
  factory TransformConfigs.empty() {
    return TransformConfigs(
      angle: 0,
      originalSize: Size.infinite,
      cropRect: Rect.largest,
      cropEditorScreenRatio: 0,
      scaleUser: 1,
      scaleRotation: 1,
      aspectRatio: -1,
      flipX: false,
      flipY: false,
      offset: const Offset(0, 0),
    );
  }

  /// The offset used for transformations.
  ///
  /// This offset represents the position adjustment applied to the image during
  /// transformations.
  final Offset offset;

  /// The crop rectangle specifying the cropped area.
  ///
  /// This rectangle defines the region of the image that is visible after
  /// cropping.
  late Rect cropRect;

  /// The original size of the image before transformation.
  ///
  /// This size represents the dimensions of the image in its unaltered state.
  late Size originalSize;

  /// The screen ratio used in the crop editor.
  ///
  /// This ratio specifies the aspect ratio of the screen in the crop editor,
  /// affecting how the image is displayed and manipulated.
  late double cropEditorScreenRatio;

  /// The angle of rotation applied to the image.
  ///
  /// This angle specifies the degree of rotation, with positive values
  /// indicating clockwise rotation and negative values indicating
  /// counter-clockwise rotation.
  final double angle;

  /// The user-defined scaling factor.
  ///
  /// This factor represents the scaling applied to the image based on user
  /// input, allowing for zooming in and out.
  final double scaleUser;

  /// The scaling factor due to rotation.
  ///
  /// This factor represents the scaling applied to the image due to its
  /// rotation, affecting its overall size and aspect ratio.
  final double scaleRotation;

  /// The aspect ratio of the image.
  ///
  /// This value specifies the ratio of width to height for the image,
  /// determining its overall shape and proportions.
  final double aspectRatio;

  /// Indicates whether the image is flipped horizontally.
  ///
  /// This boolean flag specifies whether the image has been flipped along the
  /// horizontal axis.
  final bool flipX;

  /// Indicates whether the image is flipped vertically.
  ///
  /// This boolean flag specifies whether the image has been flipped along the
  /// vertical axis.
  final bool flipY;

  /// Checks if the transformation configurations are empty.
  ///
  /// This property returns `true` if all properties are in their default states
  /// and no transformations have been applied.
  bool get isEmpty {
    return angle == 0 &&
        originalSize == Size.infinite &&
        cropRect == Rect.largest &&
        cropEditorScreenRatio == 0 &&
        scaleUser == 1 &&
        scaleRotation == 1 &&
        aspectRatio == -1 &&
        flipX == false &&
        flipY == false &&
        offset == const Offset(0, 0);
  }

  /// Checks if the transformation configurations are not empty.
  ///
  /// This property returns `true` if any transformations have been applied.
  bool get isNotEmpty => !isEmpty;

  /// Returns the combined scale from user input and rotation.
  ///
  /// This property calculates the overall scale factor by multiplying the user
  /// scale and the rotation scale.
  double get scale => scaleUser * scaleRotation;

  /// Checks if the image is rotated 90 degrees.
  ///
  /// This property returns `true` if the image is rotated to the left or right
  /// by 90 degrees.
  bool get is90DegRotated {
    RotateAngleSide factor = getRotateAngleSide(angle);
    return factor == RotateAngleSide.left || factor == RotateAngleSide.right;
  }

  /// Converts the angle (in radians) to the number of 90-degree turns
  /// (quarter turns).
  ///
  /// The method assumes that a 90-degree turn is equivalent to π/2 radians.
  /// It calculates the number of quarter turns by dividing the angle by π/2
  /// and rounding the result to the nearest integer.
  ///
  /// Returns:
  ///   An integer representing the number of 90-degree turns.
  int angleToTurns() {
    const double halfPi = 3.141592653589793 / 2; // 90 degrees
    return (angle / halfPi).round();
  }

  /// Converts the transformation configurations to a map.
  ///
  /// This method returns a map representation of the transformation settings,
  /// suitable for serialization or debugging.
  Map<String, dynamic> toMap() {
    if (isEmpty) return {};
    return {
      'angle': angle,
      'cropRect': {
        'left': cropRect.left,
        'top': cropRect.top,
        'right': cropRect.right,
        'bottom': cropRect.bottom,
      },
      'originalSize': {
        'width': originalSize.width,
        'height': originalSize.height,
      },
      'cropEditorScreenRatio': cropEditorScreenRatio,
      'scaleUser': scaleUser,
      'scaleRotation': scaleRotation,
      'aspectRatio': aspectRatio,
      'flipX': flipX,
      'flipY': flipY,
      'offset': {
        'dx': offset.dx,
        'dy': offset.dy,
      },
    };
  }

  /// Returns the top-left offset of the crop area in the original image
  /// coordinates.
  ///
  /// [rawImageSize] is the size of the unscaled original image.
  /// Takes into account user transformations like pan and zoom.
  Offset getCropStartOffset(Size rawImageSize) {
    double originalWidth = rawImageSize.width;
    double originalHeight = rawImageSize.height;

    double renderWidth = originalSize.width;
    double renderHeight = originalSize.height;

    Offset transformOffset = offset;

    double horizontalPadding = (renderWidth - cropRect.width / scaleUser) / 2;
    double verticalPadding = (renderHeight - cropRect.height / scaleUser) / 2;

    /// Calculate crop offset in original coordinates
    Offset cropOffset = Offset(
      horizontalPadding - transformOffset.dx,
      verticalPadding - transformOffset.dy,
    );

    /// Calculate scale factors for the offset
    double offsetXScale = renderWidth / cropOffset.dx;
    double offsetYScale = renderHeight / cropOffset.dy;

    return Offset(
      max(0, originalWidth / offsetXScale),
      max(0, originalHeight / offsetYScale),
    );
  }

  /// Returns the size of the crop area in the original image coordinates.
  ///
  /// [rawImageSize] is the size of the unscaled original image.
  /// The result is scaled based on the user's zoom level.
  Size getCropSize(Size rawImageSize) {
    double originalWidth = rawImageSize.width;
    double originalHeight = rawImageSize.height;

    double renderWidth = originalSize.width;
    double renderHeight = originalSize.height;

    /// Calculate scale factors based on crop dimensions
    double widthScale = renderWidth / cropRect.width;
    double heightScale = renderHeight / cropRect.height;

    return Size(
          originalWidth / widthScale,
          originalHeight / heightScale,
        ) /
        scaleUser;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is TransformConfigs &&
        other.offset == offset &&
        other.cropRect == cropRect &&
        other.originalSize == originalSize &&
        other.cropEditorScreenRatio == cropEditorScreenRatio &&
        other.angle == angle &&
        other.scaleUser == scaleUser &&
        other.scaleRotation == scaleRotation &&
        other.aspectRatio == aspectRatio &&
        other.flipX == flipX &&
        other.flipY == flipY;
  }

  @override
  int get hashCode {
    return offset.hashCode ^
        angle.hashCode ^
        cropRect.hashCode ^
        originalSize.hashCode ^
        cropEditorScreenRatio.hashCode ^
        scaleUser.hashCode ^
        scaleRotation.hashCode ^
        aspectRatio.hashCode ^
        flipX.hashCode ^
        flipY.hashCode;
  }
}

/// An enumeration representing the maximum side of an image.
///
/// This enum defines whether the maximum side of an image is horizontal,
/// vertical, or unset.
enum ImageMaxSide {
  /// Indicates that the maximum side is horizontal.
  horizontal,

  /// Indicates that the maximum side is vertical.
  vertical,

  /// Indicates that the maximum side is unset.
  unset
}
