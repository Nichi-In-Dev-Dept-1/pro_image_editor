// ignore_for_file: deprecated_member_use_from_same_package
// TODO: Remove deprecated values

import 'package:flutter/widgets.dart';

import '/features/paint_editor/enums/paint_editor_enum.dart';
import '../../custom_widgets/paint_editor_widgets.dart';
import '../../icons/paint_editor_icons.dart';
import '../../styles/paint_editor_style.dart';
import '../utils/editor_safe_area.dart';
import 'censor_configs.dart';

export '../../custom_widgets/paint_editor_widgets.dart';
export '../../icons/paint_editor_icons.dart';
export '../../styles/paint_editor_style.dart';
export 'censor_configs.dart';

/// Configuration options for a paint editor.
///
/// `PaintEditorConfigs` allows you to define settings for a paint editor,
/// including whether the editor is enabled, which drawing tools are available,
/// initial settings for drawing, and more.
///
/// Example usage:
/// ```dart
/// PaintEditorConfigs(
///   enabled: true,
///   canToggleFill: true,
///   canChangeLineWidth: true,
///   enableModeFreeStyle = true,
///   enableModeArrow = true,
///   enableModeLine = true,
///   enableModeRect = true,
///   enableModeCircle = true,
///   enableModeDashLine = true,
///   enableModeBlur = true,
///   enableModePixelate = true,
///   enableModeEraser = true,
///   initialFill: false,
///   showColorPicker: true,
///   initialStrokeWidth: 10.0,
///   initialColor: const Color(0xffff0000),
///   initialPaintMode: PaintMode.freeStyle,
/// );
/// ```
class PaintEditorConfigs {
  /// Creates an instance of PaintEditorConfigs with optional settings.
  ///
  /// By default, the editor is enabled, and most drawing tools are enabled.
  /// Other properties are set to reasonable defaults.
  const PaintEditorConfigs({
    this.enabled = true,
    this.enableZoom = false,
    this.editorMinScale = 1.0,
    this.editorMaxScale = 5.0,
    this.hasOptionFreeStyle,
    this.hasOptionArrow,
    this.hasOptionLine,
    this.hasOptionRect,
    this.hasOptionCircle,
    this.hasOptionDashLine,
    this.hasOptionEraser,
    this.enableModeFreeStyle = true,
    this.enableModeArrow = true,
    this.enableModeLine = true,
    this.enableModeRect = true,
    this.enableModeCircle = true,
    this.enableModeDashLine = true,
    this.enableModeBlur = true,
    this.enableModePixelate = true,
    this.enableModeEraser = true,
    this.canToggleFill = true,
    this.canChangeLineWidth = true,
    this.canChangeOpacity = true,
    this.initialFill = false,
    this.showLayers = true,
    this.boundaryMargin = EdgeInsets.zero,
    this.minScale = double.negativeInfinity,
    this.maxScale = double.infinity,
    this.freeStyleHighPerformanceScaling,
    this.freeStyleHighPerformanceMoving,
    this.freeStyleHighPerformanceHero = false,
    this.initialPaintMode = PaintMode.freeStyle,
    this.censorConfigs = const CensorConfigs(),
    this.safeArea = const EditorSafeArea(),
    this.style = const PaintEditorStyle(),
    this.icons = const PaintEditorIcons(),
    this.widgets = const PaintEditorWidgets(),
  })  : assert(maxScale >= minScale,
            'maxScale must be greater than or equal to minScale'),
        assert(editorMaxScale > editorMinScale,
            'editorMaxScale must be greater than editorMinScale');

  /// Indicates whether the paint editor is enabled.
  final bool enabled;

  /// Indicates whether the editor supports zoom functionality.
  ///
  /// When set to `true`, the editor allows users to zoom in and out, providing
  /// enhanced accessibility and usability, especially on smaller screens or for
  /// users with visual impairments. If set to `false`, the zoom functionality
  /// is disabled, and the editor's content remains at a fixed scale.
  ///
  /// Default value is `false`.
  final bool enableZoom;

  /// Indicating whether the free-style drawing option is enabled.
  @Deprecated('Use enableModeFreeStyle instead.')
  final bool? hasOptionFreeStyle;

  /// Indicating whether the arrow drawing option is enabled.
  @Deprecated('Use enableModeArrow instead.')
  final bool? hasOptionArrow;

  /// Indicating whether the line drawing option is enabled.
  @Deprecated('Use enableModeLine instead.')
  final bool? hasOptionLine;

  /// Indicating whether the rectangle drawing option is enabled.
  @Deprecated('Use enableModeRect instead.')
  final bool? hasOptionRect;

  /// Indicating whether the circle drawing option is enabled.
  @Deprecated('Use enableModeCircle instead.')
  final bool? hasOptionCircle;

  /// Indicating whether the dash line drawing option is enabled.
  @Deprecated('Use enableModeDashLine instead.')
  final bool? hasOptionDashLine;

  /// Indicating whether the eraser option is enabled.
  @Deprecated('Use enableModeEraser instead.')
  final bool? hasOptionEraser;

  /// Indicating whether the free-style drawing option is enabled.
  final bool enableModeFreeStyle;

  /// Indicating whether the arrow drawing option is enabled.
  final bool enableModeArrow;

  /// Indicating whether the line drawing option is enabled.
  final bool enableModeLine;

  /// Indicating whether the rectangle drawing option is enabled.
  final bool enableModeRect;

  /// Indicating whether the circle drawing option is enabled.
  final bool enableModeCircle;

  /// Indicating whether the dash line drawing option is enabled.
  final bool enableModeDashLine;

  /// Indicating whether the blur drawing option is enabled.
  final bool enableModeBlur;

  /// Indicating whether the pixelate drawing option is enabled.
  ///
  /// **IMPORTANT**: This mode is only supported when using the Impeller
  /// rendering engine. On all other platforms, it will automatically be
  /// set to `false`.
  final bool enableModePixelate;

  /// Indicating whether the eraser option is enabled.
  final bool enableModeEraser;

  /// Indicating whether the fill option can be toggled.
  final bool canToggleFill;

  /// Indicating whether the line width can be changed.
  final bool canChangeLineWidth;

  /// Indicating whether the opacity can be changed.
  final bool canChangeOpacity;

  /// Indicates the initial fill state.
  final bool initialFill;

  /// Show the layers from the main-editor.
  final bool showLayers;

  /// Enables high-performance scaling for free-style drawing when set to
  /// `true`.
  ///
  /// When this option is enabled, it optimizes scaling for improved
  /// performance.
  ///
  /// By default, it's set to `true` on mobile devices and `false` on desktop
  /// devices.
  final bool? freeStyleHighPerformanceScaling;

  /// Enables high-performance moving for free-style drawing when set to `true`.
  ///
  /// When this option is enabled, it optimizes moving for improved performance.
  ///
  /// By default, it's set to `true` only on mobile-web devices.
  final bool? freeStyleHighPerformanceMoving;

  /// Enables high-performance hero-animations for free-style drawing when set
  /// to `true`.
  ///
  /// When this option is enabled, it optimizes hero-animations for improved
  /// performance.
  ///
  /// By default, it's set to `false`.
  final bool freeStyleHighPerformanceHero;

  /// Indicates the initial paint mode.
  final PaintMode initialPaintMode;

  /// The minimum scale factor for the editor.
  ///
  /// This value determines the lowest level of zoom that can be applied to the
  /// editor content. It only has an effect when [enableZoom] is set to
  /// `true`.
  /// If [enableZoom] is `false`, this value is ignored.
  ///
  /// Default value is 1.0.
  final double editorMinScale;

  /// The maximum scale factor for the editor.
  ///
  /// This value determines the highest level of zoom that can be applied to the
  /// editor content. It only has an effect when [enableZoom] is set to
  /// `true`.
  /// If [enableZoom] is `false`, this value is ignored.
  ///
  /// Default value is 5.0.
  final double editorMaxScale;

  /// Configuration settings for the censor tool in the paint editor.
  ///
  /// This property holds an instance of [CensorConfigs] which contains
  /// various settings and options for the censoring functionality within
  /// the paint editor.
  final CensorConfigs censorConfigs;

  /// Zoom boundary
  ///
  /// A margin for the visible boundaries of the child.
  ///
  /// Any transformation that results in the viewport being able to view
  /// outside of the boundaries will be stopped at the boundary.
  /// The boundaries do not rotate with the rest of the scene, so they are
  /// always aligned with the viewport.
  ///
  /// To produce no boundaries at all, pass infinite [EdgeInsets], such as
  /// EdgeInsets.all(double.infinity).
  ///
  /// No edge can be NaN.
  ///
  /// Defaults to [EdgeInsets.zero], which results in boundaries that are the
  /// exact same size and position as the [child].
  final EdgeInsets boundaryMargin;

  /// The minimum scale factor from the layer.
  final double minScale;

  /// The maximum scale factor from the layer.
  final double maxScale;

  /// Defines the safe area configuration for the editor.
  final EditorSafeArea safeArea;

  /// Style configuration for the paint editor.
  final PaintEditorStyle style;

  /// Icons used in the paint editor.
  final PaintEditorIcons icons;

  /// Widgets associated with the paint editor.
  final PaintEditorWidgets widgets;

  /// Creates a copy of this `PaintEditorConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [PaintEditorConfigs] with some properties updated while keeping the
  /// others unchanged.
  PaintEditorConfigs copyWith({
    bool? enabled,
    bool? enableZoom,
    bool? hasOptionFreeStyle,
    bool? hasOptionArrow,
    bool? hasOptionLine,
    bool? hasOptionRect,
    bool? hasOptionCircle,
    bool? hasOptionDashLine,
    bool? hasOptionEraser,
    bool? enableModeFreeStyle,
    bool? enableModeArrow,
    bool? enableModeLine,
    bool? enableModeRect,
    bool? enableModeCircle,
    bool? enableModeDashLine,
    bool? enableModeBlur,
    bool? enableModePixelate,
    bool? enableModeEraser,
    bool? canToggleFill,
    bool? canChangeLineWidth,
    bool? canChangeOpacity,
    bool? initialFill,
    bool? freeStyleHighPerformanceScaling,
    bool? freeStyleHighPerformanceMoving,
    bool? freeStyleHighPerformanceHero,
    bool? showLayers,
    PaintMode? initialPaintMode,
    double? editorMinScale,
    double? editorMaxScale,
    double? minScale,
    double? maxScale,
    CensorConfigs? censorConfigs,
    EditorSafeArea? safeArea,
    EdgeInsets? boundaryMargin,
    PaintEditorStyle? style,
    PaintEditorIcons? icons,
    PaintEditorWidgets? widgets,
  }) {
    return PaintEditorConfigs(
      safeArea: safeArea ?? this.safeArea,
      enabled: enabled ?? this.enabled,
      enableZoom: enableZoom ?? this.enableZoom,
      hasOptionFreeStyle: hasOptionFreeStyle ?? this.hasOptionFreeStyle,
      hasOptionArrow: hasOptionArrow ?? this.hasOptionArrow,
      hasOptionLine: hasOptionLine ?? this.hasOptionLine,
      hasOptionRect: hasOptionRect ?? this.hasOptionRect,
      hasOptionCircle: hasOptionCircle ?? this.hasOptionCircle,
      hasOptionDashLine: hasOptionDashLine ?? this.hasOptionDashLine,
      hasOptionEraser: hasOptionEraser ?? this.hasOptionEraser,
      enableModeFreeStyle: enableModeFreeStyle ?? this.enableModeFreeStyle,
      enableModeArrow: enableModeArrow ?? this.enableModeArrow,
      enableModeLine: enableModeLine ?? this.enableModeLine,
      enableModeRect: enableModeRect ?? this.enableModeRect,
      enableModeCircle: enableModeCircle ?? this.enableModeCircle,
      enableModeDashLine: enableModeDashLine ?? this.enableModeDashLine,
      enableModeBlur: enableModeBlur ?? this.enableModeBlur,
      enableModePixelate: enableModePixelate ?? this.enableModePixelate,
      enableModeEraser: enableModeEraser ?? this.enableModeEraser,
      canToggleFill: canToggleFill ?? this.canToggleFill,
      canChangeLineWidth: canChangeLineWidth ?? this.canChangeLineWidth,
      showLayers: showLayers ?? this.showLayers,
      canChangeOpacity: canChangeOpacity ?? this.canChangeOpacity,
      initialFill: initialFill ?? this.initialFill,
      freeStyleHighPerformanceScaling: freeStyleHighPerformanceScaling ??
          this.freeStyleHighPerformanceScaling,
      freeStyleHighPerformanceMoving:
          freeStyleHighPerformanceMoving ?? this.freeStyleHighPerformanceMoving,
      freeStyleHighPerformanceHero:
          freeStyleHighPerformanceHero ?? this.freeStyleHighPerformanceHero,
      initialPaintMode: initialPaintMode ?? this.initialPaintMode,
      editorMinScale: editorMinScale ?? this.editorMinScale,
      censorConfigs: censorConfigs ?? this.censorConfigs,
      editorMaxScale: editorMaxScale ?? this.editorMaxScale,
      boundaryMargin: boundaryMargin ?? this.boundaryMargin,
      minScale: minScale ?? this.minScale,
      maxScale: maxScale ?? this.maxScale,
      style: style ?? this.style,
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
    );
  }
}
