import 'package:flutter/foundation.dart';
import '../models/programa_model.dart';
import '../services/api_service.dart';

class ProgramaProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  ProgramaModel? _programa;
  List<dynamic> _voluntarios = [];
  bool _isLoading = false;
  String? _error;

  ProgramaModel? get programa => _programa;
  List<dynamic> get voluntarios => _voluntarios;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPrograma() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.getMiPrograma();
      _programa = ProgramaModel.fromJson(data);
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVoluntarios() async {
    try {
      _voluntarios = await _api.getVoluntarios();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    }
    notifyListeners();
  }
}
