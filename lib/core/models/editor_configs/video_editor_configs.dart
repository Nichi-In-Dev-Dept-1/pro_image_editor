import 'package:flutter/widgets.dart';

import '/core/models/custom_widgets/video_editor_widgets.dart';
import '/core/models/icons/video_editor_icons.dart';
import '/core/models/styles/video_editor_style.dart';

export '/core/models/custom_widgets/video_editor_widgets.dart';
export '/core/models/icons/video_editor_icons.dart';
export '/core/models/styles/video_editor_style.dart';

class VideoEditorConfigs {
  const VideoEditorConfigs({
    this.icons = const VideoEditorIcons(),
    this.style = const VideoEditorStyle(),
    this.widgets = const VideoEditorWidgets(),
    this.initialPlay = false,
    this.initialMuted = false,
    this.trimBarInvertMouseScroll = false,
    this.controlsPosition = VideoEditorControlPosition.top,
    this.minTrimDuration = const Duration(seconds: 7),
    this.animatedIndicatorDuration = const Duration(milliseconds: 200),
    this.animatedIndicatorSwitchInCurve = Curves.ease,
    this.animatedIndicatorSwitchOutCurve = Curves.ease,
    this.trimBarMinScale = 1,
    this.trimBarMaxScale = 3,
  });

  final VideoEditorIcons icons;
  final VideoEditorStyle style;
  final VideoEditorWidgets widgets;

  final bool initialPlay;
  final bool initialMuted;
  final bool trimBarInvertMouseScroll;
  final double trimBarMinScale;
  final double trimBarMaxScale;

  final Duration minTrimDuration;

  final VideoEditorControlPosition controlsPosition;

  final Duration animatedIndicatorDuration;
  final Curve animatedIndicatorSwitchInCurve;
  final Curve animatedIndicatorSwitchOutCurve;

  VideoEditorConfigs copyWith({
    Widget? videoPlayer,
    VideoEditorIcons? icons,
    VideoEditorStyle? style,
    VideoEditorWidgets? widgets,
    Duration? minTrimDuration,
    VideoEditorControlPosition? controlsPosition,
    bool? initialPlay,
    bool? initialMuted,
    Duration? animatedIndicatorDuration,
    Curve? animatedIndicatorSwitchInCurve,
    Curve? animatedIndicatorSwitchOutCurve,
  }) {
    return VideoEditorConfigs(
      icons: icons ?? this.icons,
      style: style ?? this.style,
      widgets: widgets ?? this.widgets,
      minTrimDuration: minTrimDuration ?? this.minTrimDuration,
      controlsPosition: controlsPosition ?? this.controlsPosition,
      initialPlay: initialPlay ?? this.initialPlay,
      initialMuted: initialMuted ?? this.initialMuted,
      animatedIndicatorDuration:
          animatedIndicatorDuration ?? this.animatedIndicatorDuration,
      animatedIndicatorSwitchInCurve:
          animatedIndicatorSwitchInCurve ?? this.animatedIndicatorSwitchInCurve,
      animatedIndicatorSwitchOutCurve: animatedIndicatorSwitchOutCurve ??
          this.animatedIndicatorSwitchOutCurve,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is VideoEditorConfigs &&
        other.icons == icons &&
        other.style == style &&
        other.widgets == widgets &&
        other.initialPlay == initialPlay &&
        other.initialMuted == initialMuted &&
        other.animatedIndicatorDuration == animatedIndicatorDuration &&
        other.animatedIndicatorSwitchInCurve ==
            animatedIndicatorSwitchInCurve &&
        other.animatedIndicatorSwitchOutCurve ==
            animatedIndicatorSwitchOutCurve;
  }

  @override
  int get hashCode {
    return icons.hashCode ^
        style.hashCode ^
        widgets.hashCode ^
        initialPlay.hashCode ^
        initialMuted.hashCode ^
        animatedIndicatorDuration.hashCode ^
        animatedIndicatorSwitchInCurve.hashCode ^
        animatedIndicatorSwitchOutCurve.hashCode;
  }
}

enum VideoEditorControlPosition { top, bottom }
