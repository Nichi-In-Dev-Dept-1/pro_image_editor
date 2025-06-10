import 'dart:math';

/// Extension for [double] values that provides safe clamping methods.
extension DoubleExtension on double {
  /// Clamps the double value between [lowerLimit] and [upperLimit],
  /// ensuring [lowerLimit] is not greater than [upperLimit].
  ///
  /// Returns the clamped value as a double.
  ///
  /// Example:
  /// ```dart
  /// 3.5.safeMinClamp(8, 5); // returns 5
  /// 5.5.safeMinClamp(2, 10); // returns 5.5
  /// 12.0.safeMinClamp(2, 10); // returns 10.0
  /// ```
  double safeMinClamp(num lowerLimit, num upperLimit) {
    return clamp(
      min(lowerLimit, upperLimit),
      upperLimit,
    ).toDouble();
  }

  /// Clamps the double value between [lowerLimit] and [upperLimit],
  /// ensuring [upperLimit] is not less than [lowerLimit].
  ///
  /// Returns the clamped value as a double.
  ///
  /// Example:
  /// ```dart
  /// 12.safeMinClamp(8, 5); // returns 8
  /// 1.5.safeMaxClamp(2, 10); // returns 2.0
  /// 5.5.safeMaxClamp(2, 10); // returns 5.5
  /// ```
  double safeMaxClamp(num lowerLimit, num upperLimit) {
    return clamp(
      lowerLimit,
      max(lowerLimit, upperLimit),
    ).toDouble();
  }
}
