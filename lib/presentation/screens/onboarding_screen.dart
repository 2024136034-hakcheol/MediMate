import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import 'main_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _ctrl = PageController();
  int _page = 0;

  final _pages = const [
    _OnboardingPage(
      eyebrow: 'STEP 01',
      icon: Icons.camera_alt_rounded,
      title: '약 포장을 찍으면\n끝입니다',
      desc: '복잡한 입력 없이\n카메라 한 장으로 약을 등록하세요',
    ),
    _OnboardingPage(
      eyebrow: 'STEP 02',
      icon: Icons.auto_awesome_rounded,
      title: 'AI가 약 정보를\n자동으로 분석합니다',
      desc: '약 이름·용량·복용법·주의사항까지\nGemini AI가 한 번에 읽어드립니다',
    ),
    _OnboardingPage(
      eyebrow: 'STEP 03',
      icon: Icons.notifications_active_rounded,
      title: '복용 시간에 딱\n맞춰 알려드립니다',
      desc: '설정한 시간에 알림이 울리면\n버튼 하나로 복용 완료 처리하세요',
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 320), curve: Curves.easeOutCubic);
    } else {
      _start();
    }
  }

  Future<void> _start() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.navyDeep, AppColors.navy, AppColors.tealDeep],
            stops: [0.0, 0.55, 1.0],
          ),
        ),
        child: Stack(
          children: [
            PageView.builder(
              controller: _ctrl,
              itemCount: _pages.length,
              onPageChanged: (i) => setState(() => _page = i),
              itemBuilder: (_, i) => _pages[i],
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 20, 28, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(color: Color(0xFF5EEAD4), shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'MEDIMATE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              letterSpacing: 2.4,
                            ),
                          ),
                        ],
                      ),
                      if (_page < _pages.length - 1)
                        TextButton(
                          onPressed: _start,
                          style: TextButton.styleFrom(foregroundColor: Colors.white70),
                          child: const Text('건너뛰기'),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 260),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _page == i ? 28 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _page == i ? const Color(0xFF5EEAD4) : Colors.white.withValues(alpha: 0.28),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _next,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.navy,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 0,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_page == _pages.length - 1 ? '시작하기' : '다음'),
                              const SizedBox(width: 6),
                              const Icon(Icons.arrow_forward_rounded, size: 18),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final String eyebrow;
  final IconData icon;
  final String title;
  final String desc;

  const _OnboardingPage({
    required this.eyebrow,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32, 0, 32, 140),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
              ),
              child: Icon(icon, size: 44, color: const Color(0xFF5EEAD4)),
            ),
            const SizedBox(height: 36),
            Text(
              eyebrow,
              style: const TextStyle(
                color: Color(0xFF5EEAD4),
                fontWeight: FontWeight.w800,
                fontSize: 13,
                letterSpacing: 2.2,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.35,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              desc,
              style: const TextStyle(
                fontSize: 15.5,
                color: Color(0xFFCBD5E1),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
