import 'dart:io';

import 'package:flutter/material.dart';

/// Shows a picked photo, or a colored stand-in tile when no image is set yet.
class PhotoPlaceholder extends StatelessWidget {
  const PhotoPlaceholder({
    super.key,
    this.color = const Color(0xFFE4D9C9),
    this.imagePath,
    this.size = 84,
    this.borderRadius = 12,
    this.onRemove,
  });

  final Color color;
  final String? imagePath;
  final double size;
  final double borderRadius;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    final tile = ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: path != null
          ? Image.file(
              File(path),
              width: size,
              height: size,
              fit: BoxFit.cover,
            )
          : Container(
              width: size,
              height: size,
              color: color,
              child: const Icon(Icons.photo_rounded, color: Colors.white70),
            ),
    );

    if (onRemove == null) return tile;

    return Stack(
      children: [
        tile,
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black45, shape: BoxShape.circle),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
