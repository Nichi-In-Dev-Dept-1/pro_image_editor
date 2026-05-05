import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Clips a child to the current crop rectangle and applies an alpha mask image
/// inside that rectangle.
class MaskImageCropper extends StatefulWidget {
  const MaskImageCropper({
    required this.child,
    required this.maskImage,
    required this.cropRect,
    required this.clipper,
    super.key,
  });

  final Widget child;
  final ImageProvider maskImage;
  final Rect cropRect;
  final CustomClipper<Rect> clipper;

  @override
  State<MaskImageCropper> createState() => _MaskImageCropperState();
}

class _MaskImageCropperState extends State<MaskImageCropper> {
  ImageStream? _imageStream;
  ImageStreamListener? _listener;
  ui.Image? _maskUiImage;
  int _imageResolverId = 0;

  @override
  void initState() {
    super.initState();
    _resolveMaskImage();
  }

  @override
  void didUpdateWidget(covariant MaskImageCropper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.maskImage != widget.maskImage) {
      _resolveMaskImage();
    }
  }

  @override
  void dispose() {
    _removeImageListener();
    _disposeMaskImage();
    super.dispose();
  }

  void _resolveMaskImage() {
    _removeImageListener();
    _disposeMaskImage();
    final resolverId = ++_imageResolverId;
    final stream = widget.maskImage.resolve(
      createLocalImageConfiguration(context),
    );

    _listener = ImageStreamListener((ImageInfo imageInfo, bool _) {
      if (!mounted || resolverId != _imageResolverId) return;
      setState(() {
        _disposeMaskImage();
        _maskUiImage = imageInfo.image;
      });
    }, onError: (Object error, StackTrace? stackTrace) {
      if (!mounted || resolverId != _imageResolverId) return;
      setState(_disposeMaskImage);
    });

    _imageStream = stream..addListener(_listener!);
  }

  void _disposeMaskImage() {
    _maskUiImage?.dispose();
    _maskUiImage = null;
  }

  void _removeImageListener() {
    _imageResolverId++;
    final listener = _listener;
    final imageStream = _imageStream;
    if (listener != null && imageStream != null) {
      imageStream.removeListener(listener);
    }
    _listener = null;
    _imageStream = null;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      clipper: widget.clipper,
      child: CustomPaint(
        foregroundPainter: _maskUiImage == null
            ? null
            : _MaskImagePainter(
                image: _maskUiImage!,
                cropRect: widget.cropRect,
              ),
        child: widget.child,
      ),
    );
  }
}

class _MaskImagePainter extends CustomPainter {
  const _MaskImagePainter({required this.image, required this.cropRect});

  final ui.Image image;
  final Rect cropRect;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      cropRect,
      Paint()..blendMode = BlendMode.dstIn,
    );
  }

  @override
  bool shouldRepaint(covariant _MaskImagePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.cropRect != cropRect;
  }
}
