// lib/features/insight/presentation/insight_screen.dart
// Tab 3: 위험군 인사이트 (ML 모델 + SHAP 피드백)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/dio_client.dart';
import '../../../shared/widgets/common_widgets.dart';
import '../../health_profile/provider/health_profile_provider.dart';
import '../../health_profile/presentation/health_input_screen.dart';

// 예측 결과 Provider (탭 내부 독립)
final _insightProvider =
AsyncNotifierProvider.autoDispose<_InsightNotifier, Map<String, dynamic>?>(
  _InsightNotifier.new,
);

class _InsightNotifier
    extends AutoDisposeAsyncNotifier<Map<String, dynamic>?> {
  @override
  Future<Map<String, dynamic>?> build() async => null;

  Future<void> predict(Map<String, dynamic> input) async {
    state = const AsyncLoading();
    try {
      final res =
      await DioClient.instance.post('/api/predict', data: input);
      state = AsyncData(res.data as Map<String, dynamic>);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
    }
  }
}

class InsightScreen extends ConsumerWidget {
  const InsightScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(healthProfileProvider);
    final insightAsync = ref.watch(_insightProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('위험군 인사이트'),
        bottom: const AppBarDivider(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InfoCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('AI 당뇨 위험군 분석',
                      style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      )),
                  SizedBox(height: 6),
                  Text(
                      '건강정보 탭에 입력된 데이터를 기반으로\nLightGBM 모델이 위험군을 분석합니다.',
                      style: TextStyle(
                        fontSize: 12, color: AppColors.textSecondary,
                        height: 1.6,
                      )),
                ],
              ),
            ),
            const SizedBox(height: 16),

            profileAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => _NoProfileCard(),
              data: (profile) => profile == null
                  ? _NoProfileCard()
                  : _ProfileSummaryCard(profile: profile),
            ),
            const SizedBox(height: 16),

            //건강정보 최신화 버튼
            profileAsync.when(
              loading: () => const SizedBox.shrink(),
              error:   (_, __) => const SizedBox.shrink(),
              data: (profile) => OutlinedButton.icon(
                onPressed: () {
                  // Tab 4 건강정보 탭으로 이동
                  // MainShell의 index를 3으로 변경
                  final scaffold = Scaffold.of(context);
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const HealthInputScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('건강 정보 최신화 하기',
                    style: TextStyle(fontSize: 13)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(
                      color: AppColors.bgTertiary, width: 0.5),
                  minimumSize: const Size(double.infinity, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            const SizedBox(height: 12),

            //분석하기 버튼
            profileAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
              data: (profile) => profile == null
                  ? const SizedBox.shrink()
                  : GradientButton(
                label: '위험군 분석하기',
                isLoading: insightAsync.isLoading,
                onTap: () {
                  final input = _buildInput(profile);
                  ref.read(_insightProvider.notifier).predict(input);
                },
              ),
            ),
            const SizedBox(height: 16),

            //예측 결과
            insightAsync.when(
              loading: () => const Center(
                  child: CircularProgressIndicator(color: AppColors.accent)),
              error: (e, _) => InfoCard(
                child: Text('분석 실패: $e',
                    style: const TextStyle(
                        color: AppColors.riskHigh, fontSize: 12)),
              ),
              data: (result) => result == null
                  ? const SizedBox.shrink()
                  : _ResultSection(result: result),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _buildInput(dynamic p) => {
    'age':            p.age,
    'sex':            p.gender == '남' ? 1 : 2,
    'HE_ht':          p.heightCm,
    'HE_wt':          p.weightKg,
    'HE_wc':          p.waistCm,
    'HE_HbA1c':       p.hba1c,
    'HE_sbp':         p.systolicBp,
    'HE_dbp':         p.diastolicBp,
    'BS1_1':          p.smoking == 0 ? 2 : (p.smoking == 2 ? 1 : 3),
    'BD1_11':         p.drinkFrequency,
    'BD2_1':          p.drinkAmount,
    'pa_aerobic':     p.exercisePerWeek >= 3 ? 1 : 0,
    'L_BR_FQ':        p.breakfastFreq,
    'L_LN_FQ':        p.lunchFreq,
    'L_DN_FQ':        p.dinnerFreq,
    'N_EN':           p.dailyCalories,
    'N_CHO':          p.dailyCarbs,
    'N_SUGAR':        p.dailySugar,
    'HE_DMfh1':       p.familyHistory ? 1 : 0,
    'HE_DMfh2':       p.familyHistory ? 1 : 0,
    'HE_DMfh3':       p.familyHistory ? 1 : 0,
    'DI1_dg':         p.hypertension ? 1 : 0,
    'DI2_dg':         p.dyslipidemia ? 1 : 0,
    'HE_HP':          p.hypertension ? 1 : 0,
    'fasting_glucose': p.fastingGlucose,
  };
}

//결과 전체 섹션
class _ResultSection extends StatelessWidget {
  final Map<String, dynamic> result;
  const _ResultSection({required this.result});

  @override
  Widget build(BuildContext context) {
    final labelKo    = result['label_ko'] as String;
    final modelUsed  = result['model_used'] as String;
    final probs      = result['probabilities'] as Map<String, dynamic>;
    final riskDetail = result['risk_detail'] as String?;
    final shapList   = result['shap_feedback'] as List?;

    return Column(
      children: [
        // 위험군 결과 카드
        _RiskResultCard(
          labelKo:   labelKo,
          modelUsed: modelUsed,
        ),
        const SizedBox(height: 10),

        // 확률 바
        InfoCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionTitle('분류 확률'),
              const SizedBox(height: 12),
              ...probs.entries.map((e) => _ProbBar(
                label: _labelKo(e.key),
                prob:  (e.value as num).toDouble(),
              )),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // SHAP 영향 요인
        if (shapList != null && shapList.isNotEmpty) ...[
          InfoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionTitle('위험도 영향 요인 (SHAP)'),
                const SizedBox(height: 4),
                const Text(
                  '수치가 클수록 위험도에 더 많은 영향을 줍니다',
                  style: TextStyle(
                      fontSize: 10, color: AppColors.textTertiary),
                ),
                const SizedBox(height: 12),
                ...shapList.map((item) => _ShapBar(
                  label:     item['label'] as String,
                  value:     item['value'],
                  shap:      (item['shap'] as num).toDouble(),
                  direction: item['direction'] as String,
                )),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Legend(color: AppColors.riskHigh,  label: '위험 증가'),
                    const SizedBox(width: 16),
                    _Legend(color: AppColors.riskLow,   label: '위험 감소'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        if (riskDetail != null)
          InfoCard(
            child: Row(
              children: [
                const Icon(Icons.bloodtype,
                    color: AppColors.accent, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('공복혈당 세부 판정',
                          style: TextStyle(
                              fontSize: 10, color: AppColors.textTertiary)),
                      Text(riskDetail,
                          style: const TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 10),

        // 면책 조항
        const InfoCard(
          child: Text(
            '⚠️ 이 결과는 의료 진단을 대체하지 않습니다.\n정확한 진단은 전문의와 상담하세요.',
            style: TextStyle(
                fontSize: 11, color: AppColors.textTertiary, height: 1.6),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  String _labelKo(String en) => switch (en) {
    'Diabetes'     => '당뇨',
    'Pre-diabetes' => '당뇨 전단계',
    _              => '정상',
  };
}

//위험군 결과 카드
class _RiskResultCard extends StatelessWidget {
  final String labelKo;
  final String modelUsed;
  const _RiskResultCard({required this.labelKo, required this.modelUsed});

  Color get _color => switch (labelKo) {
    '당뇨'       => AppColors.riskHigh,
    '당뇨 전단계' => AppColors.riskMedium,
    _            => AppColors.riskLow,
  };

  String get _icon => switch (labelKo) {
    '당뇨'       => '⚠️',
    '당뇨 전단계' => '⚡',
    _            => '✅',
  };

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        children: [
          Text(_icon, style: const TextStyle(fontSize: 44)),
          const SizedBox(height: 8),
          Text(labelKo,
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: _color)),
          const SizedBox(height: 6),
          StatusBadge.risk(labelKo),
          const SizedBox(height: 8),
          Text(
              modelUsed == 'full'
                  ? '검진수치 포함 Full Model 적용'
                  : '일상변수 기반 Base Model 적용',
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

//SHAP 바
class _ShapBar extends StatelessWidget {
  final String label;
  final dynamic value;
  final double shap;
  final String direction;
  const _ShapBar({
    required this.label,
    required this.value,
    required this.shap,
    required this.direction,
  });

  @override
  Widget build(BuildContext context) {
    final isPos  = shap >= 0;
    final color  = isPos ? AppColors.riskHigh : AppColors.riskLow;
    final maxVal = 8.0;
    final ratio  = (shap.abs() / maxVal).clamp(0.0, 1.0);
    final valStr = value != null ? value.toString() : '-';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 90,
                child: Text(label,
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.textSecondary)),
              ),
              const SizedBox(width: 4),
              Text('($valStr)',
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: ratio,
                      child: Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 52,
                child: Text(
                  '${isPos ? '+' : ''}${shap.toStringAsFixed(3)}',
                  style: TextStyle(
                      fontSize: 10, fontWeight: FontWeight.w600,
                      color: color),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

//확률 바
class _ProbBar extends StatelessWidget {
  final String label;
  final double prob;
  const _ProbBar({required this.label, required this.prob});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: prob,
                backgroundColor: AppColors.bgTertiary,
                valueColor: AlwaysStoppedAnimation(
                    prob > 0.6 ? AppColors.accent : AppColors.textTertiary),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('${(prob * 100).toStringAsFixed(1)}%',
              style: const TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}

//등록된 프로필 존재 X
class _NoProfileCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const InfoCard(
      child: Column(
        children: [
          Icon(Icons.person_outline, size: 36, color: AppColors.textTertiary),
          SizedBox(height: 8),
          Text('건강 정보를 먼저 입력해주세요',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          SizedBox(height: 4),
          Text('건강정보 탭에서 입력할 수 있습니다',
              style: TextStyle(fontSize: 11, color: AppColors.textTertiary)),
        ],
      ),
    );
  }
}

// 프로필 요약
class _ProfileSummaryCard extends StatelessWidget {
  final dynamic profile;
  const _ProfileSummaryCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle('입력 데이터 요약'),
          const SizedBox(height: 12),
          Wrap(
            spacing: 16, runSpacing: 8,
            children: [
              _StatChip('나이', '${profile.age}세'),
              _StatChip('BMI', '${profile.bmi.toStringAsFixed(1)}'),
              _StatChip('공복혈당',
                  profile.fastingGlucose != null
                      ? '${profile.fastingGlucose} mg/dL' : '미입력'),
              _StatChip('HbA1c',
                  profile.hba1c != null ? '${profile.hba1c}%' : '미입력'),
              _StatChip('운동', '주 ${profile.exercisePerWeek}회'),
              _StatChip('흡연',
                  ['비흡연', '과거흡연', '현재흡연'][profile.smoking]),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  const _StatChip(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 9, color: AppColors.textTertiary)),
        Text(value,
            style: const TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600,
                color: AppColors.textPrimary)),
      ],
    );
  }
}

//범례
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
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                fontSize: 10, color: AppColors.textTertiary)),
      ],
    );
  }
}