// lib/features/health_profile/presentation/health_input_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../provider/health_profile_provider.dart';
import '../../auth/provider/auth_provider.dart';
import '../../auth/presentation/login_screen.dart';

class HealthInputScreen extends ConsumerStatefulWidget {
  const HealthInputScreen({super.key});

  @override
  ConsumerState<HealthInputScreen> createState() => _HealthInputScreenState();
}

class _HealthInputScreenState extends ConsumerState<HealthInputScreen> {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  bool _isSaving = false;

  //건강정보 1페이지: 기본 신체정보
  final _ageCtrl    = TextEditingController();
  int _gender       = 0; // 0=남, 1=여
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _waistCtrl  = TextEditingController();
  double? _bmi;

  //건강정보 2페이지: 혈당 / 혈압
  final _fastingCtrl       = TextEditingController();
  final _postprandialCtrl  = TextEditingController();
  final _hba1cCtrl         = TextEditingController();
  final _systolicCtrl      = TextEditingController();
  final _diastolicCtrl     = TextEditingController();

  //건강정보 3페이지: 진단 이력
  bool _hypertension = false;
  bool _dyslipidemia = false;
  // 이상지질혈증 증상 체크리스트
  final List<String> _dyslipidemiaSymptoms = [
    '콜레스테롤 수치가 높다고 들었어요',
    '중성지방 수치가 높다고 들었어요',
    '이상지질혈증 진단을 받은 적 있어요',
    '혈관 관련 약을 복용 중이에요',
  ];
  final Set<int> _selectedSymptoms = {};

  // 가족력 (부/모/형제자매 개별)
  bool _famFather   = false;
  bool _famMother   = false;
  bool _famSibling  = false;

  //건강정보 4페이지: 생활습관
  int _smoking         = 0; // 0=비흡연, 1=과거, 2=현재
  int _exercisePerWeek = 0;
  final _drinkFreqCtrl   = TextEditingController();
  final _drinkAmountCtrl = TextEditingController();

  //건강정보 5페이지: 식사 / 영양
  double _breakfastFreq = 0;
  double _lunchFreq     = 0;
  double _dinnerFreq    = 0;
  final _caloriesCtrl = TextEditingController();
  final _carbsCtrl    = TextEditingController();
  final _sugarCtrl    = TextEditingController();

  @override
  void dispose() {
    _pageCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _waistCtrl.dispose();
    _fastingCtrl.dispose();
    _postprandialCtrl.dispose();
    _hba1cCtrl.dispose();
    _systolicCtrl.dispose();
    _diastolicCtrl.dispose();
    _drinkFreqCtrl.dispose();
    _drinkAmountCtrl.dispose();
    _caloriesCtrl.dispose();
    _carbsCtrl.dispose();
    _sugarCtrl.dispose();
    super.dispose();
  }

  //BMI 자동 계산
  void _calcBmi() {
    final h = double.tryParse(_heightCtrl.text);
    final w = double.tryParse(_weightCtrl.text);
    if (h != null && w != null && h > 0) {
      setState(() => _bmi = w / ((h / 100) * (h / 100)));
    }
  }

  //페이지 이동
  void _next() {
    if (_currentPage < 4) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prev() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  //로그아웃
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('로그아웃',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        content: const Text('로그아웃 하시겠습니까?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) => const LoginScreen(),
                    transitionsBuilder: (_, anim, __, child) =>
                        FadeTransition(opacity: anim, child: child),
                    transitionDuration: const Duration(milliseconds: 400),
                  ),
                      (route) => false,
                );
              }
            },
            child: const Text('로그아웃',
                style: TextStyle(color: AppColors.riskHigh)),
          ),
        ],
      ),
    );
  }

  //최종 저장
  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(healthProfileProvider.notifier).saveProfile({
        // 신체 스펙
        'age':       int.tryParse(_ageCtrl.text),
        'gender':    _gender == 0 ? '남' : '여',
        'height_cm': double.tryParse(_heightCtrl.text),
        'weight_kg': double.tryParse(_weightCtrl.text),
        'waist_cm':  double.tryParse(_waistCtrl.text),
        // 혈당 / 혈압
        'fasting_glucose':      double.tryParse(_fastingCtrl.text),
        'postprandial_glucose': double.tryParse(_postprandialCtrl.text),
        'hba1c':                double.tryParse(_hba1cCtrl.text),
        'systolic_bp':          double.tryParse(_systolicCtrl.text),
        'diastolic_bp':         double.tryParse(_diastolicCtrl.text),
        // 병원 진단 이력
        'hypertension':  _hypertension,
        'dyslipidemia':  _dyslipidemia || _selectedSymptoms.isNotEmpty,
        'family_history': _famFather || _famMother || _famSibling,
        // 생활 습관
        'smoking':            _smoking,
        'exercise_per_week':  _exercisePerWeek,
        'drink_frequency':    double.tryParse(_drinkFreqCtrl.text),
        'drink_amount':       double.tryParse(_drinkAmountCtrl.text),
        // 식사 / 영양
        'breakfast_freq': _breakfastFreq,
        'lunch_freq':     _lunchFreq,
        'dinner_freq':    _dinnerFreq,
        'daily_calories': double.tryParse(_caloriesCtrl.text),
        'daily_carbs':    double.tryParse(_carbsCtrl.text),
        'daily_sugar':    double.tryParse(_sugarCtrl.text),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('건강 정보가 저장되었습니다'),
            backgroundColor: Color(0xFF1E293B),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 실패: $e'),
            backgroundColor: AppColors.riskHigh,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('건강 정보 입력 ${_currentPage + 1} / 5'),
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18),
          onPressed: _prev,
        )
            : null,
        actions: [
          Text('${_currentPage + 1} / 5',
              style: const TextStyle(
                  color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.close, size: 18),
            color: AppColors.textSecondary,
            onPressed: () => _showLogoutDialog(context),
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_currentPage + 1) / 5,
            backgroundColor: AppColors.bgTertiary,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 4,
          ),
        ),
      ),
      body: PageView(
        controller: _pageCtrl,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _currentPage = i),
        children: [
          _Page1(this),
          _Page2(this),
          _Page3(this),
          _Page4(this),
          _Page5(this),
        ],
      ),
    );
  }
}


//기본 신체정보 페이지 쉘
class _Page1 extends StatelessWidget {
  final _HealthInputScreenState s;
  const _Page1(this.s);

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: '기본 신체정보',
      onNext: s._next,
      child: Column(
        children: [
          // 나이 / 성별
          Row(children: [
            Expanded(
              child: LabeledField(
                label: '나이',
                child: _TextField(ctrl: s._ageCtrl, hint: '만 나이', unit: '세'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: '성별',
                child: ToggleGroup(
                  options: const ['남', '여'],
                  selected: s._gender,
                  onChanged: (i) => s.setState(() => s._gender = i),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // 키 / 몸무게
          Row(children: [
            Expanded(
              child: LabeledField(
                label: '키',
                child: _TextField(
                  ctrl: s._heightCtrl, hint: '신장', unit: 'cm',
                  onChanged: (_) => s._calcBmi(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: '몸무게',
                child: _TextField(
                  ctrl: s._weightCtrl, hint: '체중', unit: 'kg',
                  onChanged: (_) => s._calcBmi(),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          // BMI 자동계산
          _BmiCard(bmi: s._bmi),
          const SizedBox(height: 14),

          // 허리둘레
          LabeledField(
            label: '허리둘레 (선택)',
            child: _TextField(
              ctrl: s._waistCtrl,
              hint: '복부비만 기준  남 ≥90 / 여 ≥85',
              unit: 'cm',
            ),
          ),
        ],
      ),
    );
  }
}

//혈당 / 혈압 페이지쉘
class _Page2 extends StatelessWidget {
  final _HealthInputScreenState s;
  const _Page2(this.s);

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: '혈당 수치 및 혈압',
      subtitle: '검진 수치가 있으면 입력하세요 (선택)',
      onNext: s._next,
      child: Column(
        children: [
          const SectionTitle('혈당'),
          const SizedBox(height: 8),
          LabeledField(label: '공복혈당',
              child: _TextField(ctrl: s._fastingCtrl, hint: '정상 < 100', unit: 'mg/dL')),
          const SizedBox(height: 10),
          LabeledField(label: '식후 2시간 혈당',
              child: _TextField(ctrl: s._postprandialCtrl, hint: '정상 < 140', unit: 'mg/dL')),
          const SizedBox(height: 10),
          LabeledField(label: '당화혈색소 (HbA1c)',
              child: _TextField(ctrl: s._hba1cCtrl, hint: '정상 < 5.7', unit: '%')),
          const SizedBox(height: 18),

          const SectionTitle('혈압'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: LabeledField(label: '수축기',
                  child: _TextField(ctrl: s._systolicCtrl, hint: '예) 120', unit: 'mmHg')),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(label: '이완기',
                  child: _TextField(ctrl: s._diastolicCtrl, hint: '예) 80', unit: 'mmHg')),
            ),
          ]),
          const SizedBox(height: 10),
          _InfoBox(text: '혈압계가 없으면 비워두셔도 됩니다'),
        ],
      ),
    );
  }
}

//진단 이력 페이지 쉘
class _Page3 extends StatelessWidget {
  final _HealthInputScreenState s;
  const _Page3(this.s);

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: '진단 이력',
      onNext: s._next,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 고혈압
          const SectionTitle('고혈압'),
          const SizedBox(height: 8),
          _ToggleCard(
            label: '고혈압 진단을 받은 적 있나요?',
            value: s._hypertension,
            onChanged: (v) => s.setState(() => s._hypertension = v),
          ),
          const SizedBox(height: 18),

          // 이상지질혈증
          const SectionTitle('이상지질혈증'),
          const SizedBox(height: 8),
          ...s._dyslipidemiaSymptoms.asMap().entries.map((e) =>
              _CheckItem(
                label: e.value,
                checked: s._selectedSymptoms.contains(e.key),
                onChanged: (v) => s.setState(() {
                  if (v) {
                    s._selectedSymptoms.add(e.key);
                    s._dyslipidemia = true;
                  } else {
                    s._selectedSymptoms.remove(e.key);
                    if (s._selectedSymptoms.isEmpty) s._dyslipidemia = false;
                  }
                }),
              ),
          ),
          const SizedBox(height: 18),

          // 가족력
          const SectionTitle('당뇨 가족력'),
          const SizedBox(height: 8),
          _ToggleCard(
            label: '부(아버지)',
            value: s._famFather,
            onChanged: (v) => s.setState(() => s._famFather = v),
          ),
          const SizedBox(height: 6),
          _ToggleCard(
            label: '모(어머니)',
            value: s._famMother,
            onChanged: (v) => s.setState(() => s._famMother = v),
          ),
          const SizedBox(height: 6),
          _ToggleCard(
            label: '형제 / 자매',
            value: s._famSibling,
            onChanged: (v) => s.setState(() => s._famSibling = v),
          ),
        ],
      ),
    );
  }
}


//생활습관 페이지쉘
class _Page4 extends StatelessWidget {
  final _HealthInputScreenState s;
  const _Page4(this.s);

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: '생활습관',
      onNext: s._next,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 흡연
          const SectionTitle('흡연'),
          const SizedBox(height: 8),
          ToggleGroup(
            options: const ['비흡연', '과거흡연', '현재흡연'],
            selected: s._smoking,
            onChanged: (i) => s.setState(() => s._smoking = i),
          ),
          const SizedBox(height: 18),

          // 주간 운동
          const SectionTitle('주간 운동 횟수'),
          const SizedBox(height: 8),
          SpinnerField(
            value: s._exercisePerWeek,
            min: 0, max: 7,
            unit: '회 / 주',
            onChanged: (v) => s.setState(() => s._exercisePerWeek = v),
          ),
          const SizedBox(height: 8),
          if (s._exercisePerWeek == 0)
            _WarningBox(text: '운동 부족 - 혈당 관리에 악영향'),
          const SizedBox(height: 18),

          // 음주
          const SectionTitle('음주 (선택)'),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: LabeledField(
                label: '음주 빈도',
                child: _TextField(
                    ctrl: s._drinkFreqCtrl, hint: '예) 4', unit: '회/월'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: '1회 음주량',
                child: _TextField(
                    ctrl: s._drinkAmountCtrl, hint: '예) 3', unit: '잔'),
              ),
            ),
          ]),
        ],
      ),
    );
  }
}

//식사 / 영양 페이지쉘
class _Page5 extends StatelessWidget {
  final _HealthInputScreenState s;
  const _Page5(this.s);

  @override
  Widget build(BuildContext context) {
    return _PageShell(
      title: '식사 및 영양',
      isLast: true,
      onSave: s._save,
      isSaving: s._isSaving,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 식사 빈도
          const SectionTitle('주간 식사 빈도'),
          const SizedBox(height: 8),
          _MealRow(
            label: '아침',
            value: s._breakfastFreq,
            onChanged: (v) => s.setState(() => s._breakfastFreq = v),
          ),
          const SizedBox(height: 8),
          _MealRow(
            label: '점심',
            value: s._lunchFreq,
            onChanged: (v) => s.setState(() => s._lunchFreq = v),
          ),
          const SizedBox(height: 8),
          _MealRow(
            label: '저녁',
            value: s._dinnerFreq,
            onChanged: (v) => s.setState(() => s._dinnerFreq = v),
          ),
          const SizedBox(height: 18),

          // 영양
          const SectionTitle('하루 영양 섭취 (선택)'),
          const SizedBox(height: 8),
          LabeledField(
            label: '칼로리',
            child: _TextField(
                ctrl: s._caloriesCtrl, hint: '하루 평균', unit: 'kcal'),
          ),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(
              child: LabeledField(
                label: '탄수화물',
                child: _TextField(ctrl: s._carbsCtrl, hint: '예) 250', unit: 'g'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: LabeledField(
                label: '당류',
                child: _TextField(ctrl: s._sugarCtrl, hint: '예) 50', unit: 'g'),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          _InfoBox(text: '영양 수치가 없으면 비워두셔도 됩니다'),
        ],
      ),
    );
  }
}

//---------------------------------------------공통 컴포넌트-----------------------------------------

// 페이지 래퍼
class _PageShell extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final VoidCallback? onNext;
  final VoidCallback? onSave;
  final bool isLast;
  final bool isSaving;

  const _PageShell({
    required this.title,
    required this.child,
    this.subtitle,
    this.onNext,
    this.onSave,
    this.isLast = false,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700,
                      color: AppColors.accent,
                    )),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(subtitle!,
                      style: const TextStyle(
                          fontSize: 12, color: AppColors.textSecondary)),
                ],
                const SizedBox(height: 20),
                child,
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: GradientButton(
            label: isLast ? '저장하기' : '다음 →',
            isLoading: isSaving,
            onTap: isLast ? onSave : onNext,
          ),
        ),
      ],
    );
  }
}

// 텍스트 입력 필드
class _TextField extends StatelessWidget {
  final TextEditingController ctrl;
  final String hint;
  final String unit;
  final void Function(String)? onChanged;

  const _TextField({
    required this.ctrl,
    required this.hint,
    required this.unit,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
            color: AppColors.textTertiary, fontSize: 12),
        suffixText: unit,
        suffixStyle: const TextStyle(
            color: AppColors.textSecondary, fontSize: 12),
      ),
    );
  }
}

// BMI 카드
class _BmiCard extends StatelessWidget {
  final double? bmi;
  const _BmiCard({this.bmi});

  String get _label {
    if (bmi == null) return '-';
    if (bmi! < 18.5) return '저체중';
    if (bmi! < 23.0) return '정상';
    if (bmi! < 25.0) return '과체중';
    return '비만';
  }

  Color get _color {
    if (bmi == null) return AppColors.textTertiary;
    if (bmi! < 23.0) return AppColors.riskLow;
    if (bmi! < 25.0) return AppColors.riskMedium;
    return AppColors.riskHigh;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Row(
        children: [
          const Text('BMI (자동계산)',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            bmi != null ? '${bmi!.toStringAsFixed(1)}  $_label' : '- -',
            style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600, color: _color),
          ),
        ],
      ),
    );
  }
}

// 토글 카드
class _ToggleCard extends StatelessWidget {
  final String label;
  final bool value;
  final void Function(bool) onChanged;
  const _ToggleCard({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Row(
        children: [
          Text(label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

// 체크박스 항목
class _CheckItem extends StatelessWidget {
  final String label;
  final bool checked;
  final void Function(bool) onChanged;
  const _CheckItem({required this.label, required this.checked, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!checked),
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: checked ? AppColors.bgSecondary : AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: checked ? AppColors.accent : AppColors.bgTertiary,
            width: checked ? 1.2 : 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked ? Icons.check_circle : Icons.circle_outlined,
              size: 18,
              color: checked ? AppColors.accent : AppColors.textTertiary,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 13,
                    color: checked ? AppColors.textPrimary : AppColors.textSecondary,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// 식사 빈도 행
class _MealRow extends StatelessWidget {
  final String label;
  final double value;
  final void Function(double) onChanged;
  const _MealRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(label,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary)),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: 0, max: 7,
            divisions: 7,
            activeColor: AppColors.accent,
            inactiveColor: AppColors.bgTertiary,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 48,
          child: Text('주 ${value.toInt()}회',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12, color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

// 경고 박스
class _WarningBox extends StatelessWidget {
  final String text;
  const _WarningBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.riskHigh.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.riskHigh.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, size: 14, color: AppColors.riskHigh),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(fontSize: 11, color: AppColors.riskHigh)),
        ],
      ),
    );
  }
}

// 안내 박스
class _InfoBox extends StatelessWidget {
  final String text;
  const _InfoBox({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, size: 14, color: AppColors.accent),
          const SizedBox(width: 6),
          Expanded(
            child: Text(text,
                style: const TextStyle(fontSize: 11, color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}