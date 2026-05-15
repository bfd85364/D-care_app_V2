// lib/features/chatbot/presentation/widgets/quick_question_chip.dart
import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class QuickQuestionChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const QuickQuestionChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.bgTertiary, width: 0.5),
        ),
        child: Text(label,
            style: const TextStyle(
              fontSize: 12, color: AppColors.textSecondary,
            )),
      ),
    );
  }
}