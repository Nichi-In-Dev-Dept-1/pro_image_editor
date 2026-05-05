import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pro_image_editor/core/models/editor_configs/pro_image_editor_configs.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/enums/crop_mode.enum.dart';
import 'package:pro_image_editor/features/crop_rotate_editor/models/transform_configs.dart';
import 'package:pro_image_editor/shared/widgets/transform/mask_image_cropper.dart';
import 'package:pro_image_editor/shared/widgets/transform/transformed_content_generator.dart';

void main() {
  testWidgets('uses MaskImageCropper for mask crop mode', (tester) async {
    final configs = ProImageEditorConfigs(
      cropRotateEditor: CropRotateEditorConfigs(
        initialCropMode: CropMode.mask,
        maskImage: const AssetImage('assets/showcase.jpg'),
      ),
    );

    final transformConfigs = TransformConfigs(
      angle: 0,
      cropRect: const Rect.fromLTWH(10, 10, 60, 60),
      originalSize: const Size(100, 100),
      cropEditorScreenRatio: 1,
      scaleUser: 1,
      scaleRotation: 1,
      aspectRatio: 1,
      flipX: false,
      flipY: false,
      offset: Offset.zero,
      cropMode: CropMode.mask,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SizedBox(
          width: 100,
          height: 100,
          child: TransformedContentGenerator(
            transformConfigs: transformConfigs,
            configs: configs,
            child: const ColoredBox(color: Colors.red),
          ),
        ),
      ),
    );

    expect(find.byType(MaskImageCropper), findsOneWidget);
  });
}
