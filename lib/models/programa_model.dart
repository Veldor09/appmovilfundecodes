class ProgramaModel {
  final int id;
  final String nombre;
  final String? descripcion;
  final String encargadoNombre;

  ProgramaModel({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.encargadoNombre,
  });

  factory ProgramaModel.fromJson(Map<String, dynamic> json) => ProgramaModel(
        id: json['id'],
        nombre: json['nombre'],
        descripcion: json['descripcion'],
        encargadoNombre: json['encargado']?['nombre'] ?? '',
      );
}
