// Flutter imports:
import 'package:flutter/material.dart';

import '/features/filter_editor/types/filter_matrix.dart';
import '/features/tune_editor/models/tune_adjustment_matrix.dart';
import '../editor_callbacks/pro_image_editor_callbacks.dart';
import '../editor_configs/pro_image_editor_configs.dart';
import '../layers/layer.dart';

/// TODO: Remove deprecated callbacks

/// Configuration class for initializing the image editor.
///
/// This class holds various configurations needed to initialize the image
/// editor.
abstract class EditorInitConfigs {
  /// Creates a new instance of [EditorInitConfigs].
  ///
  /// The [theme] parameter specifies the theme data for the editor.
  /// The [configs] parameter specifies the configuration options for the image
  /// editor.
  /// The [callbacks] parameter specifies the callback options for the image
  /// editor.
  /// The [mainImageSize] parameter specifies the size of the image with layers
  /// applied.
  /// The [mainBodySize] parameter specifies the size of the body with layers
  /// applied.
  /// The [appliedFilters] parameter specifies the list of applied filters.
  /// The [appliedBlurFactor] parameter specifies the applied blur factor.
  /// The [transformConfigs] parameter specifies the transformation
  /// configurations for the editor.
  /// The [layers] parameter specifies the layers in the editor.
  const EditorInitConfigs({
    required this.theme,
    this.configs = const ProImageEditorConfigs(),
    this.callbacks = const ProImageEditorCallbacks(),
    this.mainImageSize,
    this.mainBodySize,
    this.transformConfigs,
    this.appliedFilters = const [],
    this.appliedTuneAdjustments = const [],
    this.appliedBlurFactor = 0,
    this.layers,
    @Deprecated('Use [callbacks.onCloseEditor] instead') this.onCloseEditor,
    @Deprecated('Use [callbacks.onImageEditingComplete] instead')
    this.onImageEditingComplete,
    @Deprecated('Use [callbacks.onImageEditingStarted] instead')
    this.onImageEditingStarted,
    this.convertToUint8List = false,
    this.enableCloseButton = true,
  });

  /// Determines whether the close button is displayed on the widget.
  final bool enableCloseButton;

  /// The configuration options for the image editor.
  final ProImageEditorConfigs configs;

  /// The callbacks for the image editor.
  final ProImageEditorCallbacks callbacks;

  /// The size of the image in the main editor.
  final Size? mainImageSize;

  /// The size of the body with layers applied.
  final Size? mainBodySize;

  /// The list of applied filters.
  final FilterMatrix appliedFilters;

  /// The list of applied tune adjustments.
  final List<TuneAdjustmentMatrix> appliedTuneAdjustments;

  /// The applied blur factor.
  final double appliedBlurFactor;

  /// The transformation configurations for the editor.
  final TransformConfigs? transformConfigs;

  /// The theme data for the editor.
  final ThemeData theme;

  /// The layers in the editor.
  final List<Layer>? layers;

  /// Determines whether to return the image as a Uint8List when closing the
  /// editor.
  final bool convertToUint8List;

  /// **Deprecated:** Use `callbacks.onImageEditingComplete` instead.
  ///
  /// A callback function that will be called when the editing is done,
  /// and it returns the edited image as a `Uint8List` with the format `jpg`.
  ///
  /// The edited image is provided as a Uint8List to the
  /// [onImageEditingComplete] function when the editing is completed.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_capture_image.jpeg?raw=true" alt="Schema" height="500px"/>
  @Deprecated('Use [callbacks.onImageEditingComplete] instead')
  final ImageEditingCompleteCallback? onImageEditingComplete;

  /// **Deprecated:** Use `callbacks.onImageEditingStarted` instead.
  ///
  /// A callback function that is triggered when the image generation is
  /// started.
  @Deprecated('Use [callbacks.onImageEditingStarted] instead')
  final Function()? onImageEditingStarted;

  /// **Deprecated:** Use `callbacks.onCloseEditor` instead.
  ///
  /// A callback function that will be called before the image editor will
  /// close.
  ///
  /// <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/schema_capture_image.jpeg?raw=true" alt="Schema" height="500px" />
  @Deprecated('Use [callbacks.onCloseEditor] instead')
  final ImageEditingEmptyCallback? onCloseEditor;
}
