import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const _tokenKey = 'auth_token';
  static const _userIdKey = 'user_id';
  static const _userRolKey = 'user_rol';
  static const _userNombreKey = 'user_nombre';
  static const _userEmailKey = 'user_email';

  Future<void> saveSession({
    required String token,
    required int userId,
    required String rol,
    required String nombre,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setInt(_userIdKey, userId);
    await prefs.setString(_userRolKey, rol);
    await prefs.setString(_userNombreKey, nombre);
    await prefs.setString(_userEmailKey, email);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<Map<String, dynamic>?> getSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    if (token == null) return null;
    return {
      'token': token,
      'id': prefs.getInt(_userIdKey) ?? 0,
      'rol': prefs.getString(_userRolKey) ?? '',
      'nombre': prefs.getString(_userNombreKey) ?? '',
      'email': prefs.getString(_userEmailKey) ?? '',
    };
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
