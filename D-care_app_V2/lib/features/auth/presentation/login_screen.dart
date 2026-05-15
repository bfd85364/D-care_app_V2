// lib/features/auth/presentation/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../provider/auth_provider.dart';
import 'register_screen.dart';
import '../../health_profile/presentation/health_input_screen.dart';
import '../../../main.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      _showSnackbar('이메일과 비밀번호를 입력해주세요');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (mounted) {
        // 로그인 성공 → 메인 화면으로
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
        );
      }
    } catch (e) {
      _showSnackbar('로그인 실패: 이메일 또는 비밀번호를 확인해주세요');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackbar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg,
            style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor: AppColors.bgSecondary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // 로고
              _Logo(),
              const SizedBox(height: 48),

              //이메일
              _fieldLabel('이메일'),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'example@email.com',
                  prefixIcon: Icon(
                    Icons.email_outlined,
                    color: AppColors.textTertiary, size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              //비밀번호
              _fieldLabel('비밀번호'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordCtrl,
                obscureText: _obscure,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '8자 이상 입력',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textTertiary, size: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary, size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscure = !_obscure),
                  ),
                ),
                onSubmitted: (_) => _login(),
              ),
              const SizedBox(height: 32),

              //로그인 버튼
              _isLoading
                  ? const CircularProgressIndicator(
                  color: AppColors.accent, strokeWidth: 2)
                  : _GradientButton(
                label: '로그인',
                onTap: _login,
              ),
              const SizedBox(height: 16),

              //회원가입 이동
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('계정이 없으신가요?',
                      style: TextStyle(
                        fontSize: 13, color: AppColors.textSecondary,
                      )),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const RegisterScreen()),
                    ),
                    child: const Text('회원가입',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              //면책 조항
              const Text(
                '이 서비스는 의료 진단을 대체하지 않습니다.\n정확한 진단은 반드시 전문의와 상담하세요.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textTertiary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(
            fontSize: 11, color: AppColors.textSecondary,
          )),
    );
  }
}

//로고 구성(정적 위젯)
class _Logo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72, height: 72,
          decoration: BoxDecoration(
            gradient: AppColors.accentGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.accent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.medical_services_rounded,
            color: Colors.white, size: 36,
          ),
        ),
        const SizedBox(height: 16),
        const Text('D-Care',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
              letterSpacing: 1,
            )),
        const SizedBox(height: 6),
        const Text('당뇨 혈당 관리 챗봇',
            style: TextStyle(
              fontSize: 13, color: AppColors.textSecondary,
            )),
      ],
    );
  }
}

// 버튼 디자인
class _GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GradientButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.accent.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              )),
        ),
      ),
    );
  }
}