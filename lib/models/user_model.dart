class UserModel {
  final int id;
  final String email;
  final String nombre;
  final String rol;
  final String token;

  UserModel({
    required this.id,
    required this.email,
    required this.nombre,
    required this.rol,
    required this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        email: json['email'],
        nombre: json['nombre'],
        rol: json['rol'],
        token: json['access_token'] ?? '',
      );

  bool get isEncargado => rol == 'ENCARGADO';
  bool get isVoluntario => rol == 'VOLUNTARIO';
}
