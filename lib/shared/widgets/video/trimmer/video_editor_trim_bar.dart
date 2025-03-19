import 'dart:math';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/models/video/trim_duration_span_model.dart';
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
  double trimStart = 0;
  double trimEnd = 1;
  double _scale = 1.0;
  double _baseScale = 1.0;
  static const double _minScale = 1.0;
  static const double _maxScale = 3.0;
  final _scrollCtrl = ScrollController();

  VideoEditorConfigurable get _player => VideoEditorConfigurable.of(context);

  int get _videoDuration => _player.controller.videoDuration.inMicroseconds;
  double get minTrimPercentage =>
      _player.configs.minTrimDuration.inMicroseconds / _videoDuration;

  void _updateTrimSpan() {
    _player.controller.setTrimSpan(
      TrimDurationSpan(
        start: Duration(microseconds: (trimStart * _videoDuration).toInt()),
        end: Duration(microseconds: (trimEnd * _videoDuration).toInt()),
      ),
    );
    setState(() {});
  }

  void _updateTrimStart(double value) {
    double minEnd = value + minTrimPercentage;
    trimStart = value;
    trimEnd = max(trimEnd, minEnd);

    if (trimEnd > 1) {
      trimStart = 1 - minTrimPercentage;
      trimEnd = 1;
    }

    _updateTrimSpan();
  }

  void _updateTrimEnd(double value) {
    double minStart = value - minTrimPercentage;
    trimEnd = value;
    trimStart = min(trimStart, minStart);

    if (trimStart < 0) {
      trimStart = 0;
      trimEnd = minTrimPercentage;
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
    double newValueStart = trimStart + factor;
    double newValueEnd = trimEnd + factor;

    if (newValueStart >= 0 && newValueEnd <= 1) {
      _updateTrimStart(newValueStart);
      _updateTrimEnd(newValueEnd);
    } else if (newValueEnd > 1 && trimEnd != 1) {
      double diff = 1 - trimEnd;
      _updateTrimStart(trimStart + diff);
      _updateTrimEnd(trimEnd + diff);
    } else if (newValueStart < 0 && trimStart != 0) {
      _updateTrimStart(0);
      _updateTrimEnd(trimEnd - trimStart);
    } else {
      _updateScrollbar(details.delta.dx);
    }
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
        double editorWidth =
            constraints.maxWidth - _player.contentPadding.horizontal;
        double scaledWidth = editorWidth * _scale;
        double trimWidth = (trimEnd - trimStart) * scaledWidth;
        double offsetLeftHandler = trimStart * scaledWidth;
        double offsetRightHandler = trimEnd * scaledWidth -
            max(_minInteractiveDimension, _player.style.trimBarHandlerWidth);

        return Listener(
          onPointerSignal: (event) {
            /// TODO: improve that it directly also scroll to the pointer position
            if (event is PointerScrollEvent) {
              double scaleChange = -event.scrollDelta.dy * 0.01;
              setState(() {
                _scale = (_scale + scaleChange).clamp(_minScale, _maxScale);
              });
            }
          },
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

                    /// Trim body area
                    _buildTrimBodyArea(
                      offsetLeftHandler,
                      offsetRightHandler,
                      scaledWidth,
                      trimWidth,
                    ),

                    /// Trim handler left
                    _buildLeftResizeHandler(offsetLeftHandler, scaledWidth),

                    /// Trim handler right
                    _buildRightResizeHandler(offsetRightHandler, scaledWidth),
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

  Widget _buildLeftResizeHandler(double offset, double scaledWidth) {
    return Positioned(
      left: offset,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          double newValue = trimStart + details.primaryDelta! / scaledWidth;
          _updateTrimStart(max(0, newValue));
        },
        child: VideoEditorTrimHandle(
          isLeft: true,
          minInteractiveDimension: _minInteractiveDimension,
        ),
      ),
    );
  }

  Widget _buildRightResizeHandler(double offset, double scaledWidth) {
    return Positioned(
      left: offset,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          double newValue = trimEnd + details.primaryDelta! / scaledWidth;
          _updateTrimEnd(min(1, newValue));
        },
        child: VideoEditorTrimHandle(
          isLeft: false,
          minInteractiveDimension: _minInteractiveDimension,
        ),
      ),
    );
  }
}
