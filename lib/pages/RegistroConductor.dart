import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:jasaivoy_driver/pages/ReciboDeSolicitudViajeChofer.dart'; // Importa la pantalla de destino.

class PassengerRegistrationScreen extends StatefulWidget {
  const PassengerRegistrationScreen({super.key});

  @override
  _PassengerRegistrationScreenState createState() =>
      _PassengerRegistrationScreenState();
}

class _PassengerRegistrationScreenState
    extends State<PassengerRegistrationScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _nombreController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    _telefonoController.dispose();
    _curpController.dispose();
    _matriculaController.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final String nombre = _nombreController.text;
    final String correo = _correoController.text;
    final String contrasena = _passwordController.text;
    final String telefono = _telefonoController.text;
    final String curp = _curpController.text;
    final String matricula = _matriculaController.text;

    if (nombre.isNotEmpty &&
        correo.isNotEmpty &&
        contrasena.isNotEmpty &&
        telefono.isNotEmpty &&
        curp.isNotEmpty &&
        matricula.isNotEmpty) {
      if (contrasena.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('La contraseña debe tener al menos 6 caracteres')),
        );
        return;
      }

      if (telefono.length < 10) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('El número de teléfono debe tener al menos 10 dígitos')),
        );
        return;
      }

      // Mostrar el diálogo de carga
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      try {
        final response = await http.post(
          Uri.parse('http://35.175.159.211:3028/api/v1/chofer'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nombre': nombre,
            'correo': correo,
            'contrasena': contrasena,
            'telefono': telefono,
            'curp': curp,
            'matricula': matricula,
          }),
        );

        Navigator.pop(context); // Cerrar el diálogo de carga

        print('Response status: ${response.statusCode}');
        print('Response body: ${response.body}');

        if (response.statusCode == 200 || response.statusCode == 201) {
          final data = json.decode(response.body);

          if (data != null && data['token'] != null && data['id'] != null) {
            final String token = data['token'];

            print('Token: $token');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Registro exitoso')),
            );

            // Redirigir a la siguiente vista con el token
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(token: token),
                ),
              );
            }
          } else {
            print('Unexpected response format: $data');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Error al procesar la respuesta')),
            );
          }
        } else {
          print('Unexpected status code: ${response.statusCode}');
          print('Response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${response.statusCode}')),
          );
        }
      } catch (e) {
        Navigator.pop(context); // Cerrar el diálogo de carga en caso de error
        print('Exception caught: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error en la conexión: $e')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Todos los campos son obligatorios')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/ImagenPasajero.png',
                      height: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Pasajero',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _nombreController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _correoController,
                decoration: InputDecoration(
                  labelText: 'Correo',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _telefonoController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Teléfono',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _curpController,
                decoration: InputDecoration(
                  labelText: 'CURP',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _matriculaController,
                decoration: InputDecoration(
                  labelText: 'Matrícula',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
