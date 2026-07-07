import 'package:flutter/material.dart';

import '../../theme.dart';
import '../main_shell.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _enter(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            children: [
              const SizedBox(height: 64),
              const Text('🐾', style: TextStyle(fontSize: 40)),
              const SizedBox(height: 12),
              const Text(
                '오늘의 우리, 기록해요',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 64),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _enter(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFEE500),
                    foregroundColor: Colors.black87,
                  ),
                  icon: const Text('🟡'),
                  label: const Text('카카오로 시작하기'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _enter(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.apple_rounded),
                  label: const Text('Apple로 시작하기'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _enter(context),
                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.textDark),
                  icon: const Text('🔵'),
                  label: const Text('Google로 시작하기'),
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () => _enter(context),
                child: const Text(
                  '이메일로 계속하기',
                  style: TextStyle(color: Colors.black45, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}
