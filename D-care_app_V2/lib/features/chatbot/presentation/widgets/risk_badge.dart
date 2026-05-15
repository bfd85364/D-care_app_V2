// lib/features/chatbot/presentation/widgets/risk_badge.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class RiskBadge extends StatelessWidget {
  const RiskBadge({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: ref.watch(riskLevelProvider)로 실제 위험군 연동
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.riskMediumBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.riskMedium, width: 0.5),
      ),
      child: const Text('중위험',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.riskMediumText,
          )),
    );
  }
}