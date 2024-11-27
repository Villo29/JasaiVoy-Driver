import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy_driver/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthModel extends ChangeNotifier {
  bool _isLoggedIn = false;
  bool _isVerified = false;
  String _token = '';
  String _userId = '';
  UserModel? _currentUser;

  UserModel? get currentUser => _currentUser;
  String get token => _token;
  String get userId => _userId;
  bool get isLoggedIn => _isLoggedIn;
  bool get isVerified => _isVerified;

  Future<void> saveSession() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('token', _token);
    prefs.setString('userId', _userId);
    if (_currentUser != null) {
      prefs.setString('currentUser', jsonEncode(_currentUser!.toJson()));
    }
    prefs.setBool('isLoggedIn', _isLoggedIn);
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token') ?? '';
    _userId = prefs.getString('userId') ?? '';
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final currentUserData = prefs.getString('currentUser');
    if (currentUserData != null) {
      _currentUser = UserModel.fromJson(jsonDecode(currentUserData));
    }
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Limpiar la sesión al cerrar
    _isLoggedIn = false;
    _token = '';
    _userId = '';
    _currentUser = null;
    notifyListeners();
  }

  // Método de login solo para verificar credenciales
  Future<void> login(String correo, String contrasena) async {
    var url = Uri.parse('http://35.175.159.211:3028/api/v1/chofer/login');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'correo': correo,
        'contrasena': contrasena,
      }),
    );

    if (response.statusCode == 200) {
      _isLoggedIn = true;
      notifyListeners();
    } else {
      throw Exception(
          'Error al iniciar sesión: ${response.statusCode} - ${response.body}');
    }
  }

  // Método para verificar el código y obtener los datos completos del usuario
  Future<void> verifyCode(String codigo, String correo) async {
    var url =
        Uri.parse('http://35.175.159.211:3028/api/v1/chofer/validar-usuario');
    var response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'correo': correo,
        'codigoVerificacion': codigo,
      }),
    );

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      if (data != null && data['chofer'] != null && data['token'] != null) {
        var chofer = data['chofer'];
        _token = data['token'];
        _userId = chofer['id'].toString();
        _currentUser = UserModel(
          id: chofer['id'].toString(),
          nombre: chofer['nombre'],
          correo: chofer['correo'],
          telefono: chofer['telefono'],
          matricula: chofer['matricula'],
          foto: chofer['imagen_url'],
        );

        _isVerified = true;
        notifyListeners();
      } else {
        throw Exception(
            'Datos de sesión inválidos: falta el token o los datos del usuario.');
      }
    } else {
      throw Exception(
          'Error al verificar el código: ${response.statusCode} - ${response.body}');
    }
  }

  // Nuevo método para actualizar el perfil del usuario
  Future<void> updateUserProfile({
    required String nombre,
    required String correo,
    required String telefono,
    required String matricula,
  }) async {
    if (_token.isEmpty || _userId.isEmpty) {
      throw Exception('Error: Usuario no autenticado');
    }

    final url = Uri.parse('http://35.175.159.211:3028/api/v1/chofer/$_userId');
    final updatedData = {
      'nombre': nombre,
      'correo': correo,
      'telefono': telefono,
      'matricula': matricula,
    };

    try {
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updatedData),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Actualizar los datos locales del usuario (sin modificar la foto)
        _currentUser = UserModel(
          id: _currentUser?.id ?? '',
          nombre: responseData['nombre'] ?? 'Sin nombre',
          correo: responseData['correo'] ?? 'Sin correo',
          telefono: responseData['telefono'] ?? 'Sin teléfono',
          matricula: responseData['matricula'] ?? 'Sin matrícula',
          foto: _currentUser?.foto ?? '', // La foto permanece igual
        );

        notifyListeners(); // Notificar cambios a los widgets dependientes
      } else {
        throw Exception(
            'Error al actualizar el perfil: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Error al realizar la petición: $error');
    }
  }

  Future<void> fetchUserDetails() async {
    if (_token.isEmpty || _userId.isEmpty) {
      throw Exception('Error: Usuario no autenticado');
    }

    final url = Uri.parse('http://35.175.159.211:3028/api/v1/chofer/$_userId');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $_token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        _currentUser = UserModel(
          id: responseData['id'].toString(),
          nombre: responseData['nombre'] ?? 'Sin nombre',
          correo: responseData['correo'] ?? 'Sin correo',
          telefono: responseData['telefono'] ?? 'Sin teléfono',
          matricula: responseData['matricula'] ?? 'Sin matrícula',
          foto: responseData['imagen_url'] ?? '',
        );

        notifyListeners(); // Notificar cambios a los widgets dependientes
      } else {
        throw Exception(
            'Error al obtener los datos del usuario: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Error al realizar la petición: $error');
    }
  }

  Future<List<dynamic>> fetchViajes() async {
    if (_currentUser == null || _currentUser!.telefono.isEmpty) {
      throw Exception('Error: Usuario no autenticado o teléfono no disponible');
    }

    final url = Uri.parse('http://backend.jasai.site:3028/api/v1/chofer/viajes');

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'driverPhone': _currentUser!.telefono,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception(
            'Error al obtener los viajes: ${response.statusCode} - ${response.body}');
      }
    } catch (error) {
      throw Exception('Error en la solicitud de viajes: $error');
    }
  }
}
