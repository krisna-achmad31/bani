import 'dart:typed_data';

import 'package:bani/core/theme/app_theme.dart';
import 'package:bani/features/tree/presentation/widgets/common.dart';
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  Full-screen photo preview: pinch to zoom, double-tap to zoom, swipe down or
//  tap ✕ to close. The avatar and the preview share a Hero tag.
// ─────────────────────────────────────────────────────────────────────────────

Future<void> openPhotoViewer(
  BuildContext context, {
  required String photo,
  Uint8List? bytes,
  required String heroTag,
  String? title,
  String? subtitle,
}) =>
    Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, _, _) => _PhotoViewer(
          photo: photo, bytes: bytes, heroTag: heroTag, title: title, subtitle: subtitle),
      transitionsBuilder: (_, anim, _, child) =>
          FadeTransition(opacity: anim, child: child),
    ));

class _PhotoViewer extends StatefulWidget {
  const _PhotoViewer(
      {required this.photo, this.bytes, required this.heroTag, this.title, this.subtitle});
  final String photo;
  final Uint8List? bytes;
  final String heroTag;
  final String? title;
  final String? subtitle;

  @override
  State<_PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<_PhotoViewer> {
  final _zoom = TransformationController();
  var _dragY = 0.0;

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _toggleZoom(TapDownDetails d) {
    final zoomed = _zoom.value.getMaxScaleOnAxis() > 1.01;
    _zoom.value = zoomed
        ? Matrix4.identity()
        : (Matrix4.identity()
          ..translateByDouble(-d.localPosition.dx, -d.localPosition.dy, 0, 1)
          ..scaleByDouble(2.5, 2.5, 1, 1)
          ..translateByDouble(d.localPosition.dx / 2.5, d.localPosition.dy / 2.5, 0, 1));
  }

  @override
  Widget build(BuildContext context) {
    final bytes = widget.bytes ?? decodeBase64Image(widget.photo);
    final opacity = (1 - _dragY.abs() / 400).clamp(0.3, 1.0);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: opacity),
      body: Stack(children: [
        GestureDetector(
          onVerticalDragUpdate: (d) {
            if (_zoom.value.getMaxScaleOnAxis() <= 1.01) setState(() => _dragY += d.delta.dy);
          },
          onVerticalDragEnd: (_) {
            if (_dragY.abs() > 120) {
              Navigator.pop(context);
            } else {
              setState(() => _dragY = 0);
            }
          },
          onDoubleTapDown: _toggleZoom,
          onDoubleTap: () {},
          child: Center(
            child: Transform.translate(
              offset: Offset(0, _dragY),
              child: InteractiveViewer(
                transformationController: _zoom,
                minScale: 1,
                maxScale: 5,
                child: Hero(
                  tag: widget.heroTag,
                  child: bytes == null
                      ? const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 64)
                      : Image.memory(bytes, fit: BoxFit.contain, gaplessPlayback: true),
                ),
              ),
            ),
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 16, 0),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (widget.title != null)
                    Text(widget.title!,
                        style: AppText.body(16, weight: FontWeight.w700, color: Colors.white)),
                  if (widget.subtitle != null)
                    Text(widget.subtitle!, style: AppText.body(12, color: Colors.white70)),
                ]),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}
