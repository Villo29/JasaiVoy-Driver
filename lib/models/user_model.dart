class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;

  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
    );
  }
}