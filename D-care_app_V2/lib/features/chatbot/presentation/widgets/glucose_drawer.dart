// lib/features/chatbot/presentation/widgets/glucose_drawer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../glucose/provider/glucose_provider.dart';
import '../../../glucose/data/glucose_model.dart';
import '../../../../core/constants/app_colors.dart';

class GlucoseDrawer extends ConsumerWidget {
  const GlucoseDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sidebarAsync = ref.watch(glucoseSidebarProvider);

    return Drawer(
      backgroundColor: AppColors.bgPrimary,
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            // 헤더
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          gradient: AppColors.accentGradient,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.bloodtype_rounded,
                          color: Colors.white, size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('혈당 기록',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              )),
                          Text('최근 30일',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textTertiary,
                              )),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 요약 카드
                  _SummaryCard(sidebarAsync: sidebarAsync),
                ],
              ),
            ),
            const Divider(color: AppColors.border, height: 1, thickness: 0.5),

            //날짜별 리스트
            Expanded(
              child: sidebarAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent, strokeWidth: 2,
                  ),
                ),
                error: (e, _) => Center(
                  child: Text('오류 발생: $e',
                      style: const TextStyle(
                        color: AppColors.textTertiary, fontSize: 12,
                      )),
                ),
                data: (days) => days.isEmpty
                    ? _EmptyState()
                    : ListView.builder(
                  padding: const EdgeInsets.only(top: 4),
                  itemCount: days.length,
                  itemBuilder: (_, i) =>
                      _DayGroupTile(dayGroup: days[i]),
                ),
              ),
            ),

            //기록 추가 버튼
            Padding(
              padding: const EdgeInsets.all(12),
              child: OutlinedButton.icon(
                onPressed: () => _showAddSheet(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('혈당 기록 추가',
                    style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(
                    color: AppColors.bgTertiary, width: 0.5,
                  ),
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _AddGlucoseSheet(),
    );
  }
}

//요약 카드
class _SummaryCard extends StatelessWidget {
  final AsyncValue sidebarAsync;
  const _SummaryCard({required this.sidebarAsync});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _Stat(label: '7일 평균', value: '121',
              unit: 'mg/dL', color: AppColors.riskMedium),
          const SizedBox(width: 16),
          _Stat(label: '측정 횟수', value: '12',
              unit: '회', color: AppColors.accent),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.riskMediumBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('⚡ 중위험',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.riskMediumText,
                )),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _Stat({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 9, color: AppColors.textTertiary,
            )),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                )),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(unit,
                  style: const TextStyle(
                    fontSize: 9, color: AppColors.textSecondary,
                  )),
            ),
          ],
        ),
      ],
    );
  }
}

//날짜 그룹 타일
class _DayGroupTile extends StatefulWidget {
  final DayGroup dayGroup;
  const _DayGroupTile({required this.dayGroup});

  @override
  State<_DayGroupTile> createState() => _DayGroupTileState();
}

class _DayGroupTileState extends State<_DayGroupTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.dayGroup.label == '오늘'; // 오늘은 기본 펼침
  }

  Color _dotColor(double avg) {
    if (avg < 110) return AppColors.glucoseNormal;
    if (avg < 140) return AppColors.glucoseWarning;
    return AppColors.glucoseDanger;
  }

  @override
  Widget build(BuildContext context) {
    final dot = _dotColor(widget.dayGroup.avgGlucose);

    return Column(
      children: [
        // 날짜 헤더
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16, vertical: 10,
            ),
            child: Row(
              children: [
                Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: dot, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.dayGroup.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: _expanded
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: _expanded
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
                Text(
                  '${widget.dayGroup.avgGlucose.toStringAsFixed(0)} avg',
                  style: TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w600, color: dot,
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // 펼쳐진 기록 상세
        AnimatedSize(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          child: _expanded
              ? Container(
            color: AppColors.bgSecondary,
            child: Column(
              children: widget.dayGroup.records
                  .map((r) => _RecordRow(record: r))
                  .toList(),
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }
}

//개별 기록 행
class _RecordRow extends StatelessWidget {
  final GlucoseRecord record;
  const _RecordRow({required this.record});

  ({Color bg, Color text}) _statusStyle(String status) {
    return switch (status) {
      '정상' => (bg: AppColors.riskLowBg, text: AppColors.riskLowText),
      '주의' => (bg: AppColors.riskMediumBg, text: AppColors.riskMediumText),
      _     => (bg: AppColors.riskHighBg, text: AppColors.riskHighText),
    };
  }

  @override
  Widget build(BuildContext context) {
    final s = _statusStyle(record.status);
    final timeStr = DateFormat('HH:mm').format(record.measuredAt);

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.bgPrimary,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.bgTertiary, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$timeStr · ${record.measurementType}',
                      style: const TextStyle(
                        fontSize: 10, color: AppColors.textTertiary,
                      )),
                  if (record.memo != null && record.memo!.isNotEmpty)
                    Text(record.memo!,
                        style: const TextStyle(
                          fontSize: 9, color: AppColors.textTertiary,
                        ),
                        overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            Text(
              record.glucose.toStringAsFixed(0),
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 6, vertical: 2,
              ),
              decoration: BoxDecoration(
                color: s.bg,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(record.status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: s.text,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

// 빈 상태
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.monitor_heart_outlined,
              size: 40, color: AppColors.bgTertiary),
          SizedBox(height: 12),
          Text('기록된 혈당이 없습니다',
              style: TextStyle(
                fontSize: 13, color: AppColors.textTertiary,
              )),
          SizedBox(height: 4),
          Text('아래 버튼으로 첫 기록을 추가하세요',
              style: TextStyle(
                fontSize: 11, color: AppColors.bgTertiary,
              )),
        ],
      ),
    );
  }
}

//혈당 추가 BottomSheet
class _AddGlucoseSheet extends ConsumerStatefulWidget {
  const _AddGlucoseSheet();

  @override
  ConsumerState<_AddGlucoseSheet> createState() => _AddGlucoseSheetState();
}

class _AddGlucoseSheetState extends ConsumerState<_AddGlucoseSheet> {
  final _controller = TextEditingController();

  //확정된 토글: 공복 / 식후2시간 2개만
  final _types = ['공복', '식후2시간'];
  int _selectedTypeIndex = 0;
  String? _memo;

  // 측정 유형별 안내 메시지
  final _hints = [
    '8시간 이상 금식 후 측정 · 정상 < 100 mg/dL',
    '식사 시작 후 2시간 뒤 측정 · 정상 < 140 mg/dL',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20, 16, 20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 36, height: 3,
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text('혈당 기록 추가',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              )),
          const SizedBox(height: 16),

          // 혈당 수치 입력
          const Text('혈당 수치',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              hintText: '000',
              hintStyle: const TextStyle(
                color: AppColors.bgTertiary, fontSize: 26,
              ),
              suffixText: 'mg/dL',
              suffixStyle: const TextStyle(
                color: AppColors.textSecondary, fontSize: 14,
              ),
              filled: true,
              fillColor: AppColors.bgPrimary,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.bgTertiary, width: 0.5,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(
                  color: AppColors.bgTertiary, width: 0.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          //토글 버튼 (공복 / 식후2시간)
          const Text('측정 유형',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.bgTertiary, width: 0.5),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: List.generate(_types.length, (i) {
                final selected = _selectedTypeIndex == i;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedTypeIndex = i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: 36,
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.bgSecondary
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(7),
                        border: selected
                            ? Border.all(
                            color: AppColors.bgTertiary, width: 0.5)
                            : null,
                      ),
                      child: Center(
                        child: Text(_types[i],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: selected
                                  ? AppColors.accent
                                  : AppColors.textSecondary,
                            )),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 8),

          // 측정 유형 안내
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.bgPrimary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.bgTertiary, width: 0.5),
            ),
            child: Row(
              children: [
                Container(
                  width: 5, height: 5,
                  decoration: const BoxDecoration(
                    color: AppColors.accent, shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _hints[_selectedTypeIndex],
                  style: const TextStyle(
                    fontSize: 10, color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // 메모
          const Text('메모 (선택)',
              style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          TextField(
            onChanged: (v) => _memo = v,
            style: const TextStyle(
              color: AppColors.textPrimary, fontSize: 13,
            ),
            decoration: const InputDecoration(
              hintText: '식사 내용, 운동 여부 등',
            ),
          ),
          const SizedBox(height: 20),

          // 저장 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: AppColors.accent,
                foregroundColor: Colors.white,
              ),
              child: const Text('저장',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    final glucose = double.tryParse(_controller.text);
    if (glucose == null) return;
    ref.read(glucoseSidebarProvider.notifier).addRecord(
      glucose: glucose,
      measurementType: _types[_selectedTypeIndex],
      memo: _memo,
    );
    Navigator.pop(context);
  }
}