import 'package:flutter/material.dart';

/// A generic "coming soon" screen for features not yet built out.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key, required this.title, this.message = '준비 중인 기능이에요'});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text(message, style: const TextStyle(color: Colors.black45)),
      ),
    );
  }
}
