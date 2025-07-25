import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '/core/models/editor_callbacks/pro_image_editor_callbacks.dart';
import '/core/models/editor_configs/pro_image_editor_configs.dart';
import '/core/models/layers/layer.dart';
import '/core/services/keyboard_service.dart';
import '/core/utils/size_utils.dart';
import '/features/main_editor/controllers/main_editor_controllers.dart';
import '/features/main_editor/services/layer_interaction_manager.dart';
import '/features/main_editor/services/sizes_manager.dart';
import '/plugins/defer_pointer/defer_pointer.dart';
import '/shared/utils/unique_id_generator.dart';
import '/shared/widgets/extended/mouse_region/extended_rebuild_mouse_region.dart';
import '/shared/widgets/layer/layer_widget.dart';
import '../main_editor.dart';

/// A widget that manages and displays layers in the main editor, handling
/// interactions, configurations, and callbacks for user actions.
class MainEditorLayers extends StatefulWidget {
  /// Creates a `MainEditorLayers` widget with the necessary configurations,
  /// managers, and callbacks.
  ///
  /// - [state]: Represents the current state of the editor.
  /// - [configs]: Configuration settings for the editor.
  /// - [callbacks]: Provides callbacks for editor interactions.
  /// - [sizesManager]: Manages size-related settings and adjustments.
  /// - [controllers]: Manages the main editor's controllers.
  /// - [layerInteraction]: Configurations for layer interactions.
  /// - [layerInteractionManager]: Handles interactions with editor layers.
  /// - [mouseCursorsKey]: Key for managing mouse cursor regions.
  /// - [activeLayers]: List of active layers in the editor.
  /// - [selectedLayerIndex]: The index of the currently selected layer.
  /// - [isSubEditorOpen]: Indicates whether a sub-editor is currently open.
  /// - [checkInteractiveViewer]: Callback to check the state of the
  ///   interactive viewer.
  /// - [onTextLayerTap]: Callback triggered when a text layer is tapped.
  /// - [setTempLayer]: Callback to temporarily set a layer for interaction.
  /// - [onContextMenuToggled]: Callback triggered when the context menu is
  ///   toggled.
  const MainEditorLayers({
    super.key,
    required this.controllers,
    required this.layerInteraction,
    required this.layerInteractionManager,
    required this.configs,
    required this.callbacks,
    required this.sizesManager,
    required this.selectedLayerIndex,
    required this.activeLayers,
    required this.isSubEditorOpen,
    required this.checkInteractiveViewer,
    required this.onTextLayerTap,
    required this.onEditPaintLayer,
    required this.state,
    required this.setTempLayer,
    required this.onContextMenuToggled,
    required this.onDuplicateLayer,
    this.enableMultiSelectMode = false,
  });

  /// Represents the current state of the editor.
  final ProImageEditorState state;

  /// Configuration settings for the editor.
  final ProImageEditorConfigs configs;

  /// Provides callbacks for editor interactions.
  final ProImageEditorCallbacks callbacks;

  /// Manages size-related settings and adjustments.
  final SizesManager sizesManager;

  /// Manages the main editor's controllers.
  final MainEditorControllers controllers;

  /// Configurations for layer interactions.
  final LayerInteractionConfigs layerInteraction;

  /// Handles interactions with editor layers.
  final LayerInteractionManager layerInteractionManager;

  /// List of active layers in the editor.
  final List<Layer> activeLayers;

  /// The index of the currently selected layer.
  final int selectedLayerIndex;

  /// Indicates whether a sub-editor is currently open.
  final bool isSubEditorOpen;

  /// If true, always allow multi-select (even without CTRL/SHIFT)
  final bool enableMultiSelectMode;

  /// Callback to check the state of the interactive viewer.
  final Function() checkInteractiveViewer;

  /// Callback triggered when a text layer is tapped.
  final Function(TextLayer layer) onTextLayerTap;

  /// A callback function that is triggered when a paint layer is edited.
  final Function(PaintLayer layer) onEditPaintLayer;

  /// Callback to temporarily set a layer for interaction.
  final Function(Layer layer) setTempLayer;

  /// Callback triggered when a layer should be copied.
  final Function(Layer layer) onDuplicateLayer;

  /// Callback triggered when the context menu is toggled.
  final Function(bool isOpen)? onContextMenuToggled;

  @override
  State<MainEditorLayers> createState() => _MainEditorLayersState();
}

class _MainEditorLayersState extends State<MainEditorLayers> {
  final _keyboard = KeyboardService();
  final _deferId = ValueNotifier(generateUniqueId());

  /// Represents the dimensions of the body.
  Size editorBodySize = Size.infinite;

  /// Key for managing mouse cursor regions.
  final _mouseCursorsKey = GlobalKey<ExtendedRebuildMouseRegionState>();

  bool _isScaleInteractionActive = false;

  // Helper methods for handling layer interactions
  void _handleEditTap(int index, Layer layer) {
    if (layer.isTextLayer) {
      widget.onTextLayerTap(layer as TextLayer);
    } else if (layer.isPaintLayer) {
      widget.onEditPaintLayer(layer as PaintLayer);
    } else if (layer.isWidgetLayer) {
      widget.callbacks.stickerEditorCallbacks?.onTapEditSticker
          ?.call(widget.state, layer as WidgetLayer, index);
    }
  }

  void _handleLayerTap(Layer layer) {
    // Only handle selection if selectable
    if (widget.layerInteractionManager.layersAreSelectable(widget.configs) &&
        layer.interaction.enableSelection) {
      final allowMultiSelect = widget.enableMultiSelectMode ||
          _keyboard.isCtrlPressed ||
          _keyboard.isShiftPressed;

      final selectedIds = widget.layerInteractionManager.selectedLayerIds;
      final alreadySelected = selectedIds.contains(layer.id);

      // If not multi-selecting, clear selection first
      if (!allowMultiSelect) {
        widget.layerInteractionManager.clearSelectedLayers();
      }

      // If the layer has a groupId, select all layers with that groupId
      Set<String> groupIds = {};
      if (layer.groupId != null) {
        groupIds = widget.activeLayers
            .where((l) => l.groupId == layer.groupId)
            .map((l) => l.id)
            .toSet();
      }

      if (groupIds.isNotEmpty) {
        // Toggle group selection
        if (groupIds.every(selectedIds.contains)) {
          for (final id in groupIds) {
            widget.layerInteractionManager.removeSelectedLayer(id);
          }
        } else {
          for (final id in groupIds) {
            widget.layerInteractionManager.addSelectedLayer(id);
          }
        }
      } else {
        // Toggle single layer
        if (alreadySelected && allowMultiSelect) {
          widget.layerInteractionManager.removeSelectedLayer(layer.id);
        } else {
          widget.layerInteractionManager.addSelectedLayer(layer.id);
        }
      }
      // After selection, update selectedLayerIndex to last selected (if any)
      if (widget.layerInteractionManager.selectedLayerIds.isNotEmpty) {
        final lastId = widget.layerInteractionManager.selectedLayerIds.last;
        final idx = widget.activeLayers.indexWhere((l) => l.id == lastId);
        if (idx != -1) widget.state.selectedLayerIndex = idx;
      }
      widget.checkInteractiveViewer();
    } else if (layer.interaction.enableEdit) {
      if (layer.isTextLayer && widget.configs.textEditor.enableEdit) {
        widget.onTextLayerTap(layer as TextLayer);
      } else if (layer.isPaintLayer && widget.configs.paintEditor.enableEdit) {
        widget.onEditPaintLayer(layer as PaintLayer);
      }
    }
  }

  void _handleTapUp(Layer layer) {
    if (_isScaleInteractionActive) return;
    if (widget.layerInteractionManager.hoverRemoveBtn) {
      widget.state.removeLayer(layer);
    }
    widget.controllers.uiLayerCtrl.add(null);
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
    widget.state.selectedLayerIndex = -1;
    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.onLayerTapUp?.call(layer);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _deferId.value = generateUniqueId();
    });
  }

  void _handleTapDown(int index, Layer layer) {
    if (_isScaleInteractionActive) return;
    // Only update selectedLayerIndex and tempLayer if not multi-selecting

    if (!(_keyboard.isCtrlPressed || _keyboard.isShiftPressed)) {
      widget.state.selectedLayerIndex = index;
      widget.setTempLayer(layer);
    }
    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.onLayerTapDown?.call(layer);
  }

  void _handleScaleRotateDown(int index, Size layerOriginalSize, Layer layer) {
    _isScaleInteractionActive = true;
    widget.state.selectedLayerIndex = index;
    widget.layerInteractionManager
      ..rotateScaleLayerSizeHelper = layerOriginalSize
      ..rotateScaleLayerScaleHelper = layer.scale;
    widget.checkInteractiveViewer();
  }

  void _handleScaleRotateUp() {
    _isScaleInteractionActive = false;
    widget.layerInteractionManager
      ..rotateScaleLayerSizeHelper = null
      ..rotateScaleLayerScaleHelper = null;
    widget.state.setState(() => widget.state.selectedLayerIndex = -1);
    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  void _handleRemoveLayer(Layer layer) {
    widget.state.setState(() => widget.state.removeLayer(layer));
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
  }

  /// Handles mouse hover events to change the cursor style
  void _handleMouseHover(PointerHoverEvent event) {
    final bool hasHit = widget.activeLayers
        .any((element) => element is PaintLayer && element.item.hit);

    final activeCursor = _mouseCursorsKey.currentState!.currentCursor;
    final moveCursor = widget.layerInteraction.style.hoverCursor;

    if (hasHit && activeCursor != moveCursor) {
      _mouseCursorsKey.currentState!.setCursor(moveCursor);
    } else if (!hasHit && activeCursor != SystemMouseCursors.basic) {
      _mouseCursorsKey.currentState!.setCursor(SystemMouseCursors.basic);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: widget.selectedLayerIndex >= 0,
      child: StreamBuilder<bool>(
        stream: widget.controllers.layerHeroResetCtrl.stream,
        initialData: false,
        builder: (context, resetLayerSnapshot) {
          // Render an empty container when resetting layers
          if (resetLayerSnapshot.data!) return const SizedBox.shrink();

          return LayoutBuilder(builder: (context, constraints) {
            editorBodySize = constraints.biggest;
            return _buildLayerRepaintBoundary();
          });
        },
      ),
    );
  }

  /// Builds the layer repaint boundary widget
  Widget _buildLayerRepaintBoundary() {
    return RepaintBoundary(
      child: ExtendedRebuildMouseRegion(
        key: _mouseCursorsKey,
        onHover: isDesktop ? _handleMouseHover : null,
        child: ValueListenableBuilder(
            valueListenable: _deferId,
            builder: (_, deferId, __) {
              return DeferredPointerHandler(
                id: deferId,
                selectedLayerId: widget.layerInteractionManager.selectedLayerId,
                child: StreamBuilder(
                  stream: widget.controllers.uiLayerCtrl.stream,
                  builder: (context, snapshot) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        setState(() {
                          widget.layerInteractionManager.clearSelectedLayers();
                          widget.state.selectedLayerIndex = -1;
                        });
                        widget.checkInteractiveViewer();
                      },
                      child: Stack(
                        children: widget.activeLayers
                            .asMap()
                            .entries
                            .map(_buildLayerWidget)
                            .toList(),
                      ),
                    );
                  },
                ),
              );
            }),
      ),
    );
  }

  /// Builds a single layer widget
  Widget _buildLayerWidget(MapEntry<int, Layer> entry) {
    var bodySize =
        getValidSizeOrDefault(widget.sizesManager.bodySize, editorBodySize);

    int index = entry.key;
    Layer layer = entry.value;
    final selected =
        widget.layerInteractionManager.selectedLayerIds.contains(layer.id);
    return LayerWidget(
      key: layer.key,
      configs: widget.configs,
      callbacks: widget.callbacks,
      editorCenterX: bodySize.width / 2,
      editorCenterY: bodySize.height / 2,
      layerData: layer,
      enableHitDetection: widget.layerInteractionManager.enabledHitDetection,
      selected: selected,
      isInteractive: !widget.isSubEditorOpen,
      highPerformanceMode:
          widget.layerInteractionManager.freeStyleHighPerformance,
      onEditTap: () => _handleEditTap(index, layer),
      onTap: _handleLayerTap,
      onTapUp: () => _handleTapUp(layer),
      onTapDown: () => _handleTapDown(index, layer),
      onScaleRotateDown: (details, layerOriginalSize) =>
          _handleScaleRotateDown(index, layerOriginalSize, layer),
      onDuplicate: () => widget.onDuplicateLayer(layer),
      onContextMenuToggled: widget.onContextMenuToggled,
      onScaleRotateUp: (details) => _handleScaleRotateUp(),
      onRemoveTap: () => _handleRemoveLayer(layer),
    );
  }
}
