import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;

  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;

  Future<void> checkSession() async {
    final session = await _storage.getSession();
    if (session != null && (session['token'] as String).isNotEmpty) {
      _user = UserModel(
        id: session['id'],
        email: session['email'],
        nombre: session['nombre'],
        rol: session['rol'],
        token: session['token'],
      );
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.login(email, password);
      await _storage.saveSession(
        token: data['access_token'],
        userId: data['user']['id'],
        rol: data['user']['rol'],
        nombre: data['user']['nombre'],
        email: data['user']['email'],
      );
      _user = UserModel.fromJson({...data['user'], 'access_token': data['access_token']});
      _status = AuthStatus.authenticated;
    } catch (e) {
      _status = AuthStatus.error;
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }

  Future<void> logout() async {
    await _storage.clearSession();
    _user = null;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
