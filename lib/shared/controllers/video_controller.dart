import 'package:flutter/widgets.dart';

import '/core/models/editor_callbacks/video_editor_callbacks.dart';
import '/core/models/editor_configs/video_editor_configs.dart';
import '/core/models/video/trim_duration_span_model.dart';

/// Controls video playback and trimming for the video editor.
class ProVideoController {
  /// Creates a [ProVideoController] instance.
  ///
  /// Requires a [videoPlayer] widget, [videoDuration], [initialResolution],
  /// and the video file size in bytes.
  ProVideoController({
    required this.videoPlayer,
    required this.videoDuration,
    required this.initialResolution,
    required this.fileSize,
    required this.thumbnails,
  });

  /// The video player widget.
  final Widget videoPlayer;

  /// The total duration of the video.
  final Duration videoDuration;

  /// The initial resolution of the video.
  final Size initialResolution;

  /// The size of the video file in bytes.
  final int fileSize;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  final List<ImageProvider> thumbnails;

  late VideoEditorCallbacks Function() _callbacksFunction;
  late VideoEditorConfigs Function() _configsFunction;

  /// Returns the configured video editor callbacks.
  VideoEditorCallbacks get callbacks => _callbacksFunction();

  /// Returns the video editor configuration settings.
  VideoEditorConfigs get configs => _configsFunction();

  /// Notifies listeners of the current playback position.
  late final playTimeNotifier = ValueNotifier<Duration>(Duration.zero);

  /// Notifies listeners of the current play state.
  late final isPlayingNotifier = ValueNotifier<bool>(configs.initialPlay);

  /// Notifies listeners of the current mute state.
  late final isMutedNotifier = ValueNotifier<bool>(configs.initialMuted);

  /// Notifies listeners of the selected trim duration span.
  late final trimDurationSpanNotifier = ValueNotifier<TrimDurationSpan>(
    TrimDurationSpan(start: Duration.zero, end: videoDuration),
  );

  /// The start time of the trimmed video segment.
  ///
  /// Retrieved from the [trimDurationSpanNotifier].
  Duration get startTime => trimDurationSpanNotifier.value.start;

  /// The end time of the trimmed video segment.
  ///
  /// Retrieved from the [trimDurationSpanNotifier].
  Duration get endTime => trimDurationSpanNotifier.value.end;

  /// Initializes the controller with provided callback and config functions.
  void initialize({
    required VideoEditorCallbacks Function() callbacksFunction,
    required VideoEditorConfigs Function() configsFunction,
  }) {
    _callbacksFunction = callbacksFunction;
    _configsFunction = configsFunction;
  }

  /// Toggles the play state of the video.
  void togglePlayState() {
    if (!isPlayingNotifier.value) {
      play();
    } else {
      pause();
    }
  }

  /// Starts video playback and triggers the play callback.
  void play() {
    isPlayingNotifier.value = true;
    callbacks.onPlay?.call();
  }

  /// Pauses video playback and triggers the pause callback.
  void pause() {
    isPlayingNotifier.value = false;
    callbacks.onPause?.call();
  }

  /// Sets the mute state and triggers the mute toggle callback.
  void setMuteState(bool isMuted) {
    isMutedNotifier.value = isMuted;
    callbacks.onMuteToggle?.call(isMuted);
  }

  /// Updates the trim span and triggers the trim update callback.
  void setTrimSpan(TrimDurationSpan span) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: span.start,
      end: span.end,
    );
    callbacks.onTrimSpanUpdate?.call(trimDurationSpanNotifier.value);
  }

  /// Sets the start time for trimming and triggers the trim update callback.
  void setTrimStart(Duration duration) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: duration,
      end: trimDurationSpanNotifier.value.end,
    );
    callbacks.onTrimSpanUpdate?.call(trimDurationSpanNotifier.value);
  }

  /// Sets the end time for trimming and triggers the trim update callback.
  void setTrimEnd(Duration duration) {
    trimDurationSpanNotifier.value = TrimDurationSpan(
      start: trimDurationSpanNotifier.value.start,
      end: duration,
    );
    callbacks.onTrimSpanUpdate?.call(trimDurationSpanNotifier.value);
  }

  /// Updates the current play position.
  void setPlayTime(Duration duration) {
    playTimeNotifier.value = duration;
  }
}
