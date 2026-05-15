// lib/features/auth/presentation/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../provider/auth_provider.dart';
import '../../health_profile/presentation/health_input_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _nameCtrl            = TextEditingController();
  final _emailCtrl           = TextEditingController();
  final _passwordCtrl        = TextEditingController();
  final _passwordConfirmCtrl = TextEditingController();
  bool _obscure        = true;
  bool _obscureConfirm = true;
  bool _isLoading      = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _passwordConfirmCtrl.dispose();
    super.dispose();
  }

  //유효성 검사
  String? _validate() {
    if (_nameCtrl.text.trim().isEmpty) return '이름을 입력해주세요';
    if (_emailCtrl.text.trim().isEmpty) return '이메일을 입력해주세요';
    if (!_emailCtrl.text.contains('@')) return '올바른 이메일 형식이 아닙니다';
    if (_passwordCtrl.text.length < 8) return '비밀번호는 8자 이상이어야 합니다';
    if (_passwordCtrl.text != _passwordConfirmCtrl.text) {
      return '비밀번호가 일치하지 않습니다';
    }
    return null;
  }

  Future<void> _register() async {
    final error = _validate();
    if (error != null) {
      _showSnackbar(error);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(authProvider.notifier).register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (mounted) {
        // 회원가입 성공시 건강정보 입력 화면으로 이동
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => const HealthInputScreen()),
        );
      }
    } catch (e) {
      _showSnackbar('회원가입 실패: 이미 사용 중인 이메일일 수 있습니다');
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('회원가입'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),

              // 안내 텍스트
              const Text('계정 정보 입력',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
              const SizedBox(height: 6),
              const Text('회원가입 후 건강 정보를 입력하면\n맞춤형 혈당 관리를 시작할 수 있습니다',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  )),
              const SizedBox(height: 32),

              _fieldLabel('이름'),
              const SizedBox(height: 6),
              TextField(
                controller: _nameCtrl,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: '아무개',
                  prefixIcon: Icon(
                    Icons.person_outline,
                    color: AppColors.textTertiary, size: 18,
                  ),
                ),
              ),
              const SizedBox(height: 14),

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
              ),
              const SizedBox(height: 14),

              _fieldLabel('비밀번호 확인'),
              const SizedBox(height: 6),
              TextField(
                controller: _passwordConfirmCtrl,
                obscureText: _obscureConfirm,
                style: const TextStyle(
                    color: AppColors.textPrimary, fontSize: 14),
                decoration: InputDecoration(
                  hintText: '비밀번호 재입력',
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.textTertiary, size: 18,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary, size: 18,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                // 비밀번호 일치 여부 실시간 표시
                onChanged: (_) => setState(() {}),
              ),

              // 비밀번호 일치 여부 표시
              if (_passwordConfirmCtrl.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Row(
                    children: [
                      Icon(
                        _passwordCtrl.text == _passwordConfirmCtrl.text
                            ? Icons.check_circle_outline
                            : Icons.cancel_outlined,
                        size: 14,
                        color: _passwordCtrl.text == _passwordConfirmCtrl.text
                            ? AppColors.riskLow
                            : AppColors.riskHigh,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _passwordCtrl.text == _passwordConfirmCtrl.text
                            ? '비밀번호가 일치합니다'
                            : '비밀번호가 일치하지 않습니다',
                        style: TextStyle(
                          fontSize: 11,
                          color: _passwordCtrl.text == _passwordConfirmCtrl.text
                              ? AppColors.riskLow
                              : AppColors.riskHigh,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 40),

              _isLoading
                  ? const Center(
                  child: CircularProgressIndicator(
                      color: AppColors.accent, strokeWidth: 2))
                  : _GradientButton(
                label: '회원가입',
                onTap: _register,
              ),
              const SizedBox(height: 16),

              // 로그인으로 돌아가기
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text('이미 계정이 있으신가요? 로그인',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      )),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) {
    return Text(label,
        style: const TextStyle(
          fontSize: 11, color: AppColors.textSecondary,
        ));
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