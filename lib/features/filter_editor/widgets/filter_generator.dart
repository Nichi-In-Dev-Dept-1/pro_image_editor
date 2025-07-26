// Flutter imports:
import 'package:flutter/widgets.dart';

import '../../tune_editor/models/tune_adjustment_matrix.dart';
import '../types/filter_matrix.dart';

/// A widget for applying color filters to its child widget.
class ColorFilterGenerator extends StatefulWidget {
  /// Constructor for creating an instance of ColorFilterGenerator.
  const ColorFilterGenerator({
    super.key,
    required this.filters,
    required this.tuneAdjustments,
    required this.child,
  });

  /// The matrix of filters to apply.
  final FilterMatrix filters;

  /// The matrix of tune adjustments to apply.
  final List<TuneAdjustmentMatrix> tuneAdjustments;

  /// The child widget to which the filters are applied.
  final Widget child;

  /// Creates the state for the ColorFilterGenerator widget.
  @override
  State<ColorFilterGenerator> createState() => ColorFilterGeneratorState();
}

/// The state class for the `ColorFilterGenerator` widget.
///
/// This class is responsible for managing the state of the
/// `ColorFilterGenerator` widget, which includes handling the generation and
/// application of color filters.
///
/// It extends the `State` class, which means it holds mutable state for the
/// `ColorFilterGenerator` widget.
class ColorFilterGeneratorState extends State<ColorFilterGenerator> {
  late List<double> _combinedMatrix;

  /// Identity color matrix.
  final _identityMatrix = <double>[
    // Row R
    1, 0, 0, 0, 0,
    // Row G
    0, 1, 0, 0, 0,
    // Row B
    0, 0, 1, 0, 0,
    // Row A
    0, 0, 0, 1, 0
  ];

  @override
  void initState() {
    super.initState();
    _recomputeMatrix();
  }

  @override
  void didUpdateWidget(covariant ColorFilterGenerator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.filters.hashCode != widget.filters.hashCode ||
        oldWidget.tuneAdjustments.hashCode != widget.tuneAdjustments.hashCode) {
      _recomputeMatrix();
    }
  }

  /// Refreshes the filter editor by generating the filtered widget and
  /// updating the state.
  void refresh() {
    _recomputeMatrix();
    setState(() {});
  }

  /// Multiplies two 4×5 color‐matrices (each a List of length 20).
  /// Returns the composed matrix: applying [b] then [a].
  List<double> _multiplyMatrices(List<double> a, List<double> b) {
    const int size = 4;
    List<double> result = List.filled(20, 0.0);

    for (int row = 0; row < size; row++) {
      for (int col = 0; col < 5; col++) {
        double sum = (col == 4) ? a[row * 5 + 4] : 0.0;
        for (int k = 0; k < size; k++) {
          sum += a[row * 5 + k] * b[k * 5 + col];
        }
        result[row * 5 + col] = sum;
      }
    }

    return result;
  }

  void _recomputeMatrix() {
    List<double> combinedMatrix = List.of(_identityMatrix);

    // Combine filters
    for (final filterMatrix in widget.filters) {
      combinedMatrix = _multiplyMatrices(filterMatrix, combinedMatrix);
    }
    // Combine tune adjustments
    for (final tune in widget.tuneAdjustments) {
      combinedMatrix = _multiplyMatrices(tune.matrix, combinedMatrix);
    }

    _combinedMatrix = combinedMatrix;
  }

  @override
  Widget build(BuildContext context) {
    return ColorFiltered(
      colorFilter: ColorFilter.matrix(_combinedMatrix),
      child: widget.child,
    );
  }
}
