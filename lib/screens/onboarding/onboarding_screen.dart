import 'package:flutter/material.dart';

import '../../theme.dart';
import '../auth/login_screen.dart';

class _OnboardingPageData {
  const _OnboardingPageData({required this.title, required this.subtitle});

  final String title;
  final String subtitle;
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  int _page = 0;

  static const _pages = [
    _OnboardingPageData(
      title: '매일의 순간을,\n잊지 마세요',
      subtitle: '사진과 짧은 글로 오늘 하루를 남겨보세요',
    ),
    _OnboardingPageData(
      title: '우리 아이가\n답장을 보내요',
      subtitle: '일기를 쓰면, 우리 아이만의 말투로 답장이 와요',
    ),
    _OnboardingPageData(
      title: '가족과 함께\n채워가는 추억',
      subtitle: '가족코드로 초대해서 함께 기록해보세요',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  void _next() {
    if (_page == _pages.length - 1) {
      _goToLogin();
      return;
    }
    _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _page == _pages.length - 1;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: TextButton(
                  onPressed: _goToLogin,
                  child: const Text('건너뛰기', style: TextStyle(color: Colors.black54)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return LayoutBuilder(
                    builder: (context, constraints) => SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: constraints.maxHeight),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: AppColors.cardBorder.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: const Icon(Icons.image_outlined, size: 48, color: Colors.black26),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                page.title,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.4),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                page.subtitle,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 14, color: Colors.black54),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: i == _page ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: i == _page ? AppColors.primaryDark : AppColors.cardBorder,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _next,
                  child: Text(isLast ? '시작하기' : '다음'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
