import 'dart:io';

import 'package:flutter/material.dart';

class PetAvatar extends StatelessWidget {
  const PetAvatar({
    super.key,
    required this.color,
    this.imagePath,
    this.radius = 28,
    this.emojiSize = 22,
  });

  final Color color;
  final String? imagePath;
  final double radius;
  final double emojiSize;

  @override
  Widget build(BuildContext context) {
    final path = imagePath;
    if (path != null) {
      return CircleAvatar(
        radius: radius,
        backgroundImage: FileImage(File(path)),
      );
    }
    return CircleAvatar(
      radius: radius,
      backgroundColor: color,
      child: Text('🐾', style: TextStyle(fontSize: emojiSize)),
    );
  }
}
