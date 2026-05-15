// lib/features/auth/presentation/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../provider/auth_provider.dart';
import 'login_screen.dart';
import '../../../main.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn),
    );

    _scaleAnim = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutBack),
    );

    _animCtrl.forward();

    // 2초 후 자동 로그인 확인
    Future.delayed(const Duration(seconds: 2), _checkLogin);
  }

  Future<void> _checkLogin() async {
    final isLoggedIn =
    await ref.read(authProvider.notifier).checkAutoLogin();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) =>
        isLoggedIn ? MainShell(key: mainShellKey) : const LoginScreen(),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Center(
        child: AnimatedBuilder(
          animation: _animCtrl,
          builder: (_, __) => FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 로고
                  Container(
                    width: 88, height: 88,
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.medical_services_rounded,
                      color: Colors.white, size: 44,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('D-Care',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: 2,
                      )),
                  const SizedBox(height: 8),
                  const Text('당뇨 혈당 관리 챗봇',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.5,
                      )),
                  const SizedBox(height: 60),
                  // 로딩 인디케이터
                  SizedBox(
                    width: 24, height: 24,
                    child: CircularProgressIndicator(
                      color: AppColors.accent.withOpacity(0.6),
                      strokeWidth: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}