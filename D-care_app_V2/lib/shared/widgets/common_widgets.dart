// lib/shared/widgets/common_widgets.dart
// 모든 공통 위젯을 한 파일에 통합
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

// ── 그라디언트 버튼 ────────────────────────────────────────
class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;

  const GradientButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 50,
        decoration: BoxDecoration(
          gradient: onTap != null
              ? AppColors.accentGradient
              : const LinearGradient(
                  colors: [AppColors.bgTertiary, AppColors.bgTertiary]),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
                )
              : Text(label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  )),
        ),
      ),
    );
  }
}

// ── 상태 배지 ─────────────────────────────────────────────
class StatusBadge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color text;

  const StatusBadge({
    super.key,
    required this.label,
    required this.bg,
    required this.text,
  });

  // 혈당 상태용 팩토리
  factory StatusBadge.glucose(String status) => StatusBadge(
    label: status,
    bg:    AppColors.glucoseBg(status),
    text:  AppColors.glucoseText(status),
  );

  // 위험군용 팩토리
  factory StatusBadge.risk(String riskLabel) {
    final style = switch (riskLabel) {
      '당뇨'      => (bg: AppColors.riskHighBg,   text: AppColors.riskHighText,   icon: '⚠️'),
      '당뇨 전단계' => (bg: AppColors.riskMediumBg, text: AppColors.riskMediumText, icon: '⚡'),
      _           => (bg: AppColors.riskLowBg,    text: AppColors.riskLowText,    icon: '✅'),
    };
    return StatusBadge(
      label: '${style.icon} $riskLabel',
      bg: style.bg,
      text: style.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: text,
        )),
    );
  }
}

// ── 섹션 타이틀 ───────────────────────────────────────────
class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});

  @override
  Widget build(BuildContext context) => Text(title,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.accent,
      letterSpacing: 0.5,
    ));
}

// ── 정보 카드 ─────────────────────────────────────────────
class InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;

  const InfoCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.bgSecondary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.bgTertiary, width: 0.5),
      ),
      child: child,
    );
  }
}

// ── 필드 레이블 ───────────────────────────────────────────
class FieldLabel extends StatelessWidget {
  final String label;
  const FieldLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) => Text(label,
    style: const TextStyle(
      fontSize: 11, color: AppColors.textSecondary,
    ));
}

// ── 토글 버튼 그룹 ────────────────────────────────────────
class ToggleGroup extends StatelessWidget {
  final List<String> options;
  final int selected;
  final void Function(int) onChanged;

  const ToggleGroup({
    super.key,
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

// ── 입력 필드 래퍼 ────────────────────────────────────────
class LabeledField extends StatelessWidget {
  final String label;
  final Widget child;

  const LabeledField({
    super.key,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 5),
        child,
      ],
    );
  }
}

// ── 스피너 위젯 ───────────────────────────────────────────
class SpinnerField extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final String unit;
  final void Function(int) onChanged;

  const SpinnerField({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 7,
    this.unit = '회 / 주',
  });

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
          _SpinBtn(
            icon: Icons.remove,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
          ),
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
                Text(unit,
                  style: const TextStyle(
                    fontSize: 10, color: AppColors.textTertiary,
                  )),
              ],
            ),
          ),
          Container(width: 0.5, height: 48, color: AppColors.bgTertiary),
          _SpinBtn(
            icon: Icons.add,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
          ),
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
  Widget build(BuildContext context) => GestureDetector(
    onTap: enabled ? onTap : null,
    child: SizedBox(
      width: 52, height: 52,
      child: Icon(icon, size: 22,
        color: enabled ? AppColors.textSecondary : AppColors.bgTertiary),
    ),
  );
}

// ── 앱바 구분선 ───────────────────────────────────────────
class AppBarDivider extends StatelessWidget implements PreferredSizeWidget {
  const AppBarDivider({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(0.5);

  @override
  Widget build(BuildContext context) =>
      Container(height: 0.5, color: AppColors.border);
}
