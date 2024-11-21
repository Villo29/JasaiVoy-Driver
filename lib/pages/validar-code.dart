import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:jasaivoy_driver/pages/ReciboDeSolicitudViajeChofer.dart';
import 'package:location/location.dart';

class VerificationScreen extends StatelessWidget {
  const VerificationScreen({super.key});

  Future<bool> _checkLocationPermission(BuildContext context) async {
    Location location = Location();
    PermissionStatus permissionGranted = await location.hasPermission();


    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
    }
    if (permissionGranted != PermissionStatus.granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Permiso de ubicación denegado')),
      );
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController codeController = TextEditingController();
    final authModel = Provider.of<AuthModel>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Verificación de Código')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ingrese su correo y el código de verificación',
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Correo',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: codeController,
              decoration: const InputDecoration(
                labelText: 'Código de verificación',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                try {
                  final email = emailController.text;
                  final codigoVerificacion = codeController.text;

                  // Verificar el código
                  await authModel.verifyCode(codigoVerificacion, email);
                  if (authModel.isVerified) {
                    // Comprobar permisos de ubicación antes de navegar
                    bool hasPermission = await _checkLocationPermission(context);
                    if (hasPermission) {
                      // Navegar a la pantalla principal después de la verificación
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(token: authModel.token), // Pasa el token a HomeScreen
                        ),
                      );
                    }
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Código o correo incorrecto: $e')),
                  );
                }
              },
              child: const Text('Verificar'),
            ),
          ],
        ),
      ),
    );
  }
}
