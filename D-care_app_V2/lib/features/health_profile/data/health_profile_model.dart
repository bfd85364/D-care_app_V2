// lib/features/health_profile/data/health_profile_model.dart
class HealthProfile {
  final int id;
  final int userId;
  final int age;
  final String gender;
  final double heightCm;
  final double weightKg;
  final double bmi;
  final double? waistCm;
  final double? fastingGlucose;
  final double? postprandialGlucose;
  final double? hba1c;
  final double? systolicBp;
  final double? diastolicBp;
  final int smoking;
  final int exercisePerWeek;
  final bool familyHistory;
  final bool hypertension;
  final bool dyslipidemia;
  final double? drinkFrequency;
  final double? drinkAmount;
  final double? breakfastFreq;
  final double? lunchFreq;
  final double? dinnerFreq;
  final double? dailyCalories;
  final double? dailyCarbs;
  final double? dailySugar;
  final String? lastRiskLabel;
  final double? lastRiskProb;

  const HealthProfile({
    required this.id,
    required this.userId,
    required this.age,
    required this.gender,
    required this.heightCm,
    required this.weightKg,
    required this.bmi,
    this.waistCm,
    this.fastingGlucose,
    this.postprandialGlucose,
    this.hba1c,
    this.systolicBp,
    this.diastolicBp,
    required this.smoking,
    required this.exercisePerWeek,
    required this.familyHistory,
    required this.hypertension,
    required this.dyslipidemia,
    this.drinkFrequency,
    this.drinkAmount,
    this.breakfastFreq,
    this.lunchFreq,
    this.dinnerFreq,
    this.dailyCalories,
    this.dailyCarbs,
    this.dailySugar,
    this.lastRiskLabel,
    this.lastRiskProb,
  });

  factory HealthProfile.fromJson(Map<String, dynamic> j) => HealthProfile(
    id:                   j['id'],
    userId:               j['user_id'],
    age:                  j['age'],
    gender:               j['gender'],
    heightCm:             (j['height_cm'] as num).toDouble(),
    weightKg:             (j['weight_kg'] as num).toDouble(),
    bmi:                  (j['bmi'] as num).toDouble(),
    waistCm:              j['waist_cm'] != null ? (j['waist_cm'] as num).toDouble() : null,
    fastingGlucose:       j['fasting_glucose'] != null ? (j['fasting_glucose'] as num).toDouble() : null,
    postprandialGlucose:  j['postprandial_glucose'] != null ? (j['postprandial_glucose'] as num).toDouble() : null,
    hba1c:                j['hba1c'] != null ? (j['hba1c'] as num).toDouble() : null,
    systolicBp:           j['systolic_bp'] != null ? (j['systolic_bp'] as num).toDouble() : null,
    diastolicBp:          j['diastolic_bp'] != null ? (j['diastolic_bp'] as num).toDouble() : null,
    smoking:              j['smoking'] ?? 0,
    exercisePerWeek:      j['exercise_per_week'] ?? 0,
    familyHistory:        j['family_history'] ?? false,
    hypertension:         j['hypertension'] ?? false,
    dyslipidemia:         j['dyslipidemia'] ?? false,
    drinkFrequency:       j['drink_frequency'] != null ? (j['drink_frequency'] as num).toDouble() : null,
    drinkAmount:          j['drink_amount'] != null ? (j['drink_amount'] as num).toDouble() : null,
    breakfastFreq:        j['breakfast_freq'] != null ? (j['breakfast_freq'] as num).toDouble() : null,
    lunchFreq:            j['lunch_freq'] != null ? (j['lunch_freq'] as num).toDouble() : null,
    dinnerFreq:           j['dinner_freq'] != null ? (j['dinner_freq'] as num).toDouble() : null,
    dailyCalories:        j['daily_calories'] != null ? (j['daily_calories'] as num).toDouble() : null,
    dailyCarbs:           j['daily_carbs'] != null ? (j['daily_carbs'] as num).toDouble() : null,
    dailySugar:           j['daily_sugar'] != null ? (j['daily_sugar'] as num).toDouble() : null,
    lastRiskLabel:        j['last_risk_label'],
    lastRiskProb:         j['last_risk_prob'] != null ? (j['last_risk_prob'] as num).toDouble() : null,
  );

  // 로컬 계산 유틸
  String get bmiLabel {
    if (bmi < 18.5) return '저체중';
    if (bmi < 23.0) return '정상';
    if (bmi < 25.0) return '과체중';
    return '비만';
  }
}
