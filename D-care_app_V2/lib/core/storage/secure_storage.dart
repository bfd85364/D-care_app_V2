// lib/core/storage/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  //JWT 토큰
  static Future<void> saveToken(String token) async =>
      await _storage.write(key: 'jwt_token', value: token);

  static Future<String?> getToken() async =>
      await _storage.read(key: 'jwt_token');

  static Future<void> deleteToken() async =>
      await _storage.delete(key: 'jwt_token');

  //사용자 ID
  static Future<void> saveUserId(int userId) async =>
      await _storage.write(key: 'user_id', value: userId.toString());

  static Future<int?> getUserId() async {
    final val = await _storage.read(key: 'user_id');
    return val != null ? int.tryParse(val) : null;
  }

  //사용자 이름
  static Future<void> saveUserName(String name) async =>
      await _storage.write(key: 'user_name', value: name);

  static Future<String?> getUserName() async =>
      await _storage.read(key: 'user_name');


  //전체 삭제 (로그아웃)
  static Future<void> clearAll() async => await _storage.deleteAll();

  //로그인 여부 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}