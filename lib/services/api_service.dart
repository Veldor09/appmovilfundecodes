import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'storage_service.dart';

class ApiService {
  static String get baseUrl => AppConfig.baseUrl;

  final StorageService _storage = StorageService();

  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Credenciales incorrectas');
  }

  Future<List<dynamic>> getVoluntarios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/voluntarios'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener voluntarios');
  }

  Future<Map<String, dynamic>> getMiPrograma() async {
    final response = await http.get(
      Uri.parse('$baseUrl/programas/mi-programa'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('No tienes un programa asignado');
  }

  Future<List<dynamic>> getMisTareas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tareas/mis-tareas'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener tareas');
  }

  Future<List<dynamic>> getTareasCompletadas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tareas/completadas'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener tareas completadas');
  }

  Future<Map<String, dynamic>> crearTarea({
    required String titulo,
    required String descripcion,
    required String fechaLimite,
    required int voluntarioId,
    required int programaId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/tareas'),
      headers: await _authHeaders(),
      body: jsonEncode({
        'titulo': titulo,
        'descripcion': descripcion,
        'fechaLimite': fechaLimite,
        'voluntarioId': voluntarioId,
        'programaId': programaId,
      }),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    throw Exception('Error al crear la tarea');
  }

  Future<void> marcarTareaCompletada(int id) async {
    final response = await http.put(
      Uri.parse('$baseUrl/tareas/$id'),
      headers: await _authHeaders(),
      body: jsonEncode({'estado': 'COMPLETADA'}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al actualizar la tarea');
    }
  }

  Future<void> actualizarEstadoTarea(int id, String estado, {String? comentario}) async {
    final body = <String, dynamic>{'estado': estado};
    if (comentario != null && comentario.isNotEmpty) body['comentario'] = comentario;
    final response = await http.put(
      Uri.parse('$baseUrl/tareas/$id/estado'),
      headers: await _authHeaders(),
      body: jsonEncode(body),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al actualizar el estado');
    }
  }

  Future<List<dynamic>> getTareasDelPrograma() async {
    final response = await http.get(
      Uri.parse('$baseUrl/tareas/del-programa'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener tareas del programa');
  }

  Future<void> saveFcmToken(String token) async {
    await http.put(
      Uri.parse('$baseUrl/auth/fcm-token'),
      headers: await _authHeaders(),
      body: jsonEncode({'token': token}),
    );
  }

  // ── Encargado: gestión de voluntarios ──────────────────────────────────────

  Future<List<dynamic>> getVoluntariosDisponibles() async {
    final response = await http.get(
      Uri.parse('$baseUrl/programas/voluntarios-disponibles'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener voluntarios disponibles');
  }

  Future<void> agregarVoluntarioAPrograma(int voluntarioId) async {
    final response = await http.post(
      Uri.parse('$baseUrl/programas/voluntarios/$voluntarioId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = jsonDecode(response.body);
      throw Exception(body['message'] ?? 'Error al agregar voluntario');
    }
  }

  Future<void> quitarVoluntarioDePrograma(int voluntarioId) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/programas/voluntarios/$voluntarioId'),
      headers: await _authHeaders(),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al quitar voluntario');
    }
  }

  // ── Admin: usuarios ────────────────────────────────────────────────────────

  Future<List<dynamic>> adminGetUsuarios() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/usuarios'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener usuarios');
  }

  Future<Map<String, dynamic>> adminCrearUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/usuarios'),
      headers: await _authHeaders(),
      body: jsonEncode({'nombre': nombre, 'email': email, 'password': password, 'rol': rol}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Error al crear usuario');
  }

  // ── Admin: programas ───────────────────────────────────────────────────────

  Future<List<dynamic>> adminGetProgramas() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/programas'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener programas');
  }

  Future<Map<String, dynamic>> adminCrearPrograma({
    required String nombre,
    String? descripcion,
    required int encargadoId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/admin/programas'),
      headers: await _authHeaders(),
      body: jsonEncode({'nombre': nombre, 'descripcion': descripcion, 'encargadoId': encargadoId}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    }
    final body = jsonDecode(response.body);
    throw Exception(body['message'] ?? 'Error al crear programa');
  }

  Future<List<dynamic>> adminGetEncargados() async {
    final response = await http.get(
      Uri.parse('$baseUrl/admin/encargados'),
      headers: await _authHeaders(),
    );
    if (response.statusCode == 200) return jsonDecode(response.body);
    throw Exception('Error al obtener encargados');
  }
}
