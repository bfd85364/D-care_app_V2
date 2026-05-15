// lib/features/auth/provider/auth_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/network/dio_client.dart';

class AuthState {
  final bool isLoggedIn;
  final String? userName;
  final int? userId;
  final String? error;

  const AuthState({
    this.isLoggedIn = false,
    this.userName,
    this.userId,
    this.error,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    String? userName,
    int? userId,
    String? error,
  }) => AuthState(
    isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    userName:   userName   ?? this.userName,
    userId:     userId     ?? this.userId,
    error:      error,
  );
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

class AuthNotifier extends Notifier<AuthState> {
  static const _storage = FlutterSecureStorage();

  @override
  AuthState build() => const AuthState();

  //로그인
  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(error: null);
    try {
      final res = await DioClient.instance.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );
      await _saveSession(
        token:    res.data['access_token'] as String,
        userId:   res.data['user_id']      as int,
        userName: res.data['name']         as String,
      );
    } catch (e) {
      state = state.copyWith(error: '이메일 또는 비밀번호를 확인하세요');
      rethrow;
    }
  }

  //회원가입
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(error: null);
    try {
      final res = await DioClient.instance.post(
        '/api/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      await _saveSession(
        token:    res.data['access_token'] as String,
        userId:   res.data['user_id']      as int,
        userName: name,
      );
    } catch (e) {
      state = state.copyWith(error: '이미 사용 중인 이메일입니다');
      rethrow;
    }
  }

  //자동 로그인 (토큰 서버 검증 포함)
  Future<bool> checkAutoLogin() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) return false;

      // 서버에 토큰 유효성 확인
      final res = await DioClient.instance.get('/api/auth/me');

      final userIdStr = await _storage.read(key: 'user_id');
      final userName  = await _storage.read(key: 'user_name');

      state = state.copyWith(
        isLoggedIn: true,
        userId:     int.tryParse(userIdStr ?? ''),
        userName:   res.data['name'] as String? ?? userName,
      );
      return true;
    } catch (e) {
      // 토큰 만료 or 서버 오류 → 저장 삭제 후 로그인 화면
      await _storage.deleteAll();
      return false;
    }
  }

  //로그아웃
  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthState();
  }

  //공통: 세션 저장
  Future<void> _saveSession({
    required String token,
    required int userId,
    required String userName,
  }) async {
    await _storage.write(key: 'jwt_token', value: token);
    await _storage.write(key: 'user_id',   value: userId.toString());
    await _storage.write(key: 'user_name', value: userName);
    state = state.copyWith(
      isLoggedIn: true,
      userId:     userId,
      userName:   userName,
    );
  }
}