import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/models/video/trim_duration_span_model.dart';
import 'package:pro_image_editor/shared/widgets/video/trimmer/video_editor_play_time_indicator.dart';
import '../video_editor_configurable.dart';
import 'video_editor_trim_handle.dart';
import 'video_editor_trim_thumbnail_bar.dart';

class VideoEditorTrimBar extends StatefulWidget {
  const VideoEditorTrimBar({
    super.key,
  });

  @override
  _VideoEditorTrimBarState createState() => _VideoEditorTrimBarState();
}

class _VideoEditorTrimBarState extends State<VideoEditorTrimBar> {
  double _trimStart = 0;
  double _trimEnd = 1;
  double _scale = 1.0;
  double _baseScale = 1.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;
  final _scrollCtrl = ScrollController();

  VideoEditorConfigurable get _player => VideoEditorConfigurable.of(context);

  int get _videoDuration => _player.controller.videoDuration.inMicroseconds;
  double get _minTrimPercentage =>
      _player.configs.minTrimDuration.inMicroseconds / _videoDuration;

  bool _isUpdatingTrimBar = false;

  void _updateTrimSpan() {
    _player.controller.setTrimSpan(
      TrimDurationSpan(
        start: Duration(microseconds: (_trimStart * _videoDuration).toInt()),
        end: Duration(microseconds: (_trimEnd * _videoDuration).toInt()),
      ),
    );
    _isUpdatingTrimBar = true;
    setState(() {});
  }

  void _updateTrimStart(double value) {
    double minEnd = value + _minTrimPercentage;
    _trimStart = value;
    _trimEnd = max(_trimEnd, minEnd);

    if (_trimEnd > 1) {
      _trimStart = 1 - _minTrimPercentage;
      _trimEnd = 1;
    }

    _updateTrimSpan();
  }

  void _updateTrimEnd(double value) {
    double minStart = value - _minTrimPercentage;
    _trimEnd = value;
    _trimStart = min(_trimStart, minStart);

    if (_trimStart < 0) {
      _trimStart = 0;
      _trimEnd = _minTrimPercentage;
    }

    _updateTrimSpan();
  }

  void _updateScrollbar(double value) {
    _scrollCtrl.jumpTo(
      max(
        0,
        min(
          _scrollCtrl.position.maxScrollExtent,
          _scrollCtrl.offset - value,
        ),
      ),
    );
  }

  void _updateDragTrimBar(DragUpdateDetails details, double scaledWidth) {
    double factor = details.primaryDelta! / scaledWidth;
    double newValueStart = _trimStart + factor;
    double newValueEnd = _trimEnd + factor;

    if (newValueStart >= 0 && newValueEnd <= 1) {
      _updateTrimStart(newValueStart);
      _updateTrimEnd(newValueEnd);
    } else if (newValueEnd > 1 && _trimEnd != 1) {
      double diff = 1 - _trimEnd;
      _updateTrimStart(_trimStart + diff);
      _updateTrimEnd(_trimEnd + diff);
    } else if (newValueStart < 0 && _trimStart != 0) {
      _updateTrimStart(0);
      _updateTrimEnd(_trimEnd - _trimStart);
    } else {
      _updateScrollbar(details.delta.dx);
    }
  }

  void _triggerTrimSpanEnd() {
    _player.callbacks.onTrimSpanEnd?.call(
      TrimDurationSpan(
        start: Duration(microseconds: (_trimStart * _videoDuration).toInt()),
        end: Duration(microseconds: (_trimEnd * _videoDuration).toInt()),
      ),
    );
    _isUpdatingTrimBar = false;
    setState(() {});
  }

  void _handleMouseScroll(PointerSignalEvent event, double trimBarWidth) {
    if (event is! PointerScrollEvent) return;

    // Define zoom factor dynamically based on scroll speed
    double factor = 0.05 * (event.scrollDelta.dy / 50).abs().clamp(0.5, 2);

    double deltaY = event.scrollDelta.dy *
        (_player.configs.trimBarInvertMouseScroll ? -1 : 1);

    double startZoom = _scale;
    double newZoom = _scale;

    // Adjust zoom based on scroll direction
    if (deltaY > 0) {
      newZoom -= factor;
      newZoom = max(_minScale, newZoom);
    } else if (deltaY < 0) {
      newZoom += factor;
      newZoom = min(_maxScale, newZoom);
    }

    /// Get the local mouse position relative to the trim bar
    double mouseX = event.localPosition.dx;

    /// Get the total scrollable width
    double scaledWidth = trimBarWidth * startZoom;
    double newScaledWidth = trimBarWidth * newZoom;

    /// Convert mouse position to percentage in the current zoom level
    double mousePositionPercent = (mouseX + _scrollCtrl.offset) / scaledWidth;

    /// Compute the new scroll offset so that zooming happens around
    /// the mouse pointer
    double newScrollOffset = (mousePositionPercent * newScaledWidth) - mouseX;

    /// Ensure new scroll offset is within valid range
    double clampedScrollOffset = max(
      0,
      min(_scrollCtrl.position.maxScrollExtent, newScrollOffset),
    );

    setState(() {
      _scale = newZoom;
    });

    // Apply the new scroll position
    _scrollCtrl.jumpTo(clampedScrollOffset);
  }

  double get _minInteractiveDimension =>
      Theme.of(context).materialTapTargetSize == MaterialTapTargetSize.padded
          ? kMinInteractiveDimension
          : 0;

  @override
  Widget build(BuildContext context) {
    if (_player.widgets.trimBar != null) return _player.widgets.trimBar!;

    return RepaintBoundary(
      child: LayoutBuilder(builder: (_, constraints) {
        double trimBarWidth =
            constraints.maxWidth - _player.contentPadding.horizontal;
        double scaledWidth = trimBarWidth * _scale;
        double trimWidth = (_trimEnd - _trimStart) * scaledWidth;
        double offsetLeftHandler = _trimStart * scaledWidth;
        double offsetRightHandler = _trimEnd * scaledWidth -
            max(_minInteractiveDimension, _player.style.trimBarHandlerWidth);

        return Listener(
          onPointerSignal: (ev) => _handleMouseScroll(ev, trimBarWidth),
          child: GestureDetector(
            onScaleStart: (ScaleStartDetails details) {
              _baseScale = _scale;
            },
            onScaleUpdate: (ScaleUpdateDetails details) {
              setState(() {
                _scale =
                    (_baseScale * details.scale).clamp(_minScale, _maxScale);
              });
            },
            child: SingleChildScrollView(
              padding: _player.contentPadding,
              controller: _scrollCtrl,
              scrollDirection: Axis.horizontal,
              child: Container(
                width: scaledWidth,
                padding: const EdgeInsets.only(top: 8.0),
                child: Stack(
                  children: [
                    /// Trimmer background
                    GestureDetector(
                      onHorizontalDragEnd: (_) => _triggerTrimSpanEnd(),
                      onHorizontalDragUpdate: (details) {
                        _updateScrollbar(details.delta.dx);
                      },
                      child: const VideoEditorTrimThumbnailBar(),
                    ),

                    /// Outside shadows
                    ..._buildOutsideShadows(
                      offsetLeftHandler,
                      offsetRightHandler,
                      scaledWidth,
                    ),

                    /// Play-time indicator
                    if (!_isUpdatingTrimBar)
                      VideoEditorPlayTimeIndicator(trimBarWidth: scaledWidth),

                    /// Trim body area
                    _buildTrimBodyArea(
                      offsetLeftHandler,
                      offsetRightHandler,
                      scaledWidth,
                      trimWidth,
                    ),

                    /// Trim handler left
                    _buildResizeHandler(true, offsetLeftHandler, scaledWidth),

                    /// Trim handler right
                    _buildResizeHandler(false, offsetRightHandler, scaledWidth),
                  ],
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  List<Widget> _buildOutsideShadows(
    double offsetLeftHandler,
    double offsetRightHandler,
    double scaledWidth,
  ) {
    double radiusWidth = _player.style.trimBarHandlerRadius;
    return [
      Positioned(
        left: 0,
        width: offsetLeftHandler + radiusWidth,
        height: _player.style.trimBarHeight,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: _player.style.trimBarOutsideAreaBackground,
              borderRadius: BorderRadius.horizontal(
                left: Radius.circular(_player.style.trimBarHandlerRadius),
              ),
            ),
          ),
        ),
      ),
      Positioned(
        left: offsetRightHandler,
        width: scaledWidth - offsetRightHandler,
        height: _player.style.trimBarHeight,
        child: IgnorePointer(
          child: Container(
            decoration: BoxDecoration(
              color: _player.style.trimBarOutsideAreaBackground,
              borderRadius: BorderRadius.horizontal(
                right: Radius.circular(_player.style.trimBarHandlerRadius),
              ),
            ),
          ),
        ),
      ),
    ];
  }

  Widget _buildTrimBodyArea(
    double offsetLeftHandler,
    double offsetRightHandler,
    double scaledWidth,
    double trimWidth,
  ) {
    return Positioned(
      left: offsetLeftHandler,
      width: offsetRightHandler -
          offsetLeftHandler +
          max(_minInteractiveDimension, _player.style.trimBarHandlerWidth),
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (_) => _triggerTrimSpanEnd(),
        onHorizontalDragUpdate: (details) =>
            _updateDragTrimBar(details, scaledWidth),
        child: MouseRegion(
          cursor: SystemMouseCursors.move,
          child: Container(
            width: trimWidth,
            height: _player.style.trimBarHeight,
            decoration: BoxDecoration(
              border: Border.all(
                color: _player.style.trimBarBackground,
                width: _player.style.trimBarBorderWidth,
              ),
              borderRadius: BorderRadius.circular(
                _player.style.trimBarHandlerRadius,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResizeHandler(bool isLeft, double offset, double scaledWidth) {
    return Positioned(
      left: offset,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: (_) => _triggerTrimSpanEnd(),
        onHorizontalDragUpdate: (details) {
          if (isLeft) {
            double newValue = _trimStart + details.primaryDelta! / scaledWidth;
            _updateTrimStart(max(0, newValue));
          } else {
            double newValue = _trimEnd + details.primaryDelta! / scaledWidth;
            _updateTrimEnd(min(1, newValue));
          }
        },
        child: VideoEditorTrimHandle(
          isLeft: isLeft,
          minInteractiveDimension: _minInteractiveDimension,
        ),
      ),
    );
  }
}
