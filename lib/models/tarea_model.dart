class TareaModel {
  final int id;
  final String descripcion;
  final String fechaLimite;
  final String estado;
  final int voluntarioId;
  final String voluntarioNombre;
  final int programaId;
  final String programaNombre;

  TareaModel({
    required this.id,
    required this.descripcion,
    required this.fechaLimite,
    required this.estado,
    required this.voluntarioId,
    required this.voluntarioNombre,
    required this.programaId,
    required this.programaNombre,
  });

  factory TareaModel.fromJson(Map<String, dynamic> json) => TareaModel(
        id: json['id'],
        descripcion: json['descripcion'],
        fechaLimite: json['fechaLimite'] ?? '',
        estado: json['estado'] ?? 'PENDIENTE',
        voluntarioId: json['voluntarioId'],
        voluntarioNombre: json['voluntario']?['nombre'] ?? '',
        programaId: json['programaId'],
        programaNombre: json['programa']?['nombre'] ?? '',
      );
}
