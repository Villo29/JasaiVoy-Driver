import 'package:flutter/material.dart';
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:jasaivoy_driver/pages/Viajesregistradosconductor.dart';
import 'package:jasaivoy_driver/pages/EditProfileScreen.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _authenticate(BuildContext context) async {
    final LocalAuthentication auth = LocalAuthentication();
    bool isAuthenticated = false;

    try {
      isAuthenticated = await auth.authenticate(
        localizedReason: 'Por favor autentícate para editar tu perfil',
        options: const AuthenticationOptions(
          biometricOnly: true, // Solo huella o FaceID
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la autenticación: $e')),
      );
      return;
    }

    if (isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticación exitosa')),
      );
      // Ejecutar la acción que ya tienes en tu código original
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const EditProfileScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Autenticación fallida')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authModel = Provider.of<AuthModel>(context);
    final user = authModel.currentUser;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Hola ${user?.nombre ?? ''} 👋',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            if (user?.foto != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(user!.foto!),
              ),
            const SizedBox(height: 20),
            const Text(
              'Bienvenido a Jasai',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            InfoRow(label: 'Nombre', value: user?.nombre ?? 'N/A'),
            InfoRow(label: 'Número de teléfono', value: user?.telefono ?? 'N/A'),
            InfoRow(label: 'Correo electrónico', value: user?.correo ?? 'N/A'),
            InfoRow(label: 'Matrícula', value: user?.matricula ?? 'N/A'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ViajesRegistradosScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent.withOpacity(0.3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Viajes realizados',
                style: TextStyle(color: Colors.black),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _authenticate(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent.withOpacity(0.3),
                padding:
                    const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Editar perfil',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final String label;
  final String value;
  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
