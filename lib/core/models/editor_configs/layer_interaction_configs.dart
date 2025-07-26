import '../custom_widgets/layer_interaction_widgets.dart';
import '../icons/layer_interaction_icons.dart';
import '../styles/layer_interaction_style.dart';

export '../icons/layer_interaction_icons.dart';
export '../styles/layer_interaction_style.dart';

/// Represents the interaction behavior for a layer.
///
/// This class provides configuration options for layer interactions, such as
/// whether the layer is selectable and its initial selection state.
class LayerInteractionConfigs {
  /// Creates a [LayerInteractionConfigs] instance.
  ///
  /// This constructor allows configuration of layer interaction behavior,
  /// including the selectable state and the initial selection state.
  ///
  /// Example:
  /// ```
  /// LayerInteractionConfigs(
  ///   selectable: LayerInteractionSelectable.manual,
  ///   initialSelected: true,
  /// )
  /// ```
  const LayerInteractionConfigs({
    this.selectable = LayerInteractionSelectable.auto,
    this.initialSelected = false,
    this.hideToolbarOnInteraction = false,
    this.hideVideoControlsOnInteraction = true,
    this.keepSelectionOnInteraction = true,
    this.enableKeyboardMultiSelection = true,
    this.enableLongPressMultiSelection = true,
    this.videoControlsSwitchDuration = const Duration(milliseconds: 220),
    this.icons = const LayerInteractionIcons(),
    this.widgets = const LayerInteractionWidgets(),
    this.style = const LayerInteractionStyle(),
  });

  /// Specifies the selectability behavior for the layer.
  ///
  /// Defaults to [LayerInteractionSelectable.auto].
  final LayerInteractionSelectable selectable;

  /// The layer is automatically selected upon creation.
  /// This option takes effect only when `selectable` is set to `enabled` or
  /// `auto` where the device is a desktop.
  final bool initialSelected;

  /// Determines whether the toolbars should be hidden when the user interacts
  /// with the editor.
  final bool hideToolbarOnInteraction;

  /// Determines whether the video controls should be hidden when the user
  /// interacts with the editor.
  final bool hideVideoControlsOnInteraction;

  /// Determines whether the current selection should be retained when
  /// interacting with layers.
  ///
  /// If set to `true`, the selection remains active during layer interactions.
  /// If set to `false`, the selection will be cleared upon interaction.
  final bool keepSelectionOnInteraction;

  /// Enables multi-selection using keyboard modifiers (Ctrl or Shift).
  ///
  /// When set to `true`, users can select multiple layers by holding down
  /// Ctrl or Shift while clicking or tapping.
  final bool enableKeyboardMultiSelection;

  /// Enables multi-selection via long-press gestures.
  ///
  /// When set to `true`, users can enter multi-select mode by long-pressing
  /// on a layer (useful for touch devices).
  final bool enableLongPressMultiSelection;

  /// The duration of the switch animation when the video controls show/hide.
  final Duration videoControlsSwitchDuration;

  /// Defines icons used in layer interactions.
  final LayerInteractionIcons icons;

  /// Widgets associated with layer interactions.
  final LayerInteractionWidgets widgets;

  /// Style configuration for layer interactions.
  final LayerInteractionStyle style;

  /// Creates a copy of this `LayerInteractionConfigs` object with the given
  /// fields replaced with new values.
  ///
  /// The [copyWith] method allows you to create a new instance of
  /// [LayerInteractionConfigs] with some properties updated while keeping the
  /// others unchanged.
  LayerInteractionConfigs copyWith({
    LayerInteractionSelectable? selectable,
    bool? initialSelected,
    bool? hideToolbarOnInteraction,
    bool? hideVideoControlsOnInteraction,
    bool? keepSelectionOnInteraction,
    bool? enableKeyboardMultiSelection,
    bool? enableLongPressMultiSelection,
    Duration? videoControlsSwitchDuration,
    LayerInteractionIcons? icons,
    LayerInteractionWidgets? widgets,
    LayerInteractionStyle? style,
  }) {
    return LayerInteractionConfigs(
      icons: icons ?? this.icons,
      widgets: widgets ?? this.widgets,
      selectable: selectable ?? this.selectable,
      initialSelected: initialSelected ?? this.initialSelected,
      hideToolbarOnInteraction:
          hideToolbarOnInteraction ?? this.hideToolbarOnInteraction,
      hideVideoControlsOnInteraction:
          hideVideoControlsOnInteraction ?? this.hideVideoControlsOnInteraction,
      keepSelectionOnInteraction:
          keepSelectionOnInteraction ?? this.keepSelectionOnInteraction,
      enableKeyboardMultiSelection:
          enableKeyboardMultiSelection ?? this.enableKeyboardMultiSelection,
      enableLongPressMultiSelection:
          enableLongPressMultiSelection ?? this.enableLongPressMultiSelection,
      videoControlsSwitchDuration:
          videoControlsSwitchDuration ?? this.videoControlsSwitchDuration,
      style: style ?? this.style,
    );
  }
}

/// Enumerates the different selectability states for a layer.
enum LayerInteractionSelectable {
  /// Automatically determines if the layer is selectable based on the device
  /// type.
  ///
  /// If the device is a desktop-device, the layer is selectable; otherwise,
  /// the layer is not selectable.
  auto,

  /// Indicates that the layer is selectable.
  enabled,

  /// Indicates that the layer is not selectable.
  disabled,
}
