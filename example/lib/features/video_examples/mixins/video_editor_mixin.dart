/* import 'dart:typed_data';

import 'package:example/core/constants/example_constants.dart';
import 'package:example/features/preview/preview_video.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/core/models/complete_parameters.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_video_editor/pro_video_editor.dart';

/// A mixin for handling video editing states.
mixin VideoEditorMixin<T extends StatefulWidget> on State<T> {
  /// The target format for the exported video.
  final outputFormat = VideoOutputFormat.mp4;

  /// Video editor configuration settings.
  late final VideoEditorConfigs videoConfigs = VideoEditorConfigs(
    initialMuted: true,
    initialPlay: false,
    isAudioSupported: outputFormat != VideoOutputFormat.gif,
    minTrimDuration: const Duration(seconds: 7),
  );

  /// Indicates whether a seek operation is in progress.
  bool isSeeking = false;

  /// Stores the currently selected trim duration span.
  TrimDurationSpan? durationSpan;

  /// Temporarily stores a pending trim duration span.
  TrimDurationSpan? tempDurationSpan;

  /// Controls video playback and trimming functionalities.
  ProVideoController? proVideoController;

  /// Stores generated thumbnails for the trimmer bar and filter background.
  final List<ImageProvider> thumbnails = [];

  /// Holds information about the selected video.
  ///
  /// This will be populated via [setVideoInformations].
  late VideoInformation videoInformation;

  /// Number of thumbnails to generate across the video timeline.
  final int thumbnailCount = 7;

  /// The video currently loaded in the editor.
  EditorVideo video = EditorVideo(assetPath: kVideoEditorExampleAssetPath);

  /// The result of the video export process, if completed.
  Uint8List? exportedVideo;

  /// The duration it took to generate the exported video.
  Duration videoGenerationTime = Duration.zero;

  /// Loads and sets [videoInformation] for the given [video].
  ///
  /// Uses the [VideoUtilsService] to extract metadata such as duration,
  /// resolution, and format.
  Future<void> setVideoInformations() async {
    videoInformation =
        await VideoUtilsService.instance.getVideoInformation(video);
  }

  /// Generates thumbnails for the given [video] using calculated timestamps.
  ///
  /// The function computes evenly spaced timestamps based on the video's
  /// duration and the fixed [thumbnailCount]. It also calculates the desired
  /// image width in physical pixels, accounting for the device pixel ratio
  /// and video aspect ratio.
  ///
  /// The resulting thumbnails are added to a local list as [MemoryImage]s.
  Future<void> generateThumbnails() async {
    int videoDuration = videoInformation.duration.inMilliseconds;
    int firstPosition = 1000;

    double step = (videoDuration - firstPosition) / (thumbnailCount - 1);

    var timestamps = List.generate(thumbnailCount, (i) {
      return Duration(milliseconds: (step * i).toInt());
    });

    var imageWidth = MediaQuery.sizeOf(context).width /
        thumbnailCount *
        MediaQuery.devicePixelRatioOf(context) *
        videoInformation.resolution.aspectRatio;

    var thumbnailList = await VideoUtilsService.instance
        .createVideoThumbnails(CreateVideoThumbnail(
      video: video,
      timestamps: timestamps,
      imageWidth: imageWidth,
    ));

    thumbnails.addAll(thumbnailList.map(MemoryImage.new));

    /// Optional precache every thumbnail
    var cacheList = thumbnails.map((item) => precacheImage(item, context));
    await Future.wait(cacheList);
  }

  /// Generates the final video based on the given [parameters].
  ///
  /// Applies blur, color filters, cropping, rotation, flipping, and trimming
  /// before exporting using FFmpeg. Measures and stores the generation time.
  Future<void> generateVideo(CompleteParameters parameters) async {
    final stopwatch = Stopwatch()..start();

    var devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    var videoBytes = await video.safeByteArray();

    var exportModel = ExportVideoModel(
      videoBytes: videoBytes,
      imageBytes: parameters.image,
      blur: parameters.blur,
      colorFilters: parameters.colorFilters,
      startTime: parameters.startTime,
      endTime: parameters.endTime,
      videoDuration: videoInformation.duration,
      transform: ExportTransform(
        width: parameters.cropWidth,
        height: parameters.cropHeight,
        rotateTurns: parameters.rotateTurns,
        x: parameters.cropX?.toString(),
        y: parameters.cropY?.toString(),
        flipX: parameters.flipX,
        flipY: parameters.flipY,
      ),

      ///
      devicePixelRatio: devicePixelRatio,
      enableAudio: proVideoController?.isAudioEnabled ?? true,

      /// Generation configurations
      outputFormat: outputFormat,
      outputQuality: OutputQuality.mediumHigh,
      encodingPreset: EncodingPreset.ultrafast,

      /// Other
      /// customFilter: '',
      /// encoding: const VideoEncoding(
      ///   aviEncodingConfig: AviEncodingConfig(),
      ///   gifEncodingConfig: GifEncodingConfig(),
      ///   mkvEncodingConfig: MkvEncodingConfig(),
      ///   movEncodingConfig: MovEncodingConfig(),
      ///   mp4EncodingConfig: Mp4EncodingConfig(),
      ///   webMEncodingConfig: WebMEncodingConfig(),
      /// ),
    );
    exportedVideo = await VideoUtilsService.instance.exportVideo(exportModel);
    videoGenerationTime = stopwatch.elapsed;
  }

  /// Closes the video editor and opens a preview screen if a video was
  /// exported.
  ///
  /// If [exportedVideo] is available, it navigates to [PreviewVideo].
  /// Afterwards, it pops the current editor page.
  void onCloseEditor(EditorMode editorMode) async {
    if (editorMode != EditorMode.main) return Navigator.pop(context);
    if (exportedVideo != null) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewVideo(
            bytes: exportedVideo!,
            generationTime: videoGenerationTime,
          ),
        ),
      );
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }
}
 */
