// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/mixins/converted_callbacks.dart';
import '/core/mixins/converted_configs.dart';
import '/core/mixins/standalone_editor.dart';
import '/core/models/editor_image.dart';
import '/core/models/init_configs/blur_editor_init_configs.dart';
import '/core/models/transform_helper.dart';
import '/core/platform/io/io_helper.dart';
import '/features/blur_editor/widgets/blur_editor_bottombar.dart';
import '/shared/services/content_recorder/widgets/content_recorder.dart';
import '/shared/utils/file_constructor_utils.dart';
import '/shared/widgets/layer/layer_stack.dart';
import '/shared/widgets/transform/transformed_content_generator.dart';
import '../crop_rotate_editor/models/transform_factors.dart';
import '../filter_editor/widgets/filtered_image.dart';
import 'widgets/blur_editor_appbar.dart';

/// The `BlurEditor` widget allows users to apply blur to images.
///
/// You can create a `BlurEditor` using one of the factory methods provided:
/// - `BlurEditor.file`: Loads an image from a file.
/// - `BlurEditor.asset`: Loads an image from an asset.
/// - `BlurEditor.network`: Loads an image from a network URL.
/// - `BlurEditor.memory`: Loads an image from memory as a `Uint8List`.
/// - `BlurEditor.autoSource`: Automatically selects the source based on
/// provided parameters.
class BlurEditor extends StatefulWidget
    with StandaloneEditor<BlurEditorInitConfigs> {
  /// Constructs a `BlurEditor` widget.
  ///
  /// The [key] parameter is used to provide a key for the widget.
  /// The [editorImage] parameter specifies the image to be edited.
  /// The [initConfigs] parameter specifies the initialization configurations
  /// for the editor.
  const BlurEditor._({
    super.key,
    required this.editorImage,
    required this.initConfigs,
  });

  /// Constructs a `BlurEditor` widget with image data loaded from memory.
  factory BlurEditor.memory(
    Uint8List byteArray, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(byteArray: byteArray),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded from a file.
  factory BlurEditor.file(
    File file, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(file: ensureFileInstance(file)),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded from an asset.
  factory BlurEditor.asset(
    String assetPath, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(assetPath: assetPath),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded from a network URL.
  factory BlurEditor.network(
    String networkUrl, {
    Key? key,
    required BlurEditorInitConfigs initConfigs,
  }) {
    return BlurEditor._(
      key: key,
      editorImage: EditorImage(networkUrl: networkUrl),
      initConfigs: initConfigs,
    );
  }

  /// Constructs a `BlurEditor` widget with an image loaded automatically based
  /// on the provided source.
  ///
  /// Either [byteArray], [file], [networkUrl], or [assetPath] must be provided.
  factory BlurEditor.autoSource({
    Key? key,
    Uint8List? byteArray,
    File? file,
    String? assetPath,
    String? networkUrl,
    EditorImage? editorImage,
    required BlurEditorInitConfigs initConfigs,
  }) {
    if (byteArray != null || editorImage?.byteArray != null) {
      return BlurEditor.memory(
        byteArray ?? editorImage!.byteArray!,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (file != null || editorImage?.file != null) {
      return BlurEditor.file(
        ensureFileInstance(file ?? editorImage!.file!),
        key: key,
        initConfigs: initConfigs,
      );
    } else if (networkUrl != null || editorImage?.networkUrl != null) {
      return BlurEditor.network(
        networkUrl ?? editorImage!.networkUrl!,
        key: key,
        initConfigs: initConfigs,
      );
    } else if (assetPath != null || editorImage?.assetPath != null) {
      return BlurEditor.asset(
        assetPath ?? editorImage!.assetPath!,
        key: key,
        initConfigs: initConfigs,
      );
    } else {
      throw ArgumentError(
          "Either 'byteArray', 'file', 'networkUrl' or 'assetPath' must "
          'be provided.');
    }
  }

  @override
  final BlurEditorInitConfigs initConfigs;
  @override
  final EditorImage editorImage;

  @override
  createState() => BlurEditorState();
}

/// The state class for the `BlurEditor` widget.
class BlurEditorState extends State<BlurEditor>
    with
        ImageEditorConvertedConfigs,
        ImageEditorConvertedCallbacks,
        StandaloneEditorState<BlurEditor, BlurEditorInitConfigs> {
  /// Update the image with the applied blur and the slider value.
  late final StreamController<void> _uiBlurStream;

  late final ValueNotifier<double> _blurFactor =
      ValueNotifier(appliedBlurFactor);

  /// Represents the selected blur state.
  double get blurFactor => _blurFactor.value;
  set blurFactor(double value) {
    _blurFactor.value = value;
  }

  @override
  void initState() {
    super.initState();
    _uiBlurStream = StreamController.broadcast();
    _uiBlurStream.stream.listen((_) => rebuildController.add(null));

    blurEditorCallbacks?.onInit?.call();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      blurEditorCallbacks?.onAfterViewInit?.call();
    });
  }

  @override
  void dispose() {
    _uiBlurStream.close();
    screenshotCtrl.destroy();
    super.dispose();
  }

  @override
  void setState(void Function() fn) {
    rebuildController.add(null);
    super.setState(fn);
  }

  /// Handles the "Done" action, either by applying changes or closing the
  /// editor.
  void done() async {
    doneEditing(
      returnValue: blurFactor,
      editorImage: widget.editorImage,
    );
    blurEditorCallbacks?.handleDone();
  }

  /// Set the blur factor and update the UI.
  void setBlurFactor(double value) {
    blurFactor = value;
    _uiBlurStream.add(null);
    blurEditorCallbacks?.handleBlurFactorChange(value);
  }

  /// Handles changes in the blur factor value.
  void _onChanged(double value) {
    setBlurFactor(value);
  }

  /// Handles the end of changes in the blur factor value.
  void _onChangedEnd(double value) {
    blurEditorCallbacks?.handleBlurFactorChangeEnd(value);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      takeScreenshot();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: theme.copyWith(
          tooltipTheme: theme.tooltipTheme.copyWith(preferBelow: true)),
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: blurEditorConfigs.style.uiOverlayStyle,
        child: SafeArea(
          top: blurEditorConfigs.safeArea.top,
          bottom: blurEditorConfigs.safeArea.bottom,
          left: blurEditorConfigs.safeArea.left,
          right: blurEditorConfigs.safeArea.right,
          child: RecordInvisibleWidget(
            controller: screenshotCtrl,
            child: Scaffold(
              backgroundColor: blurEditorConfigs.style.background,
              appBar: _buildAppBar(),
              body: _buildBody(),
              bottomNavigationBar: _buildBottomNavBar(),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the app bar for the blur editor.
  PreferredSizeWidget? _buildAppBar() {
    if (blurEditorConfigs.widgets.appBar != null) {
      return blurEditorConfigs.widgets.appBar!
          .call(this, rebuildController.stream);
    }

    return BlurEditorAppBar(
      blurEditorConfigs: blurEditorConfigs,
      i18n: i18n.blurEditor,
      close: close,
      done: done,
    );
  }

  /// Builds the main content area of the editor.
  Widget _buildBody() {
    return LayoutBuilder(builder: (context, constraints) {
      editorBodySize = constraints.biggest;
      return Stack(
        alignment: Alignment.center,
        fit: StackFit.expand,
        children: [
          ContentRecorder(
            controller: screenshotCtrl,
            child: Stack(
              alignment: Alignment.center,
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: heroTag,
                  createRectTween: (begin, end) =>
                      RectTween(begin: begin, end: end),
                  child: TransformedContentGenerator(
                    configs: configs,
                    transformConfigs:
                        initialTransformConfigs ?? TransformConfigs.empty(),
                    child: StreamBuilder(
                        stream: _uiBlurStream.stream,
                        builder: (context, snapshot) {
                          return FilteredImage(
                            width: getMinimumSize(mainImageSize, editorBodySize)
                                .width,
                            height:
                                getMinimumSize(mainImageSize, editorBodySize)
                                    .height,
                            configs: configs,
                            image: editorImage,
                            filters: appliedFilters,
                            tuneAdjustments: appliedTuneAdjustments,
                            blurFactor: blurFactor,
                          );
                        }),
                  ),
                ),
                if (blurEditorConfigs.showLayers && layers != null)
                  LayerStack(
                    transformHelper: TransformHelper(
                      mainBodySize:
                          getMinimumSize(mainBodySize, editorBodySize),
                      mainImageSize:
                          getMinimumSize(mainImageSize, editorBodySize),
                      transformConfigs: initialTransformConfigs,
                      editorBodySize: editorBodySize,
                    ),
                    overlayColor: blurEditorConfigs.style.background,
                    configs: configs,
                    layers: layers!,
                    clipBehavior: Clip.none,
                  ),
                if (blurEditorConfigs.widgets.bodyItemsRecorded != null)
                  ...blurEditorConfigs.widgets.bodyItemsRecorded!(
                      this, rebuildController.stream),
              ],
            ),
          ),
          if (blurEditorConfigs.widgets.bodyItems != null)
            ...blurEditorConfigs.widgets.bodyItems!(
                this, rebuildController.stream),
        ],
      );
    });
  }

  /// Builds the bottom navigation bar with blur slider.
  Widget? _buildBottomNavBar() {
    if (blurEditorConfigs.widgets.bottomBar != null) {
      return blurEditorConfigs.widgets.bottomBar!
          .call(this, rebuildController.stream);
    }

    return BlurEditorBottombar(
      blurEditorConfigs: blurEditorConfigs,
      blurFactor: _blurFactor,
      rebuildController: rebuildController,
      blurEditorState: this,
      onChanged: _onChanged,
      onChangedEnd: _onChangedEnd,
    );
  }
}
