// lib/features/dashboard/presentation/dashboard_screen.dart
import '../../chatbot/presentation/session_list_screen.dart';
import '../../../main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/storage/secure_storage.dart';
import '../../glucose/provider/glucose_provider.dart';
import '../../glucose/data/glucose_model.dart';
import '../../health_profile/provider/health_profile_provider.dart';
import '../../chatbot/provider/chat_provider.dart';
import '../../chatbot/data/message_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(healthProfileProvider);
    final statsAsync   = ref.watch(glucoseStatsProvider);

    // 위험군 배지
    final riskLabel = profileAsync.value?.lastRiskLabel;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('대시보드'),
        actions: [
          if (riskLabel != null)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _riskBg(riskLabel),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _riskColor(riskLabel), width: 0.5),
              ),
              child: Text(_riskIcon(riskLabel),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _riskTextColor(riskLabel),
                  )),
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0.5),
          child: Container(height: 0.5, color: AppColors.border),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.accent,
        onRefresh: () async {
          ref.invalidate(glucoseStatsProvider);
          ref.invalidate(glucoseSidebarProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              //7일 통계 카드
              statsAsync.when(
                loading: () => const _StatsSkeleton(),
                error:   (e, _) => _ErrorCard(message: '통계 불러오기 실패'),
                data:    (stats) => _StatsCard(stats: stats),
              ),
              const SizedBox(height: 12),

              //혈당 기록 추가 버튼
              _AddGlucoseButton(),
              const SizedBox(height: 16),

              //최근 혈당 기록
              const Text('최근 혈당 기록',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 8),
              _RecentRecordsList(),
              const SizedBox(height: 20),

              const Text('최근 대화 기록',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.accent,
                    letterSpacing: 0.5,
                  )),
              const SizedBox(height: 8),
              _RecentChatList(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }



  Color _riskColor(String label) => switch (label) {
    '당뇨'       => AppColors.riskHigh,
    '당뇨 전단계' => AppColors.riskMedium,
    _            => AppColors.riskLow,
  };

  Color _riskBg(String label) => switch (label) {
    '당뇨'       => AppColors.riskHighBg,
    '당뇨 전단계' => AppColors.riskMediumBg,
    _            => AppColors.riskLowBg,
  };

  Color _riskTextColor(String label) => switch (label) {
    '당뇨'       => AppColors.riskHighText,
    '당뇨 전단계' => AppColors.riskMediumText,
    _            => AppColors.riskLowText,
  };

  String _riskIcon(String label) => switch (label) {
    '당뇨'       => '⚠️ $label',
    '당뇨 전단계' => '⚡ $label',
    _            => '✅ $label',
  };
}

//7일 통계 카드
class _StatsCard extends StatelessWidget {
  final Map<String, dynamic> stats;
  const _StatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final avg   = (stats['avg']   as num?)?.toDouble() ?? 0;
    final max   = (stats['max']   as num?)?.toDouble() ?? 0;
    final min   = (stats['min']   as num?)?.toDouble() ?? 0;
    final count = (stats['count'] as num?)?.toInt()    ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('7일 혈당 통계',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.accent,
              )),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatItem(label: '평균', value: '${avg.toStringAsFixed(1)}', unit: 'mg/dL'),
              _Divider(),
              _StatItem(label: '최고', value: '${max.toStringAsFixed(0)}', unit: 'mg/dL'),
              _Divider(),
              _StatItem(label: '최저', value: '${min.toStringAsFixed(0)}', unit: 'mg/dL'),
              _Divider(),
              _StatItem(label: '측정', value: '$count', unit: '회'),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  const _StatItem({required this.label, required this.value, required this.unit});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              )),
          Text(unit,
              style: const TextStyle(
                  fontSize: 9, color: AppColors.textTertiary)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
      width: 0.5, height: 40, color: AppColors.bgTertiary);
}

//혈당 추가 버튼
class _AddGlucoseButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddGlucoseButton> createState() => _AddGlucoseButtonState();
}

class _AddGlucoseButtonState extends ConsumerState<_AddGlucoseButton> {
  final _glucoseCtrl = TextEditingController();
  String _type = '공복';

  @override
  void dispose() {
    _glucoseCtrl.dispose();
    super.dispose();
  }

  void _showAddDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: const Text('혈당 기록 추가',
            style: TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _glucoseCtrl,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                labelText: '혈당 수치 (mg/dL)',
                labelStyle: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: ['공복', '식후2시간'].map((t) => Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _type = t),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _type == t
                          ? AppColors.accent.withOpacity(0.2)
                          : AppColors.bgTertiary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: _type == t
                              ? AppColors.accent
                              : Colors.transparent),
                    ),
                    child: Text(t,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: _type == t
                              ? AppColors.accent
                              : AppColors.textSecondary,
                        )),
                  ),
                ),
              )).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              final val = double.tryParse(_glucoseCtrl.text);
              if (val == null) return;
              await ref.read(glucoseSidebarProvider.notifier).addRecord(
                glucose:         val,
                measurementType: _type,
              );
              ref.invalidate(glucoseStatsProvider);
              if (mounted) Navigator.pop(context);
              _glucoseCtrl.clear();
            },
            child: const Text('저장',
                style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _showAddDialog,
      child: Container(
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          gradient: AppColors.accentGradient,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.add, color: Colors.white, size: 18),
              SizedBox(width: 6),
              Text('혈당 기록 추가',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

//최근 혈당 기록 목록
class _RecentRecordsList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarAsync = ref.watch(glucoseSidebarProvider);
    return sidebarAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.accent)),
      error: (e, _) => _ErrorCard(message: '기록 불러오기 실패'),
      data: (groups) {
        if (groups.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.bgSecondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('혈당 기록이 없습니다\n위 버튼으로 기록을 추가해보세요',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 13, color: AppColors.textTertiary, height: 1.6)),
            ),
          );
        }
        return Column(
          children: groups.map((g) => _DayGroupCard(group: g)).toList(),
        );
      },
    );
  }
}

class _DayGroupCard extends StatelessWidget {
  final DayGroup group;
  const _DayGroupCard({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(group.label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  )),
              const Spacer(),
              Text('평균 ${group.avgGlucose.toStringAsFixed(0)} mg/dL',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textTertiary)),
            ],
          ),
          const SizedBox(height: 8),
          ...group.records.map((r) => _RecordRow(record: r)),
        ],
      ),
    );
  }
}

class _RecordRow extends StatelessWidget {
  final GlucoseRecord record;
  const _RecordRow({required this.record});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.glucoseDot(record.status);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(record.measurementType,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary)),
          const SizedBox(width: 8),
          Text('${record.glucose.toStringAsFixed(0)} mg/dL',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.glucoseBg(record.status),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(record.status,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: AppColors.glucoseText(record.status),
                )),
          ),
          if (record.memo != null) ...[
            const SizedBox(width: 6),
            Expanded(
              child: Text(record.memo!,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 10, color: AppColors.textTertiary)),
            ),
          ],
        ],
      ),
    );
  }
}

//공통 위젯
class _StatsSkeleton extends StatelessWidget {
  const _StatsSkeleton();
  @override
  Widget build(BuildContext context) => Container(
    height: 80,
    decoration: BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(14),
    ),
    child: const Center(
        child: CircularProgressIndicator(color: AppColors.accent)),
  );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.bgSecondary,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(message,
        style: const TextStyle(
            color: AppColors.textTertiary, fontSize: 12)),
  );
}

//최근 대화 기록
class _RecentChatList extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatProvider);

    // 봇 메시지만, 최근 3개 (환영 메시지 제외)
    final recentBotMessages = chatState.messages
        .where((m) => !m.isUser)
        .where((m) => !m.text.startsWith('안녕하세요! 당뇨 관리 챗봇'))
        .toList()
        .reversed
        .take(3)
        .toList();

    if (recentBotMessages.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text(
            '아직 대화 기록이 없습니다\n챗봇과 대화를 시작해보세요',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 13, color: AppColors.textTertiary, height: 1.6),
          ),
        ),
      );
    }

    return Column(
      children: recentBotMessages
          .map((msg) => _ChatPreviewCard(msg: msg))
          .toList(),
    );
  }
}

class _ChatPreviewCard extends StatelessWidget {
  final Message msg;
  const _ChatPreviewCard({required this.msg});

  @override
  Widget build(BuildContext context) {
    final time =
        '${msg.createdAt.hour.toString().padLeft(2, '0')}:'
        '${msg.createdAt.minute.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SessionListScreen()),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 챗봇 아이콘
          Container(
            width: 28, height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.smart_toy_outlined,
                size: 15, color: AppColors.accent),
          ),
          const SizedBox(width: 10),
          // 메시지 내용
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  msg.text,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(time,
                        style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.textTertiary)),
                    const Spacer(),
                    const Icon(Icons.arrow_forward_ios,
                      size: 10, color: AppColors.textTertiary),
                   ],
                 )
               ],
             ),
           ),
         ],
        ),
      ),
    );
  }
}