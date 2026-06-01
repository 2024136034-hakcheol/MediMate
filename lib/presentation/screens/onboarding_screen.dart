import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
      icon: Icons.camera_alt_rounded,
      title: '약 포장을 찍으면\n끝입니다',
      desc: '복잡한 입력 없이\n카메라 한 장으로 약을 등록하세요',
      color: Color(0xFF1b5e20),
    ),
    _OnboardingPage(
      icon: Icons.auto_awesome,
      title: 'AI가 약 정보를\n자동으로 분석합니다',
      desc: '약 이름·용량·복용법·주의사항까지\nGemini AI가 한 번에 읽어드립니다',
      color: Color(0xFF2e7d32),
    ),
    _OnboardingPage(
      icon: Icons.notifications_active_rounded,
      title: '복용 시간에 딱\n맞춰 알려드립니다',
      desc: '설정한 시간에 알림이 울리면\n버튼 하나로 복용 완료 처리하세요',
      color: Color(0xFF388e3c),
    ),
  ];

  void _next() {
    if (_page < _pages.length - 1) {
      _ctrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
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
      body: Stack(
        children: [
          PageView.builder(
            controller: _ctrl,
            itemCount: _pages.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => _pages[i],
          ),
          // 하단 컨트롤
          Positioned(
            left: 0, right: 0, bottom: 48,
            child: Column(
              children: [
                // 점 인디케이터
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_pages.length, (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: _page == i ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? Colors.white : Colors.white38,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  )),
                ),
                const SizedBox(height: 32),
                // 버튼
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _next,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF2e7d32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                        elevation: 0,
                      ),
                      child: Text(_page == _pages.length - 1 ? '시작하기' : '다음'),
                    ),
                  ),
                ),
                if (_page < _pages.length - 1)
                  TextButton(
                    onPressed: _start,
                    child: const Text('건너뛰기', style: TextStyle(color: Colors.white60)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _OnboardingPage({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, Color.lerp(color, Colors.black, 0.3)!],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 80, color: Colors.white),
              ),
              const SizedBox(height: 48),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold,
                  color: Colors.white, height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                desc,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16, color: Colors.white70, height: 1.6,
                ),
              ),
              const SizedBox(height: 160),
            ],
          ),
        ),
      ),
    );
  }
}
