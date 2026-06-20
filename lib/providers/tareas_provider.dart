import 'package:flutter/foundation.dart';
import '../models/tarea_model.dart';
import '../services/api_service.dart';

class TareasProvider extends ChangeNotifier {
  final ApiService _api = ApiService();

  List<TareaModel> _misTareas = [];
  List<TareaModel> _tareasCompletadas = [];
  List<TareaModel> _tareasDelPrograma = [];
  bool _isLoading = false;
  String? _error;

  List<TareaModel> get misTareas => _misTareas;
  List<TareaModel> get tareasCompletadas => _tareasCompletadas;
  List<TareaModel> get tareasDelPrograma => _tareasDelPrograma;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadMisTareas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.getMisTareas();
      _misTareas = data.map((j) => TareaModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTareasCompletadas() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.getTareasCompletadas();
      _tareasCompletadas = data.map((j) => TareaModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTareasDelPrograma() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final data = await _api.getTareasDelPrograma();
      _tareasDelPrograma = data.map((j) => TareaModel.fromJson(j)).toList();
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> marcarCompletada(int id) async {
    try {
      await _api.marcarTareaCompletada(id);
      await loadMisTareas();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarEstado(int id, String estado) async {
    try {
      await _api.actualizarEstadoTarea(id, estado);
      await loadTareasCompletadas();
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
