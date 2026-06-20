class ProgramaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final int? encargadoId;
  final String encargadoNombre;

  ProgramaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.encargadoId,
    required this.encargadoNombre,
  });

  factory ProgramaModel.fromJson(Map<String, dynamic> json) => ProgramaModel(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        encargadoId: json['encargado']?['id'],
        encargadoNombre: json['encargado']?['nombre'] ?? '',
      );
}
