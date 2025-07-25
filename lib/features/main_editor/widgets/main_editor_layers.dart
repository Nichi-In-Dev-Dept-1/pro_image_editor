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
  /// - [activeLayers]: List of active layers in the editor.
  /// - [isSubEditorOpen]: Indicates whether a sub-editor is currently open.
  /// - [checkInteractiveViewer]: Callback to check the state of the
  ///   interactive viewer.
  /// - [onTextLayerTap]: Callback triggered when a text layer is tapped.
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
    required this.activeLayers,
    required this.isSubEditorOpen,
    required this.isLayerBeingTransformed,
    required this.checkInteractiveViewer,
    required this.onTextLayerTap,
    required this.onEditPaintLayer,
    required this.state,
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

  /// Indicates whether a sub-editor is currently open.
  final bool isSubEditorOpen;

  /// If true, always allow multi-select (even without CTRL/SHIFT)
  final bool enableMultiSelectMode;

  /// Indicates whether a layer is currently being transformed.
  final bool isLayerBeingTransformed;

  /// Callback to check the state of the interactive viewer.
  final Function() checkInteractiveViewer;

  /// Callback triggered when a text layer is tapped.
  final Function(TextLayer layer) onTextLayerTap;

  /// A callback function that is triggered when a paint layer is edited.
  final Function(PaintLayer layer) onEditPaintLayer;

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
  bool _helperIsPointerDownSelected = false;

  late final _layerInteraction = widget.layerInteractionManager;

  bool get _enableMultiSelect =>
      widget.enableMultiSelectMode ||
      _keyboard.isCtrlPressed ||
      _keyboard.isShiftPressed;

  // Helper methods for handling layer interactions
  void _handleEditTap(Layer layer) {
    if (layer.isTextLayer) {
      widget.onTextLayerTap(layer as TextLayer);
    } else if (layer.isPaintLayer) {
      widget.onEditPaintLayer(layer as PaintLayer);
    } else if (layer.isWidgetLayer) {
      widget.callbacks.stickerEditorCallbacks?.onTapEditSticker
          ?.call(widget.state, layer as WidgetLayer);
    }
  }

  void _handleLayerTap(Layer layer) {
    // Only handle selection if selectable
    if (layer.interaction.enableSelection) {
      final selectedIds = _layerInteraction.selectedLayerIds;
      final isAlreadySelected =
          selectedIds.contains(layer.id) && !_helperIsPointerDownSelected;

      if (!_enableMultiSelect) {
        _layerInteraction.clearSelectedLayers();
        if (!isAlreadySelected) {
          _layerInteraction.addSelectedLayer(layer.id);
        }
      } else {
        if (isAlreadySelected) {
          _layerInteraction.removeSelectedLayer(layer.id);
        } else {
          _layerInteraction.addSelectedLayer(layer.id);
        }
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
          _layerInteraction.removeMultipleSelectedLayers(groupIds);
        } else {
          _layerInteraction.addMultipleSelectedLayers(groupIds);
        }
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
    if (!_layerInteraction.layersAreSelectable(widget.configs)) {
      _layerInteraction.clearSelectedLayers();
    }
    if (_isScaleInteractionActive || widget.isLayerBeingTransformed) return;
    if (_layerInteraction.hoverRemoveBtn) {
      widget.state.removeLayer(layer);
    }

    widget.controllers.uiLayerCtrl.add(null);
    widget.callbacks.mainEditorCallbacks?.handleUpdateUI();
    _validateClearLayer();

    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.onLayerTapUp?.call(layer);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _deferId.value = generateUniqueId();
    });
  }

  void _validateClearLayer() {
    if (!widget.configs.layerInteraction.keepSelectionOnInteraction) {
      _layerInteraction.clearSelectedLayers();
    }
  }

  void _handleTapDown(Layer layer) {
    _helperIsPointerDownSelected = false;
    if (_isScaleInteractionActive || widget.isLayerBeingTransformed) return;

    /// If a user directly drags a layer, we first need to ensure the layer is
    /// selected when the pointer goes down.
    if (layer.interaction.enableSelection) {
      final selectedIds = _layerInteraction.selectedLayerIds;
      bool isAlreadySelected = selectedIds.contains(layer.id);

      if (!isAlreadySelected && (selectedIds.isEmpty || _enableMultiSelect)) {
        _helperIsPointerDownSelected = true;
        _layerInteraction.addSelectedLayer(layer.id);
      } else if (!isAlreadySelected && !_enableMultiSelect) {
        _helperIsPointerDownSelected = true;
        _layerInteraction
          ..clearSelectedLayers()
          ..addSelectedLayer(layer.id);
      }
    }

    widget.checkInteractiveViewer();
    widget.callbacks.mainEditorCallbacks?.onLayerTapDown?.call(layer);
  }

  void _handleScaleRotateDown(Size layerOriginalSize, Layer layer) {
    _isScaleInteractionActive = true;

    _layerInteraction
      ..rotateScaleLayerSizeHelper = layerOriginalSize
      ..rotateScaleLayerScaleHelper = layer.scale;
    widget.checkInteractiveViewer();
  }

  void _handleScaleRotateUp() {
    _isScaleInteractionActive = false;
    _layerInteraction
      ..rotateScaleLayerSizeHelper = null
      ..rotateScaleLayerScaleHelper = null;
    _validateClearLayer();
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
    return StreamBuilder<bool>(
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
                selectedLayerId: _layerInteraction.selectedLayerId,
                child: StreamBuilder(
                  stream: widget.controllers.uiLayerCtrl.stream,
                  builder: (context, snapshot) {
                    return GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () {
                        _layerInteraction.clearSelectedLayers();
                        widget.checkInteractiveViewer();
                        setState(() {});
                      },
                      child: Stack(
                        children:
                            widget.activeLayers.map(_buildLayerWidget).toList(),
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
  Widget _buildLayerWidget(Layer layer) {
    var bodySize =
        getValidSizeOrDefault(widget.sizesManager.bodySize, editorBodySize);

    final selected = _layerInteraction.selectedLayerIds.contains(layer.id);
    return LayerWidget(
      key: layer.key,
      configs: widget.configs,
      callbacks: widget.callbacks,
      editorCenterX: bodySize.width / 2,
      editorCenterY: bodySize.height / 2,
      layerData: layer,
      enableHitDetection: _layerInteraction.enabledHitDetection,
      selected: selected,
      isInteractive: !widget.isSubEditorOpen,
      highPerformanceMode: _layerInteraction.freeStyleHighPerformance,
      enableVisibleOverlay:
          _layerInteraction.layersAreSelectable(widget.configs),
      onEditTap: () => _handleEditTap(layer),
      onTap: _handleLayerTap,
      onTapUp: () => _handleTapUp(layer),
      onTapDown: () => _handleTapDown(layer),
      onScaleRotateDown: (details, layerOriginalSize) =>
          _handleScaleRotateDown(layerOriginalSize, layer),
      onDuplicate: () => widget.onDuplicateLayer(layer),
      onContextMenuToggled: widget.onContextMenuToggled,
      onScaleRotateUp: (details) => _handleScaleRotateUp(),
      onRemoveTap: () => _handleRemoveLayer(layer),
    );
  }
}
