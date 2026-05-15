// lib/features/glucose/provider/glucose_provider.dart
// FastAPI 실제 연동 버전

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/glucose_model.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/storage/secure_storage.dart';

//혈당 사이드바
final glucoseSidebarProvider =
AsyncNotifierProvider<GlucoseSidebarNotifier, List<DayGroup>>(
  GlucoseSidebarNotifier.new,
);

class GlucoseSidebarNotifier extends AsyncNotifier<List<DayGroup>> {
  @override
  Future<List<DayGroup>> build() async {
    return _fetchSidebar();
  }

  Future<List<DayGroup>> _fetchSidebar() async {
    final userId = await SecureStorage.getUserId();
    if (userId == null) return [];

    final res = await DioClient.instance.get(
      '/api/glucose/sidebar/$userId',
      queryParameters: {'days': 30},
    );
    return (res.data as List)
        .map((d) => DayGroup.fromJson(d as Map<String, dynamic>))
        .toList();
  }

  //혈당 기록 추가
  Future<void> addRecord({
    required double glucose,
    required String measurementType,
    String? memo,
  }) async {
    final userId = await SecureStorage.getUserId();
    if (userId == null) return;

    await DioClient.instance.post(
      '/api/glucose/$userId',
      data: {
        'glucose':          glucose,
        'measurement_type': measurementType,
        'measured_at':      DateTime.now().toIso8601String(),
        'memo':             memo,
      },
    );
    ref.invalidateSelf();
  }

  //혈당 기록 삭제
  Future<void> deleteRecord(int recordId) async {
    await DioClient.instance.delete('/api/glucose/record/$recordId');
    ref.invalidateSelf();
  }
}

// 대시보드 혈당 통계
final glucoseStatsProvider =
AsyncNotifierProvider<GlucoseStatsNotifier, Map<String, dynamic>>(
  GlucoseStatsNotifier.new,
);

class GlucoseStatsNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    return _fetchStats();
  }

  Future<Map<String, dynamic>> _fetchStats() async {
    final userId = await SecureStorage.getUserId();
    if (userId == null) return _emptyStats();

    final res = await DioClient.instance.get(
      '/api/glucose/$userId/stats',
      queryParameters: {'days': 7},
    );
    return res.data as Map<String, dynamic>;
  }

  Map<String, dynamic> _emptyStats() => {
    'avg':   0.0,
    'max':   0.0,
    'min':   0.0,
    'count': 0,
  };

  Future<void> refresh() async => ref.invalidateSelf();
}