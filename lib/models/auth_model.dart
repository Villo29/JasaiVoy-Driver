import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy_driver/models/user_model.dart';

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
      throw Exception('Error al iniciar sesión: ${response.statusCode} - ${response.body}');
    }
  }

  // Método para verificar el código y obtener los datos completos del usuario
  Future<void> verifyCode(String codigo, String correo) async {
    var url = Uri.parse('http://35.175.159.211:3028/api/v1/chofer/validar-usuario');
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
        );

        _isVerified = true;
        notifyListeners();
      } else {
        throw Exception('Datos de sesión inválidos: falta el token o los datos del usuario.');
      }
    } else {
      throw Exception('Error al verificar el código: ${response.statusCode} - ${response.body}');
    }
  }
}