import 'tune_adjustment_matrix.dart';

/// This will hold the list of tune changes as well as single tune changes
class TuneEditBatch {
  // Optional: to label auto-tune edits etc.

  /// Constructor for TuneBatch class
  TuneEditBatch(this.state, {this.label});

  /// Holds the list of [TuneAdjustmentMatrix] changes
  final List<TuneAdjustmentMatrix> state;

  /// This is a optional value for keep the track of auto tune values
  final String? label;
}
