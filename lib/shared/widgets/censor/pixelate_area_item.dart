import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:pro_image_editor/shared/services/shader_manager.dart';

import 'abstract/censor_area_item.dart';

/// A widget that applies a pixelate effect to a defined area.
///
/// This class extends [CensorAreaItem] and implements the pixelate effect
/// using a [BackdropFilter] with a pixelate shader.
class PixelateAreaItem extends CensorAreaItem {
  /// Creates a [PixelateAreaItem] with the specified [censorConfigs] and
  /// optional [size].
  const PixelateAreaItem({
    super.key,
    required super.censorConfigs,
    super.size,
  });

  @override
  Widget build(BuildContext context) {
    assert(
      ShaderManager.instance.isShaderFilterSupported,
      'Shader filters are not supported on the current backend.',
    );
    if (!ShaderManager.instance.isShaderFilterSupported) {
      return const SizedBox();
    }

    return super.build(context);
  }

  @override
  Widget buildBackdropFilter({required Widget child}) {
    /// Return cached shader
    if (ShaderManager.instance.containsShader(ShaderMode.pixelate)) {
      return _buildFilter(
        shader: ShaderManager.instance.shaders[ShaderMode.pixelate]!,
        child: child,
      );
    }

    /// Load shader
    return FutureBuilder(
        future: ShaderManager.instance.loadShader(ShaderMode.pixelate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            assert(false, 'Error loading shader: ${snapshot.error}');
            return const SizedBox.shrink();
          } else if (!snapshot.hasData) {
            assert(false, 'Shader is null');
            return const SizedBox.shrink();
          }

          FragmentShader shader = snapshot.data!;
          return _buildFilter(shader: shader, child: child);
        });
  }

  Widget _buildFilter({
    required Widget child,
    required FragmentShader shader,
  }) {
    shader
      ..setFloat(0, size?.width ?? 100)
      ..setFloat(1, size?.height ?? 100)
      ..setFloat(2, censorConfigs.pixelatePixelSize);
    return BackdropFilter(
      filter: ImageFilter.shader(shader),
      child: child,
    );
  }
}
