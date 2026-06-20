class TareaModel {
  final int id;
  final String titulo;
  final String descripcion;
  final String fechaLimite;
  final String estado;
  final String? comentario;
  final int voluntarioId;
  final String voluntarioNombre;
  final int programaId;
  final String programaNombre;

  TareaModel({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaLimite,
    required this.estado,
    this.comentario,
    required this.voluntarioId,
    required this.voluntarioNombre,
    required this.programaId,
    required this.programaNombre,
  });

  String get tituloDisplay => titulo.isNotEmpty ? titulo : descripcion;

  factory TareaModel.fromJson(Map<String, dynamic> json) => TareaModel(
        id: json['id'],
        titulo: json['titulo'] ?? '',
        descripcion: json['descripcion'],
        fechaLimite: json['fechaLimite'] ?? '',
        estado: json['estado'] ?? 'PENDIENTE',
        comentario: json['comentario'],
        voluntarioId: json['voluntarioId'],
        voluntarioNombre: json['voluntario']?['nombre'] ?? '',
        programaId: json['programaId'],
        programaNombre: json['programa']?['nombre'] ?? '',
      );
}
