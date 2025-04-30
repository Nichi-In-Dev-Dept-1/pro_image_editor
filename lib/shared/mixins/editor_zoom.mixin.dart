import 'package:flutter/widgets.dart';

import '/core/models/editor_configs/utils/zoom_configs.dart';
import '../utils/debounce.dart';
import '../widgets/extended/extended_interactive_viewer.dart';

/// A mixin that provides zoom-related behavior for image or content editors.
///
/// This includes logic for double-tap detection, zoom control, and reset
/// actions. It expects a [GlobalKey] reference to an
/// [ExtendedInteractiveViewerState] implementation.
mixin EditorZoomMixin<T extends StatefulWidget> on State<T> {
  /// Stores the position of the last pointer down event, used for zoom focus.
  Offset? _lastTapDownOffset;

  /// A debounce utility to track timing between double-tap events.
  final _doubleTapDebounce = Debounce(const Duration(milliseconds: 300));

  /// Helper counter to track consecutive tap events.
  int _doubleTapCountHelper = 0;

  /// A reference to the [ExtendedInteractiveViewer]'s global key.
  ///
  /// This must be implemented by the consuming widget to control zoom behavior.
  GlobalKey<ExtendedInteractiveViewerState> get interactiveViewer;

  @override
  void dispose() {
    _doubleTapDebounce.dispose();
    super.dispose();
  }

  /// Detects whether a [PointerDownEvent] is part of a double-tap gesture.
  ///
  /// Returns `true` if two taps occur within the debounce duration.
  @protected
  bool detectDoubleTap(PointerDownEvent details) {
    _lastTapDownOffset = details.position;
    _doubleTapCountHelper++;
    _doubleTapDebounce(() {
      _doubleTapCountHelper = 0;
    });
    return _doubleTapCountHelper == 2;
  }

  /// Handles a confirmed double-tap gesture and performs a zoom action.
  ///
  /// Converts the global tap position to local coordinates and zooms in using
  /// the configuration provided in [configs].
  @protected
  void handleDoubleTap(
    BuildContext context,
    PointerDownEvent details,
    ZoomConfigs configs,
  ) {
    if (configs.enableDoubleTapZoom && _lastTapDownOffset != null) {
      final renderBox = context.findRenderObject() as RenderBox;
      final localTap = renderBox.globalToLocal(_lastTapDownOffset!);
      interactiveViewer.currentState?.quickZoomTo(
        localTap,
        configs.doubleTapZoomFactor,
        curve: configs.doubleTapZoomCurve,
        duration: configs.doubleTapZoomDuration,
      );
    }
  }

  /// Programmatically zooms the editor to a given offset and/or scale.
  ///
  /// If [offset] or [scale] is null, defaults will be used.
  void zoomTo({Offset? offset, double? scale}) {
    interactiveViewer.currentState?.zoomTo(offset: offset, scale: scale);
  }

  /// Returns the current scale factor of the image editor.
  double get editorScaleFactor =>
      interactiveViewer.currentState?.scaleFactor ?? 1.0;

  /// Resets the zoom and pan of the image editor.
  void resetZoom() {
    interactiveViewer.currentState?.reset();
  }
}
