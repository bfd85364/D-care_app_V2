// lib/features/glucose/data/glucose_model.dart
// freezed 없는 일반 클래스 버전
// build_runner 실행 불필요

class GlucoseRecord {
  final int id;
  final double glucose;
  final String measurementType; // 공복 | 식후2시간
  final DateTime measuredAt;
  final String status;          // 정상 | 주의 | 위험
  final String? memo;

  const GlucoseRecord({
    required this.id,
    required this.glucose,
    required this.measurementType,
    required this.measuredAt,
    required this.status,
    this.memo,
  });

  factory GlucoseRecord.fromJson(Map<String, dynamic> json) {
    return GlucoseRecord(
      id:              json['id'] as int,
      glucose:         (json['glucose'] as num).toDouble(),
      measurementType: json['measurement_type'] as String,
      measuredAt:      DateTime.parse(json['measured_at'] as String),
      status:          json['status'] as String,
      memo:            json['memo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id':               id,
      'glucose':          glucose,
      'measurement_type': measurementType,
      'measured_at':      measuredAt.toIso8601String(),
      'status':           status,
      'memo':             memo,
    };
  }

  // 필요 시 copyWith
  GlucoseRecord copyWith({
    int? id,
    double? glucose,
    String? measurementType,
    DateTime? measuredAt,
    String? status,
    String? memo,
  }) {
    return GlucoseRecord(
      id:              id              ?? this.id,
      glucose:         glucose         ?? this.glucose,
      measurementType: measurementType ?? this.measurementType,
      measuredAt:      measuredAt      ?? this.measuredAt,
      status:          status          ?? this.status,
      memo:            memo            ?? this.memo,
    );
  }
}

class DayGroup {
  final String date;
  final String label;
  final List<GlucoseRecord> records;
  final double avgGlucose;

  const DayGroup({
    required this.date,
    required this.label,
    required this.records,
    required this.avgGlucose,
  });

  factory DayGroup.fromJson(Map<String, dynamic> json) {
    return DayGroup(
      date:       json['date'] as String,
      label:      json['label'] as String,
      avgGlucose: (json['avg_glucose'] as num).toDouble(),
      records:    (json['records'] as List)
          .map((r) => GlucoseRecord.fromJson(r as Map<String, dynamic>))
          .toList(),
    );
  }
}