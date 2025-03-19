import 'package:flutter/widgets.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video_editor_configs.dart';
import '/core/models/video/trim_duration_span_model.dart';

class ProVideoController {
  ProVideoController({
    required this.videoPlayer,
    required this.videoDuration,
    required this.initialResolution,
    required this.fileSize,
  });

  final Widget videoPlayer;
  final Duration videoDuration;
  final Size initialResolution;
  final int fileSize;

  /// TODO: generate thumbnails for trimmerbar and filter background
  List<ImageProvider> thumbnails = [];

  late VideoEditorCallbacks Function() _callbacksFunction;
  late VideoEditorConfigs Function() _configsFunction;

  VideoEditorCallbacks get callbacks => _callbacksFunction();
  VideoEditorConfigs get configs => _configsFunction();

  late final isPlayingNotifier = ValueNotifier<bool>(configs.initialPlay);
  late final isMutedNotifier = ValueNotifier<bool>(configs.initialMuted);
  late final trimDurationSpanNotifier = ValueNotifier<TrimDurationSpan>(
    TrimDurationSpan(start: Duration.zero, end: videoDuration),
  );

  initialize({
    required VideoEditorCallbacks Function() callbacksFunction,
    required VideoEditorConfigs Function() configsFunction,
  }) {
    _callbacksFunction = callbacksFunction;
    _configsFunction = configsFunction;
  }

  void togglePlayState() {
    isPlayingNotifier.value = !isPlayingNotifier.value;

    if (isPlayingNotifier.value) {
      callbacks.onPlay?.call();
    } else {
      callbacks.onPause?.call();
    }
  }

  void setMuteState(bool isMuted) {
    isMutedNotifier.value = isMuted;

    callbacks.onMuteToggle?.call(isMuted);
  }

  void setTrimSpan(TrimDurationSpan span) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: span.start,
      end: span.end,
    );
    callbacks.onTrimSpanChanged?.call(trimDurationSpanNotifier.value);
  }

  void setTrimStart(Duration duration) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: duration,
      end: trimDurationSpanNotifier.value.end,
    );
    callbacks.onTrimSpanChanged?.call(trimDurationSpanNotifier.value);
  }

  void setTrimEnd(Duration duration) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: trimDurationSpanNotifier.value.start,
      end: duration,
    );
    callbacks.onTrimSpanChanged?.call(trimDurationSpanNotifier.value);
  }
}
