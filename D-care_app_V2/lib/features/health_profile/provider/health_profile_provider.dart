// lib/features/health_profile/provider/health_profile_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/health_profile_model.dart';
import '../../../core/network/dio_client.dart';

// 건강 프로필 캐시 Provider
// 한 번 로드하면 앱 실행 중 재요청 없음
final healthProfileProvider =
    AsyncNotifierProvider<HealthProfileNotifier, HealthProfile?>(
  HealthProfileNotifier.new,
);

class HealthProfileNotifier extends AsyncNotifier<HealthProfile?> {
  @override
  Future<HealthProfile?> build() async {
    // 앱 시작 시 1회만 로드
    return _fetchProfile();
  }

  Future<HealthProfile?> _fetchProfile() async {
    try {
      final userId = 1; // TODO: authProvider에서 가져오기
      final res = await DioClient.instance.get('/api/health/$userId');
      return HealthProfile.fromJson(res.data);
    } catch (_) {
      return null;
    }
  }

  // 저장 후 캐시 갱신
  Future<void> saveProfile(Map<String, dynamic> data) async {
    try {
      final userId = 1;
      await DioClient.instance.post('/api/health/$userId', data: data);
      ref.invalidateSelf(); // 캐시 갱신
    } catch (e) {
      throw Exception('저장 실패: $e');
    }
  }
}
