<img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/logo.jpg?raw=true" alt="Logo" />

<p>
    <a href="https://pub.dartlang.org/packages/pro_image_editor">
        <img src="https://img.shields.io/pub/v/pro_image_editor.svg" alt="pub package">
    </a>
    <a href="https://github.com/sponsors/hm21">
        <img src="https://img.shields.io/static/v1?label=Sponsor&message=%E2%9D%A4&logo=GitHub&color=%23f5372a" alt="Sponsor">
    </a>
    <a href="https://img.shields.io/github/license/hm21/pro_image_editor">
        <img src="https://img.shields.io/github/license/hm21/pro_image_editor" alt="License">
    </a>
    <a href="https://github.com/hm21/pro_image_editor/issues">
        <img src="https://img.shields.io/github/issues/hm21/pro_image_editor" alt="GitHub issues">
    </a>
    <a href="https://hm21.github.io/pro_image_editor">
        <img src="https://img.shields.io/badge/web-demo---?&color=0f7dff" alt="Web Demo">
    </a>
</p>

The ProImageEditor is a Flutter widget designed for image editing within your application. It provides a flexible and convenient way to integrate image editing capabilities into your Flutter project. 

<a href="https://hm21.github.io/pro_image_editor">Demo Website</a>

## Table of contents

- **[📷 Preview](#preview)**
- **[✨ Features](#features)**
- **[🔧 Getting started](#getting-started)**
  - [Android](#android)
  - [OpenHarmony](#openharmony)
  - [Web](#web)
- **[❓ Usage](#usage)**
  - [Open the editor in a new page](#open-the-editor-in-a-new-page)
  - [Show the editor inside of a widget](#show-the-editor-inside-of-a-widget)
  - [Own stickers or widgets](#own-stickers-or-widgets)
  - [Grounded-Design](#grounded-design)
  - [Frosted-Glass-Design](#frosted-glass-design)
  - [WhatsApp-Design](#whatsapp-design)
  - [Highly configurable](#highly-configurable)
  - [Custom Widgets](#custom-widgets)
  - [Upload to Firebase or Supabase](#upload-to-firebase-or-supabase)
  - [Import-Export state history](#import-export-state-history)
- **[📚 Documentation](#documentation)**
- **[🤝 Contributing](#contributing)**
- **[📜 License](LICENSE)**
- **[📜 Notices](NOTICES)**



## Preview
<table>
  <thead>
    <tr>
      <th align="center">Grounded-Design</th>
      <th align="center">Frosted-Glass-Design</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/grounded-design.gif?raw=true" alt="Grounded-Design" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/frosted-glass-design.gif?raw=true" alt="Frosted-Glass-Design" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">WhatsApp-Design</th>
      <th align="center">Paint-Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/whatsapp-design.gif?raw=true" alt="WhatsApp-Design" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/paint-editor.gif?raw=true" alt="Paint-Editor" />
      </td>
    </tr>
  </tbody>
</table>
<table>
  <thead>
    <tr>
      <th align="center">Text-Editor</th>
      <th align="center">Crop-Rotate-Editor</th>
    </tr>
  </thead>
  <tbody>
   <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/text-editor.gif?raw=true" alt="Text-Editor" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/crop-rotate-editor.gif?raw=true" alt="Crop-Rotate-Editor" />
      </td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th align="center">Filter-Editor</th>
      <th align="center">Emoji-Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/filter-editor.gif?raw=true" alt="Filter-Editor" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/emoji-editor.gif?raw=true" alt="Emoji-Editor" />
      </td>
    </tr>
  </tbody>
</table>

<table>
  <thead>
    <tr>
      <th align="center">Sticker/ Widget Editor</th>
      <th align="center">Blur-Editor</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/sticker-editor.gif?raw=true" alt="Sticker-Widget-Editor" />
      </td>
      <td align="center" width="50%">
        <img src="https://github.com/hm21/pro_image_editor/blob/stable/assets/preview/blur-editor.gif?raw=true" alt="Blur-Editor" />
      </td>
    </tr>
  </tbody>
</table>



## Features

- ✅ Multiple-Editors
  - ✅ Paint-Editor
    - ✅ Color picker
    - ✅ Multiple forms like arrow, rectangle, circle and freestyle
    - ✅ Censor areas with blur or pixelation
  - ✅ Text-Editor
    - ✅ Color picker
    - ✅ Align-Text => left, right and center
    - ✅ Change Text Scale
    - ✅ Multiple background modes like in whatsapp
  - ✅ Crop-Rotate-Editor
    - ✅ Rotate
    - ✅ Flip
    - ✅ Multiple aspect ratios
    - ✅ Reset
    - ✅ Double-Tap
    - ✅ Round cropper
  - ✅ Tune-Adjustments-Editor
  - ✅ Filter-Editor
  - ✅ Blur-Editor
  - ✅ Emoji-Picker
  - ✅ Sticker-Editor
- ✅ Multi-Threading
  - ✅ Use isolates for background tasks on Dart native devices
  - ✅ Use web-workers for background tasks on Dart web devices
  - ✅ Automatically or manually set the number of active background processors based on the device
- ✅ Undo and redo function
- ✅ Use your image directly from memory, asset, file or network
- ✅ Each icon, style or widget can be changed
- ✅ Any text can be translated "i18n"
- ✅ Many custom configurations for each subeditor
- ✅ Selectable design mode between Material and Cupertino
- ✅ Reorder layer level
- ✅ Movable background image
- ✅ Multiple prebuilt themes
  - ✅ Grounded-Theme
  - ✅ WhatsApp Theme
  - ✅ Frosted-Glass Theme
- ✅ Interactive layers
- ✅ Helper lines for better positioning
- ✅ Hit detection for painted layers
- ✅ Zoomable paint and main editor
- ✅ Improved layer movement and scaling functionality for desktop devices


#### Planned features
- ✨ Paint-Editor 
  - Freestyle-Painter with improved performance and hitbox
- ✨ Text-Editor
  - Text-layer with an improved hit-box and ensure it's vertically centered on all devices
- ✨ AI Futures => Perhaps integrating Adobe Firefly


## Getting started

### Android

To enable smooth hit vibrations from a helper line, you need to add the `VIBRATE` permission to your `AndroidManifest.xml` file.

``` xml
<uses-permission android:name="android.permission.VIBRATE"/>
```

### OpenHarmony 

To enable smooth hit vibrations from a helper line, you need to add the `VIBRATE` permission to your project's module.json5 file.

```json
"requestPermissions": [
    {"name" :  "ohos.permission.VIBRATE"},                
]
```


### Web

If you're displaying emoji on the web and want them to be colored by default (especially if you're not using a custom font like Noto Emoji), you can achieve this by adding the `useColorEmoji: true` parameter to your `flutter_bootstrap.js` file, as shown in the code snippet below:

<details>
  <summary>Show code example</summary>

```js
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
    },
    onEntrypointLoaded: function (engineInitializer) {
      engineInitializer.initializeEngine({
        useColorEmoji: true, // add this parameter
        renderer: 'canvaskit'
      }).then(function (appRunner) {
        appRunner.runApp();
      });
    }
});
```
</details>

<br/>

The HTML renderer is not supported in the image editor and has been completely removed in Flutter version >= `3.29.0`. However, if you are using an older Flutter version < `3.29`, please ensure that you enforce the canvas renderer.

To enable the Canvaskit renderer by default, you can do the following in your `flutter_bootstrap.js` file.

<details>
  <summary>Show code example</summary>

```js
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
    serviceWorkerSettings: {
        serviceWorkerVersion: {{flutter_service_worker_version}},
    },
    onEntrypointLoaded: function (engineInitializer) {
      engineInitializer.initializeEngine({
        useColorEmoji: true,
        renderer: 'canvaskit' // add this parameter
      }).then(function (appRunner) {
        appRunner.runApp();
      });
    }
});
```
</details>

<br/>

By making this change, you can enhance filter compatibility and ensure a smoother experience on older Android phones and various mobile web devices.
<br/>
You can view the full web example [here](https://github.com/hm21/pro_image_editor/tree/stable/example/web).


### iOS, macOS, Linux, Windows

No further action is required.


<br/>


## Usage

Import first the image editor like below:
```dart
import 'package:pro_image_editor/pro_image_editor.dart';
```

#### Open the editor in a new page

```dart
void _openEditor() {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ProImageEditor.network(
        'https://picsum.photos/id/237/2000',
        callbacks: ProImageEditorCallbacks(
          onImageEditingComplete: (Uint8List bytes) async {
            /*
              Your code to handle the edited image. Upload it to your server as an example.
              You can choose to use await, so that the loading-dialog remains visible until your code is ready, or no async, so that the loading-dialog closes immediately.
              By default, the bytes are in `jpg` format.
            */
            Navigator.pop(context);
          },
        ),
      ),
    ),
  );
}
```

#### Show the editor inside of a widget 

```dart
@override
Widget build(BuildContext context) {
    return Scaffold(
        body: ProImageEditor.network(
          'https://picsum.photos/id/237/2000',
           callbacks: ProImageEditorCallbacks(
             onImageEditingComplete: (Uint8List bytes) async {
               /*
                 Your code to handle the edited image. Upload it to your server as an example.
                 You can choose to use await, so that the loading-dialog remains visible until your code is ready, or no async, so that the loading-dialog closes immediately.
                 By default, the bytes are in `jpg` format.
                */
               Navigator.pop(context);
             },
          ),
        ),
    );
}
```

#### Own stickers or widgets

To display stickers or widgets in the ProImageEditor, you have the flexibility to customize and load your own content. The `buildStickers` method allows you to define your own logic for loading stickers, whether from a backend, assets, or local storage, and then push them into the editor. The example [here](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/stickers_example.dart) demonstrates how to load images that can serve as stickers and then add them to the editor.



#### Grounded design

To use the "Grounded-Design" you can follow the example [here](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/design_examples/grounded_example.dart)


#### Frosted-Glass design

To use the "Frosted-Glass-Design" you can follow the example [here](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/design_examples/frosted_glass_example.dart)



#### WhatsApp design

The image editor offers a WhatsApp-themed option that mirrors the popular messaging app's design.
The editor also follows the small changes that exist in the Material (Android) and Cupertino (iOS) version.

You can see the complete example [here](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/design_examples/whatsapp_example.dart)



#### Highly configurable

Customize the image editor to suit your preferences. Of course, each class like `I18nTextEditor` includes more configuration options.

<details>
  <summary>Show code example</summary>

```dart
return Scaffold(
  appBar: AppBar(title: const Text('Pro-Image-Editor')),
  body: ProImageEditor.network(
    'https://picsum.photos/id/237/2000',
    key: _editor,
    callbacks: ProImageEditorCallbacks(
      onImageEditingComplete: (Uint8List bytes) async {
        /*
              Your code to handle the edited image. Upload it to your server as an example.
              You can choose to use await, so that the loading-dialog remains visible until your code is ready, or no async, so that the loading-dialog closes immediately.
              By default, the bytes are in `jpg` format.
            */
        Navigator.pop(context);
      },
    ),
    configs: ProImageEditorConfigs(
      i18n: const I18n(
        various: I18nVarious(),
        paintEditor: I18nPaintEditor(),
        textEditor: I18nTextEditor(),
        cropRotateEditor: I18nCropRotateEditor(),
        filterEditor: I18nFilterEditor(filters: I18nFilters()),
        emojiEditor: I18nEmojiEditor(),
        stickerEditor: I18nStickerEditor(),
        // More translations...
      ),
      helperLines: const HelperLineConfigs(
        showVerticalLine: true,
        showHorizontalLine: true,
        showRotateLine: true,
        hitVibration: true,
      ),
      mainEditor: const MainEditorConfigs(
        widgets: MainEditorWidgets(),
        icons: MainEditorIcons(),
        style: MainEditorStyle(),
        enableCloseButton: true,
        // more...
      ),
      paintEditor: const PaintEditorConfigs(
        widgets: PaintEditorWidgets(),
        icons: PaintEditorIcons(),
        style: PaintEditorStyle(),
        canChangeOpacity: true,
        // more...
      ),
      textEditor: const TextEditorConfigs(
          widgets: TextEditorWidgets(),
          icons: TextEditorIcons(),
          style: TextEditorStyle(),
          autocorrect: true
          // more...
          ),
      cropRotateEditor: const CropRotateEditorConfigs(
        widgets: CropRotateEditorWidgets(),
        icons: CropRotateEditorIcons(),
        style: CropRotateEditorStyle(),
        canFlip: true,
        // more...
      ),
      filterEditor: const FilterEditorConfigs(
        widgets: FilterEditorWidgets(),
        icons: FilterEditorIcons(),
        style: FilterEditorStyle(),
        showLayers: true,
        // more...
      ),
      blurEditor: const BlurEditorConfigs(
        widgets: BlurEditorWidgets(),
        icons: BlurEditorIcons(),
        style: BlurEditorStyle(),
        showLayers: true,
        // more...
      ),
      tuneEditor: const TuneEditorConfigs(
        widgets: TuneEditorWidgets(),
        icons: TuneEditorIcons(),
        style: TuneEditorStyle(),
        showLayers: true,
        // more...
      ),
      emojiEditor: const EmojiEditorConfigs(
        icons: EmojiEditorIcons(),
        style: EmojiEditorStyle(),
        // more...
      ),
      imageGeneration: const ImageGenerationConfigs(
        processorConfigs: ProcessorConfigs(),
        // more
      ),
      designMode: ImageEditorDesignMode.material,
      heroTag: 'hero',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue.shade800,
          brightness: Brightness.dark,
        ),
      ),
    ),
  ),
);
```
</details>

#### Custom Widgets

Customize the editor with your own widgets. For a complete example, refer to the [custom widgets example](https://github.com/hm21/pro_image_editor/blob/stable/example/lib/features/custom_widgets_example.dart).


#### Upload to Firebase or Supabase

<details>
  <summary> <b>Firebase example</b> </summary>

```dart
ProImageEditor.asset(
  'assets/demo.png',
  callbacks: ProImageEditorCallbacks(
    onImageEditingComplete: (bytes) async {
      try {
        String path = 'your-storage-path/my-image-name.jpg';
        Reference ref = FirebaseStorage.instance.ref(path);

        /// In some special cases detect firebase the contentType wrong,
        /// so we make sure the contentType is set to jpg.
        await ref.putData(bytes, SettableMetadata(contentType: 'image/jpg'));
      } on FirebaseException catch (e) {
        debugPrint(e.message);
      }
      if (mounted) Navigator.pop(context);
    },
  ),
);
```
</details>

<br/>

<details>
  <summary> <b>Supabase example</b> </summary>

```dart
final _supabase = Supabase.instance.client;

ProImageEditor.asset(
  'assets/demo.png',
  callbacks: ProImageEditorCallbacks(
    onImageEditingComplete: (bytes) async {
      try {
        String path = 'your-storage-path/my-image-name.jpg';
        await _supabase.storage.from('my_bucket').uploadBinary(
              path,
              bytes,
              retryAttempts: 3,
            );
      } catch (e) {
        debugPrint(e.toString());
      }
      if (mounted) Navigator.pop(context);
    },
  ),
);
```
</details>


#### Import-Export state history

The state history from the image editor can be exported and imported. However, it's important to note that the crop and rotate feature currently only allows exporting the final cropped image and not individual states. Additionally, all sticker widgets are converted into images and saved in that format during the export process.




<details>
  <summary> <b>Export example</b> </summary>

```dart
 await _editor.currentState?.exportStateHistory(
    // All configurations are optional
    configs: const ExportEditorConfigs(
        historySpan: ExportHistorySpan.all,
        exportPaint: true,
        exportText: true,
        exportCropRotate: true,
        exportFilter: true,
        exportTuneAdjustments: true,
        exportEmoji: true,
        exportBlur: true,
        exportWidgets: true,
        enableMinify: true,
    ),
  ).toJson(); // or => toMap(), toFile()
```
</details>

<br/>

<details>
  <summary><b>Import example</b></summary>

```dart
 _editor.currentState?.importStateHistory(
    // or => fromMap(), fromJsonFile()
    ImportStateHistory.fromJson( 
      /* Json-String from your exported state history */,
      configs: const ImportEditorConfigs(
        mergeMode: ImportEditorMergeMode.replace,
        recalculateSizeAndPosition: true,
      ),
    ),
  );
```
</details>

<br/>

<details>
  <summary><b>Initial import example</b></summary>
  
If you wish to open the editor directly with your exported state history, you can do so by utilizing the import feature. Simply load the exported state history into the editor, and it will recreate the previous editing session, allowing you to continue where you left off.

```dart
ProImageEditor.memory(
  bytes,
  key: _editor,
  callbacks: ProImageEditorCallbacks(
    onImageEditingComplete: (Uint8List bytes) async {
      /*
        Your code to handle the edited image. Upload it to your server as an example.
        You can choose to use await, so that the loading-dialog remains visible until your code is ready, or no async, so that the loading-dialog closes immediately.
        By default, the bytes are in `jpg` format.
      */
      Navigator.pop(context);
    },
  ),
  configs: ProImageEditorConfigs(
    stateHistory: StateHistoryConfigs(
      initStateHistory: ImportStateHistory.fromJson( 
        /* Json-String from your exported state history */,
        configs: const ImportEditorConfigs(
          mergeMode: ImportEditorMergeMode.replace,
          recalculateSizeAndPosition: true,
        ),
      ),
    ),
  ),
);
```
</details>

## Documentation

### Interactive layers

Each layer, whether it's an emoji, text, or painting, is interactive, allowing you to manipulate them in various ways. You can move and scale layers using intuitive gestures. Holding a layer with one finger enables you to move it across the canvas. Holding a layer with one finger and using another to pinch or spread allows you to scale and rotate the layer.

On desktop devices, you can click and hold a layer with the mouse to move it. Additionally, using the mouse wheel lets you scale the layer. To rotate a layer, simply press the 'Shift' or 'Ctrl' key while interacting with it.


### Editor Widget
| Property       | Description                                     |
|----------------|-------------------------------------------------|
| `byteArray`    | Image data as a `Uint8List` from memory.        |
| `file`         | File object representing the image file.        |
| `assetPath`    | Path to the image asset.                        |
| `networkUrl`   | URL of the image to be loaded from the network. |
| `configs`      | Configuration options for the image editor.     |
| `callbacks`    | Callbacks for the image editor.                 |


#### Constructors

##### `ProImageEditor.memory`

Creates a `ProImageEditor` widget for editing an image from memory.

##### `ProImageEditor.file`

Creates a `ProImageEditor` widget for editing an image from a file.

##### `ProImageEditor.asset`

Creates a `ProImageEditor` widget for editing an image from an asset.

##### `ProImageEditor.network`

Creates a `ProImageEditor` widget for editing an image from a network URL.

### ProImageEditorConfigs

| Property Name                     | Description                                                                | Default Value                      |
|-----------------------------------|----------------------------------------------------------------------------|------------------------------------|
| `blurEditor`                      | Configuration options for the Blur Editor.                                 | `BlurEditorConfigs()`              |
| `cropRotateEditor`                | Configuration options for the Crop and Rotate Editor.                      | `CropRotateEditorConfigs()`        |
| `designMode`                      | The design mode for the Image Editor.                                      | `ImageEditorDesignMode.material`  |
| `dialogConfigs`                   | Configuration for the loading dialog used in the editor.                   | `DialogConfigs()`                  |
| `emojiEditor`                     | Configuration options for the Emoji Editor.                                | `EmojiEditorConfigs()`             |
| `filterEditor`                    | Configuration options for the Filter Editor.                               | `FilterEditorConfigs()`            |
| `helperLines`                     | Configuration options for helper lines in the Image Editor.                | `HelperLineConfigs()`              |
| `heroTag`                         | A unique hero tag for the Image Editor widget.                             | `'Pro-Image-Editor-Hero'`          |
| `i18n`                            | Internationalization settings for the Image Editor.                        | `I18n()`                           |
| `imageGeneration`                 | Holds the configurations related to image generation.                      | `ImageGenerationConfigs()`         |
| `layerInteraction`                | Configuration options for the layer interaction behavior.                  | `LayerInteractionConfigs()`        |
| `mainEditor`                      | Configuration options for the Main Editor.                                 | `MainEditorConfigs()`              |
| `paintEditor`                     | Configuration options for the Paint Editor.                                | `PaintEditorConfigs()`             |
| `progressIndicatorConfigs`        | Configuration for customizing progress indicators.                         | `ProgressIndicatorConfigs()`       |
| `stateHistory`                    | Holds the configurations related to state history management.              | `StateHistoryConfigs()`            |
| `stickerEditor`                   | Configuration options for the Sticker Editor.                              | `StickerEditorConfigs()`           |
| `textEditor`                      | Configuration options for the Text Editor.                                 | `TextEditorConfigs()`              |
| `theme`                           | The theme to be used for the Image Editor.                                 | `null`                             |
| `tuneEditor`                      | Configuration options for the Tune Editor.                                 | `TuneEditorConfigs()`              |


### ProImageEditorCallbacks

| Property Name                  | Description                                                                                                                        | Default Value |
|--------------------------------|----------------------------------------------------------------------------------------------------------------------------------- |---------------|
| `onImageEditingStarted`        | A callback function that is triggered when the image generation is started.                                                        | `null`        |
| `onImageEditingComplete`       | A callback function that will be called when the editing is done, returning the edited image as `Uint8List` with the format `jpg`. | `null`    |
| `onThumbnailGenerated`         | A callback function that is called when the editing is complete and the thumbnail image is generated, along with capturing the original image as a raw `ui.Image`. If used, it will disable the `onImageEditingComplete` callback.   | `null`        |
| `onCloseEditor`                | A callback function that will be called before the image editor closes.                                                            | `null`        |
| `mainEditorCallbacks`          | Callbacks from the main editor.                                                                                                    | `null`        |
| `paintEditorCallbacks`         | Callbacks from the paint editor.                                                                                                   | `null`        |
| `textEditorCallbacks`          | Callbacks from the text editor.                                                                                                    | `null`        |
| `cropRotateEditorCallbacks`    | Callbacks from the crop-rotate editor.                                                                                             | `null`        |
| `filterEditorCallbacks`        | Callbacks from the filter editor.                                                                                                  | `null`        |
| `blurEditorCallbacks`          | Callbacks from the blur editor.                                                                                                    | `null`        |



<details>
  <summary><b>i18n</b> </summary>
 
| Property Name              | Description                                                                                                  | Default Value                |
|----------------------------|--------------------------------------------------------------------------------------------------------------|------------------------------|
| `paintEditor`              | Translations and messages specific to the painting editor.                                                   | `I18nPaintingEditor()`       |
| `various`                  | Translations and messages for various parts of the editor.                                                   | `I18nVarious()`              |
| `layerInteraction`         | Translations and messages for layer interactions.                                                            | `I18nLayerInteraction()`     |
| `textEditor`               | Translations and messages specific to the text editor.                                                       | `I18nTextEditor()`           |
| `filterEditor`             | Translations and messages specific to the filter editor.                                                     | `I18nFilterEditor()`         |
| `blurEditor`               | Translations and messages specific to the blur editor.                                                       | `I18nBlurEditor()`           |
| `emojiEditor`              | Translations and messages specific to the emoji editor.                                                      | `I18nEmojiEditor()`          |
| `stickerEditor`            | Translations and messages specific to the sticker editor.                                                    | `I18nStickerEditor()`        |
| `cropRotateEditor`         | Translations and messages specific to the crop and rotate editor.                                            | `I18nCropRotateEditor()`     |
| `doneLoadingMsg`           | Message displayed while changes are being applied.                                                           | `Changes are being applied`  |
| `importStateHistoryMsg`    | Message displayed during the import of state history. If the text is empty, no loading dialog will be shown. | `Initialize Editor`          |
| `cancel`                   | Text for the "Cancel" action.                                                                                | `Cancel`                     |
| `undo`                     | Text for the "Undo" action.                                                                                  | `Undo`                       |
| `redo`                     | Text for the "Redo" action.                                                                                  | `Redo`                       |
| `done`                     | Text for the "Done" action.                                                                                  | `Done`                       |
| `remove`                   | Text for the "Remove" action.                                                                                | `Remove`                     |


#### `i18n paintEditor`

| Property Name             | Description                                                                 | Default Value |
|---------------------------|-----------------------------------------------------------------------------|---------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item that opens the Painting Editor.     | `Paint`       |
| `freestyle`               | Text for the "Freestyle" painting mode.                                     | `Freestyle`   |
| `arrow`                   | Text for the "Arrow" painting mode.                                         | `Arrow`       |
| `line`                    | Text for the "Line" painting mode.                                          | `Line`        |
| `rectangle`               | Text for the "Rectangle" painting mode.                                     | `Rectangle`   |
| `circle`                  | Text for the "Circle" painting mode.                                        | `Circle`      |
| `dashLine`                | Text for the "Dash line" painting mode.                                     | `Dash line`   |
| `lineWidth`               | Text for the "Line width" tooltip.                                          | `Line width`  |
| `toggleFill`              | Text for the "Toggle fill" tooltip.                                         | `Toggle fill` |
| `undo`                    | Text for the "Undo" button.                                                 | `Undo`        |
| `redo`                    | Text for the "Redo" button.                                                 | `Redo`        |
| `done`                    | Text for the "Done" button.                                                 | `Done`        |
| `back`                    | Text for the "Back" button.                                                 | `Back`        |
| `smallScreenMoreTooltip`  | The tooltip text displayed for the "More" option on small screens.          | `More`        |



#### `i18n textEditor`

| Property                  | Description                                         | Default Value       |
|---------------------------|-----------------------------------------------------|---------------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item             | `'Text'`            |
| `inputHintText`           | Placeholder text displayed in the text input field  | `'Enter text'`      |
| `done`                    | Text for the "Done" button                          | `'Done'`            |
| `back`                    | Text for the "Back" button                          | `'Back'`            |
| `textAlign`               | Text for the "Align text" setting                   | `'Align text'`      |
| `fontScale`               | Text for the "Font Scale" setting                   | `'Font Scale'`      |
| `backgroundMode`          | Text for the "Background mode" setting              | `'Background mode'` |
| `smallScreenMoreTooltip`  | Tooltip text for the "More" option on small screens | `'More'`            |


#### `i18n cropRotateEditor`

| Property Name             | Description                                                                       | Default Value   |
|---------------------------|-----------------------------------------------------------------------------------|-----------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item that opens the Crop and Rotate Editor.    | `Crop/ Rotate`  |
| `rotate`                  | Text for the "Rotate" tooltip.                                                    | `Rotate`        |
| `flip`                    | Text for the "Flip" tooltip.                                                      | `Flip`          |
| `ratio`                   | Text for the "Ratio" tooltip.                                                     | `Ratio`         |
| `back`                    | Text for the "Back" button.                                                       | `Back`          |
| `cancel`                  | Text for the "Cancel" button. | `Cancel`        |
| `done`                    | Text for the "Done" button.                                                       | `Done`          |
| `reset`                   | Text for the "Reset" button.                                                      | `Reset`         |
| `undo`                    | Text for the "Undo" button.                                                       | `Undo`          |
| `redo`                    | Text for the "Redo" button.                                                       | `Redo`          |
| `smallScreenMoreTooltip`  | The tooltip text displayed for the "More" option on small screens.                | `More`          |



#### `i18n filterEditor`

| Property                 | Description                                         | Default Value                |
|--------------------------|-----------------------------------------------------|------------------------------|
| `applyFilterDialogMsg`   | Text displayed when a filter is being applied       | `'Filter is being applied.'` |
| `bottomNavigationBarText`| Text for the bottom navigation bar item             | `'Filter'`                   |
| `back`                   | Text for the "Back" button in the Filter Editor     | `'Back'`                     |
| `done`                   | Text for the "Done" button in the Filter Editor     | `'Done'`                     |
| `filters`                | Internationalization settings for individual filters| `I18nFilters()`              |


#### `i18n blurEditor`

| Property                 | Description                                        | Default Value             |
|--------------------------|----------------------------------------------------|---------------------------|
| `applyBlurDialogMsg`     | Text displayed when a filter is being applied     | `'Blur is being applied.'` |
| `bottomNavigationBarText`| Text for the bottom navigation bar item           | `'Blur'`                   |
| `back`                   | Text for the "Back" button in the Blur Editor     | `'Back'`                   |
| `done`                   | Text for the "Done" button in the Blur Editor     | `'Done'`                   |


#### `i18n emojiEditor`
| Property Name             | Description                                                                | Default Value  |
|---------------------------|----------------------------------------------------------------------------|----------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item that opens the Emoji Editor.       | `Emoji`        |
| `noRecents`               | Text which shows there are no recent selected emojis.                      | `No Recents`   |
| `search`                  | Hint text in the search field.                                             | `Search`       |


#### `i18n stickerEditor`
| Property                  | Description                                                            | Default Value |
|---------------------------|------------------------------------------------------------------------|---------------|
| `bottomNavigationBarText` | Text for the bottom navigation bar item that opens the Sticker Editor. | 'Stickers'    |


#### `i18n various`

| Property                      | Description                                                             | Default Value                                                                        |
| ----------------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| `loadingDialogMsg`            | Text for the loading dialog message.                                    | `'Please wait...'`                                                                   |
| `closeEditorWarningTitle`     | Title for the warning message when closing the Image Editor.            | `'Close Image Editor?'`                                                              |
| `closeEditorWarningMessage`   | Warning message when closing the Image Editor.                          | `'Are you sure you want to close the Image Editor? Your changes will not be saved.'` |
| `closeEditorWarningConfirmBtn`| Text for the confirmation button in the close editor warning dialog.    | `'OK'`                                                                               |
| `closeEditorWarningCancelBtn` | Text for the cancel button in the close editor warning dialog.          | `'Cancel'`                                                                           |
</details>


<br/>

### Contributing

I welcome contributions from the open-source community to make this project even better. Whether you want to report a bug, suggest a new feature, or contribute code, I appreciate your help.

#### Bug Reports and Feature Requests

If you encounter a bug or have an idea for a new feature, please open an issue on my [GitHub Issues](https://github.com/hm21/pro_image_editor/issues) page. I will review it and discuss the best approach to address it.

#### Code Contributions

If you'd like to contribute code to this project, please follow these steps:

1. Fork the repository to your GitHub account.
2. Clone your forked repository to your local machine.

```bash
git clone https://github.com/hm21/pro_image_editor.git
```

<br/>

## Contributors
<a href="https://github.com/hm21/pro_image_editor/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=hm21/pro_image_editor" />
</a>

Made with [contrib.rocks](https://contrib.rocks).

<br/>

### Included Packages

This package uses several Flutter packages to provide a seamless editing experience. A big thanks to the authors of these amazing packages. Here’s a list of the packages we used in this project:

- [emoji_picker_flutter](https://pub.dev/packages/emoji_picker_flutter)
- [http](https://pub.dev/packages/http)
- [image](https://pub.dev/packages/image)
- [rounded_background_text](https://pub.dev/packages/rounded_background_text)
- [vibration](https://pub.dev/packages/vibration)

From these packages, only a small part of the code is used, with some code changes that better fit to the image editor.
- [colorfilter_generator](https://pub.dev/packages/colorfilter_generator)
- [defer_pointer](https://pub.dev/packages/defer_pointer)

