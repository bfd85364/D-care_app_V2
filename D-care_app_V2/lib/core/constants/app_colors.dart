// lib/core/constants/app_colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // 배경
  static const bgPrimary   = Color(0xFFF1F5F9);
  static const bgSecondary = Color(0xFFE1E1E1);
  static const bgTertiary  = Color(0xFFE6E2E2);
  static const border      = Color(0xFF1BE800);

  // 텍스트
  static const textPrimary   = Color(0xFF000000);
  static const textSecondary = Color(0xFF010500);
  static const textTertiary  = Color(0xFF000000);

  // 액센트
  static const accent     = Color(0xFF06B6D4);
  static const accentBlue = Color(0xFF3B82F6);

  // 위험군
  static const riskHigh   = Color(0xFFEF4444);
  static const riskMedium = Color(0xFFEAB308);
  static const riskLow    = Color(0xFF22C55E);

  static const riskHighBg   = Color(0xFFFEE2E2);
  static const riskMediumBg = Color(0xFFFEF9C3);
  static const riskLowBg    = Color(0xFFDCFCE7);

  static const riskHighText   = Color(0xFF991B1B);
  static const riskMediumText = Color(0xFF854D0E);
  static const riskLowText    = Color(0xFF15803D);

  // 혈당 상태 색상 (상수)
  static const glucoseNormal  = Color(0xFF22C55E);
  static const glucoseWarning = Color(0xFFEAB308);
  static const glucoseDanger  = Color(0xFFEF4444);

  // 그라디언트
  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 혈당 상태 색상 헬퍼
  static Color glucoseDot(String status) => switch (status) {
    '정상' => riskLow,
    '주의' => riskMedium,
    _     => riskHigh,
  };

  static Color glucoseBg(String status) => switch (status) {
    '정상' => riskLowBg,
    '주의' => riskMediumBg,
    _     => riskHighBg,
  };

  static Color glucoseText(String status) => switch (status) {
    '정상' => riskLowText,
    '주의' => riskMediumText,
    _     => riskHighText,
  };
}