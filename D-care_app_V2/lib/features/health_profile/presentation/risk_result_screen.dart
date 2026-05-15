// lib/features/health_profile/presentation/risk_result_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../main.dart';

class RiskResultScreen extends StatelessWidget {
  final String riskLevel;           // 고위험 | 중위험 | 저위험
  final Map<String, double> shapValues; // SHAP 변수 영향도

  const RiskResultScreen({
    super.key,
    required this.riskLevel,
    required this.shapValues,
  });

  // ── 위험군별 색상/아이콘 ──────────────────────────────────
  Color get _riskColor => switch (riskLevel) {
    '고위험' => AppColors.riskHigh,
    '중위험' => AppColors.riskMedium,
    _       => AppColors.riskLow,
  };

  Color get _riskBgColor => switch (riskLevel) {
    '고위험' => AppColors.riskHighBg,
    '중위험' => AppColors.riskMediumBg,
    _       => AppColors.riskLowBg,
  };

  String get _riskIcon => switch (riskLevel) {
    '고위험' => '⚠️',
    '중위험' => '⚡',
    _       => '✅',
  };

  String get _riskDescription => switch (riskLevel) {
    '고위험' => '즉각적인 의료 상담을 권장합니다.\n혈당 모니터링과 생활습관 개선이 시급합니다.',
    '중위험' => '정기적인 혈당 체크와\n식이·운동 관리가 필요합니다.',
    _       => '현재 상태를 유지하며\n예방적 관리를 지속하세요.',
  };

  @override
  Widget build(BuildContext context) {
    // SHAP 값 절댓값 기준 내림차순 정렬
    final sortedShap = shapValues.entries.toList()
      ..sort((a, b) => b.value.abs().compareTo(a.value.abs()));

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('위험군 분석 결과'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── 위험군 결과 카드 ───────────────────────────
            _RiskResultCard(
              riskLevel: riskLevel,
              riskColor: _riskColor,
              riskBgColor: _riskBgColor,
              riskIcon: _riskIcon,
              description: _riskDescription,
            ),
            const SizedBox(height: 20),

            // ── SHAP 변수 영향도 ───────────────────────────
            if (shapValues.isNotEmpty) ...[
              _SectionTitle(title: '위험도 영향 요인 분석'),
              const SizedBox(height: 12),
              ...sortedShap.map((e) => _ShapBar(
                label: _labelKor(e.key),
                value: e.value,
                maxValue: sortedShap.first.value.abs(),
              )),
              const SizedBox(height: 8),
              // 범례
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _Legend(color: AppColors.riskHigh, label: '위험 증가'),
                  const SizedBox(width: 16),
                  _Legend(color: AppColors.riskLow, label: '위험 감소'),
                ],
              ),
            ],
            const SizedBox(height: 20),

            // ── 권고 사항 ──────────────────────────────────
            _RecommendCard(riskLevel: riskLevel),
            const SizedBox(height: 32),

            // ── 시작하기 버튼 ──────────────────────────────
            _GradientButton(
              label: '챗봇과 상담 시작하기',
              onTap: () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const MainShell()),
                (_) => false,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '이 결과는 의료 진단을 대체하지 않습니다.\n정확한 진단은 반드시 전문의와 상담하세요.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: AppColors.textTertiary, height: 1.6),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // 변수명 한글 변환
  String _labelKor(String key) => switch (key) {
    'fasting_glucose'     => '공복혈당',
    'hba1c'               => 'HbA1c',
    'bmi'                 => 'BMI',
    'systolic_bp'         => '수축기혈압',
    'diastolic_bp'        => '이완기혈압',
    'exercise'            => '운동횟수',
    'smoking'             => '흡연',
    'family_history'      => '가족력',
    'postprandial_glucose'=> '식후혈당',
    _                     => key,
  };
}

// ── 위험군 결과 카드 ───────────────────────────────────────────
class _RiskResultCard extends StatelessWidget {
  final String riskLevel, riskIcon, description;
  final Color riskColor, riskBgColor;

  const _RiskResultCard({
    required this.riskLevel,
    required this.riskColor,
    required this.riskBgColor,
    required this.riskIcon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.4), width: 1.5),
      ),
      child: Column(
        children: [
          Text(riskIcon, style: const TextStyle(fontSize: 48)),
          const SizedBox(height: 12),
          Text(riskLevel,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: riskColor,
            )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: riskBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text('AI 모델 분석 결과',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: riskColor,
              )),
          ),
          const SizedBox(height: 16),
          Text(description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13, color: AppColors.textSecondary, height: 1.6,
            )),
        ],
      ),
    );
  }
}

// ── SHAP 영향도 바 ─────────────────────────────────────────────
class _ShapBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;

  const _ShapBar({
    required this.label,
    required this.value,
    required this.maxValue,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = value >= 0; // 양수 = 위험 증가
    final ratio = maxValue > 0 ? value.abs() / maxValue : 0.0;
    final barColor = isPositive ? AppColors.riskHigh : AppColors.riskLow;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
              style: const TextStyle(
                fontSize: 11, color: AppColors.textSecondary,
              )),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Stack(
              children: [
                Container(
                  height: 24,
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: ratio,
                  child: Container(
                    height: 24,
                    decoration: BoxDecoration(
                      color: barColor.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 48,
            child: Text(
              '${isPositive ? '+' : ''}${value.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w600, color: barColor,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 권고 사항 카드 ─────────────────────────────────────────────
class _RecommendCard extends StatelessWidget {
  final String riskLevel;
  const _RecommendCard({required this.riskLevel});

  List<String> get _recommendations => switch (riskLevel) {
    '고위험' => [
      '즉시 전문의 상담을 받으세요',
      '공복혈당을 매일 측정하세요',
      '당질 섭취를 엄격히 제한하세요',
      '주 5회 이상 유산소 운동을 하세요',
      '3개월 내 HbA1c 재검사를 받으세요',
    ],
    '중위험' => [
      '3~6개월마다 혈당 검사를 받으세요',
      '주 3회 이상 30분 유산소 운동을 하세요',
      '정제 탄수화물 섭취를 줄이세요',
      '표준 체중을 유지하세요',
      '금연 및 절주를 실천하세요',
    ],
    _ => [
      '현재의 건강한 생활습관을 유지하세요',
      '연 1회 정기 혈당 검사를 받으세요',
      '규칙적인 운동을 지속하세요',
      '균형 잡힌 식단을 유지하세요',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('권고 사항',
            style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            )),
          const SizedBox(height: 12),
          ..._recommendations.map((r) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.check_circle_outline,
                  size: 14, color: AppColors.accent),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(r,
                    style: const TextStyle(
                      fontSize: 12, color: AppColors.textSecondary, height: 1.5,
                    )),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}

// ── 섹션 타이틀 ───────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title,
        style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600,
          color: AppColors.accent, letterSpacing: 0.5,
        )),
    );
  }
}

// ── 범례 ──────────────────────────────────────────────────────
class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10, height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
          style: const TextStyle(fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}

//버튼 디자인
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
              blurRadius: 12, offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(label,
            style: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white,
            )),
        ),
      ),
    );
  }
}
