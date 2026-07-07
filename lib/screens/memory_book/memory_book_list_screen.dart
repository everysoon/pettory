import 'package:flutter/material.dart';

class MemoryBookListScreen extends StatelessWidget {
  const MemoryBookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('추억북')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            '아직 만들어진 추억북이 없어요.\n기록이 쌓이면 자동으로 만들어드릴게요 📖',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black45),
          ),
        ),
      ),
    );
  }
}
