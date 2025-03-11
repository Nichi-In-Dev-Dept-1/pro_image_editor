import '../styles/helper_line_style.dart';

export '../styles/helper_line_style.dart';

/// The `HelperLineConfigs` class defines the settings for displaying helper
/// lines in the image editor.
/// Helper lines are used to guide users in positioning and rotating layers.
///
/// Usage:
///
/// ```dart
/// HelperLineConfigs helperLines = HelperLineConfigs(
///   showVerticalLine: true,
///   showHorizontalLine: true,
///   showRotateLine: true,
/// );
/// ```
///
/// Properties:
///
/// - `showVerticalLine`: Specifies whether to show the vertical helper line.
///
/// - `showHorizontalLine`: Specifies whether to show the horizontal helper
///   line.
///
/// - `showRotateLine`: Specifies whether to show the rotate helper line.
///
/// Example Usage:
///
/// ```dart
/// HelperLineConfigs helperLines = HelperLineConfigs(
///   showVerticalLine: true,
///   showHorizontalLine: true,
///   showRotateLine: true,
/// );
///
/// bool showVerticalLine = helperLines.showVerticalLine;
/// bool showHorizontalLine = helperLines.showHorizontalLine;
/// // Access other helper lines settings...
/// ```
class HelperLineConfigs {
  /// Creates an instance of the `HelperLines` class with the specified
  /// settings.
  const HelperLineConfigs({
    this.showVerticalLine = true,
    this.showHorizontalLine = true,
    this.showRotateLine = true,
    this.style = const HelperLineStyle(),
  });

  /// Specifies whether to show the vertical helper line.
  final bool showVerticalLine;

  /// Specifies whether to show the horizontal helper line.
  final bool showHorizontalLine;

  /// Specifies whether to show the rotate helper line.
  final bool showRotateLine;

  /// Style configuration for helper lines.
  final HelperLineStyle style;

  /// Creates a copy of this `HelperLineConfigs` object with the given fields
  /// replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [HelperLineConfigs] with some properties updated while keeping the
  /// others unchanged.
  HelperLineConfigs copyWith({
    bool? showVerticalLine,
    bool? showHorizontalLine,
    bool? showRotateLine,
    HelperLineStyle? style,
  }) {
    return HelperLineConfigs(
      showVerticalLine: showVerticalLine ?? this.showVerticalLine,
      showHorizontalLine: showHorizontalLine ?? this.showHorizontalLine,
      showRotateLine: showRotateLine ?? this.showRotateLine,
      style: style ?? this.style,
    );
  }
}
