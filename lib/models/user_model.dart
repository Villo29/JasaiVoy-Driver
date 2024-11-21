class UserModel {
  final String id;
  final String nombre;
  final String correo;
  final String telefono;
  final String matricula;


  UserModel({
    required this.id,
    required this.nombre,
    required this.correo,
    required this.telefono,
    required this.matricula,


  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      telefono: json['telefono'],
      matricula: json['matricula'],
    );
  }
}