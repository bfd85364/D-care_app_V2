// lib/features/health_profile/presentation/health_edit_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';

class HealthEditScreen extends ConsumerStatefulWidget {
  // 기존 프로필 데이터 받아서 초기값으로 사용
  final Map<String, dynamic> currentProfile;
  const HealthEditScreen({super.key, required this.currentProfile});

  @override
  ConsumerState<HealthEditScreen> createState() => _HealthEditScreenState();
}

class _HealthEditScreenState extends ConsumerState<HealthEditScreen> {
  late final TextEditingController _heightCtrl;
  late final TextEditingController _weightCtrl;
  late final TextEditingController _fastingCtrl;
  late final TextEditingController _postprandialCtrl;
  late final TextEditingController _hba1cCtrl;
  late final TextEditingController _systolicCtrl;
  late final TextEditingController _diastolicCtrl;
  late int _smoking;
  late int _exercisePerWeek;
  late bool _familyHistory;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 기존 데이터로 초기값 설정
    final p = widget.currentProfile;
    _heightCtrl       = TextEditingController(text: '${p['height_cm'] ?? ''}');
    _weightCtrl       = TextEditingController(text: '${p['weight_kg'] ?? ''}');
    _fastingCtrl      = TextEditingController(text: '${p['fasting_glucose'] ?? ''}');
    _postprandialCtrl = TextEditingController(text: '${p['postprandial_glucose'] ?? ''}');
    _hba1cCtrl        = TextEditingController(text: '${p['hba1c'] ?? ''}');
    _systolicCtrl     = TextEditingController(text: '${p['systolic_bp'] ?? ''}');
    _diastolicCtrl    = TextEditingController(text: '${p['diastolic_bp'] ?? ''}');
    _smoking          = p['smoking'] ?? 0;
    _exercisePerWeek  = p['exercise_per_week'] ?? 0;
    _familyHistory    = p['family_history'] ?? false;
  }

  @override
  void dispose() {
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _fastingCtrl.dispose();
    _postprandialCtrl.dispose();
    _hba1cCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    super.dispose();
  }

  double get _bmi {
    final h = double.tryParse(_heightCtrl.text) ?? 0;
    final w = double.tryParse(_weightCtrl.text) ?? 0;
    if (h <= 0) return 0;
    return w / ((h / 100) * (h / 100));
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      // TODO: PATCH /api/users/{userId}/health-profile 호출
      await Future.delayed(const Duration(seconds: 1)); // 임시
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('건강 정보가 수정되었습니다'),
            backgroundColor: Color(0xFF1E293B),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
        title: const Text('건강 정보 수정'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 16, height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.accent,
                    ))
                : const Text('저장',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('신체 정보'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _inputField(
                  controller: _heightCtrl,
                  label: '키', suffix: 'cm',
                  onChanged: (_) => setState(() {}),
                )),
                const SizedBox(width: 10),
                Expanded(child: _inputField(
                  controller: _weightCtrl,
                  label: '몸무게', suffix: 'kg',
                  onChanged: (_) => setState(() {}),
                )),
              ],
            ),
            const SizedBox(height: 10),

            // BMI 자동계산
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.bgTertiary, width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('BMI (자동계산)',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  const Spacer(),
                  Text(
                    _bmi > 0 ? _bmi.toStringAsFixed(1) : '-',
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    )),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _sectionTitle('혈당 수치'),
            const SizedBox(height: 12),

            _inputField(controller: _fastingCtrl,
              label: '공복혈당', suffix: 'mg/dL', hint: '정상 < 100'),
            const SizedBox(height: 10),
            _inputField(controller: _postprandialCtrl,
              label: '식후 2시간 혈당', suffix: 'mg/dL', hint: '정상 < 140'),
            const SizedBox(height: 10),
            _inputField(controller: _hba1cCtrl,
              label: 'HbA1c', suffix: '%', hint: '정상 < 5.7'),
            const SizedBox(height: 20),

            _sectionTitle('혈압'),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(child: _inputField(
                  controller: _systolicCtrl, label: '수축기', suffix: 'mmHg')),
                const SizedBox(width: 10),
                Expanded(child: _inputField(
                  controller: _diastolicCtrl, label: '이완기', suffix: 'mmHg')),
              ],
            ),
            const SizedBox(height: 20),

            _sectionTitle('생활습관'),
            const SizedBox(height: 12),

            // 흡연
            _fieldLabel('흡연 여부'),
            const SizedBox(height: 6),
            _ToggleRow(
              options: ['비흡연', '과거흡연', '현재흡연'],
              selected: _smoking,
              onChanged: (v) => setState(() => _smoking = v),
            ),
            const SizedBox(height: 14),

            // 운동
            _fieldLabel('주간 운동 횟수'),
            const SizedBox(height: 6),
            _ExerciseSpinner(
              value: _exercisePerWeek,
              onChanged: (v) => setState(() => _exercisePerWeek = v),
            ),
            const SizedBox(height: 14),

            // 가족력
            _fieldLabel('당뇨 가족력'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgSecondary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.bgTertiary, width: 0.5),
              ),
              child: Row(
                children: [
                  const Text('가족 중 당뇨 환자가 있나요?',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                  const Spacer(),
                  Switch.adaptive(
                    value: _familyHistory,
                    onChanged: (v) => setState(() => _familyHistory = v),
                    activeColor: AppColors.accent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 저장 버튼
            GestureDetector(
              onTap: _isLoading ? null : _save,
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2)
                      : const Text('저장하기',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          )),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title,
    style: const TextStyle(
      fontSize: 13, fontWeight: FontWeight.w600,
      color: AppColors.accent, letterSpacing: 0.5,
    ));

  Widget _fieldLabel(String label) => Text(label,
    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary));

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    String? suffix,
    String? hint,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            suffixText: suffix,
            suffixStyle: const TextStyle(
              color: AppColors.textSecondary, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

//토글 행
class _ToggleRow extends StatelessWidget {
  final List<String> options;
  final int selected;
  final void Function(int) onChanged;
  const _ToggleRow({
    required this.options,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgPrimary,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      padding: const EdgeInsets.all(3),
      child: Row(
        children: List.generate(options.length, (i) {
          final sel = selected == i;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                height: 36,
                decoration: BoxDecoration(
                  color: sel ? AppColors.bgSecondary : Colors.transparent,
                  borderRadius: BorderRadius.circular(7),
                  border: sel
                      ? Border.all(color: AppColors.bgTertiary, width: 0.5)
                      : null,
                ),
                child: Center(
                  child: Text(options[i],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w600 : FontWeight.w400,
                      color: sel ? AppColors.accent : AppColors.textSecondary,
                    )),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

//운동 스피너
class _ExerciseSpinner extends StatelessWidget {
  final int value;
  final void Function(int) onChanged;
  const _ExerciseSpinner({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Row(
        children: [
          _SpinBtn(icon: Icons.remove, enabled: value > 0,
            onTap: () => onChanged(value - 1)),
          Container(width: 0.5, height: 48, color: AppColors.bgTertiary),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('$value',
                  style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                const Text('회 / 주',
                  style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
              ],
            ),
          ),
          Container(width: 0.5, height: 48, color: AppColors.bgTertiary),
          _SpinBtn(icon: Icons.add, enabled: value < 7,
            onTap: () => onChanged(value + 1)),
        ],
      ),
    );
  }
}

class _SpinBtn extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  const _SpinBtn({required this.icon, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: SizedBox(
        width: 52, height: 52,
        child: Icon(icon, size: 22,
          color: enabled ? AppColors.textSecondary : AppColors.bgTertiary),
      ),
    );
  }
}
