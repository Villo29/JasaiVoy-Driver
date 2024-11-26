import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:jasaivoy_driver/pages/Viajesregistradosconductor.dart';
import 'package:jasaivoy_driver/pages/ReciboDeSolicitudViajeChofer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  bool _isLoading = false;
  int _selectedIndex = 0; // Inicializar índice seleccionado

  @override
  void initState() {
    super.initState();
    final authModel = Provider.of<AuthModel>(context, listen: false);
    final user = authModel.currentUser;

    // Inicializar los controladores con los datos actuales del usuario
    _nameController = TextEditingController(text: user?.nombre ?? '');
    _emailController = TextEditingController(text: user?.correo ?? '');
    _phoneController = TextEditingController(text: user?.telefono ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);

    setState(() {
      _isLoading = true; // Mostrar indicador de carga
    });

    try {
      // Llamar al método del AuthModel para actualizar el perfil
      await authModel.updateUserProfile(
        nombre: _nameController.text,
        correo: _emailController.text,
        telefono: _phoneController.text,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );

      Navigator.pop(context); // Volver a la pantalla anterior
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al actualizar el perfil: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Ocultar indicador de carga
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration:
                  const InputDecoration(labelText: 'Correo Electrónico'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Teléfono'),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator() // Mostrar indicador de carga mientras se guarda
                : ElevatedButton(
                    onPressed: _saveProfile,
                    child: const Text('Guardar Cambios'),
                  ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar2.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar3.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar4.png'),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar5.png'),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });

          // Manejar la redirección con if
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraphScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MyApp()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const RegisteredTripsScreen()),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const EditProfileScreen()),
            );
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}

class GraphScreen extends StatelessWidget {
  const GraphScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Graficas'),
        backgroundColor: Colors.green,
      ),
      body: const Center(
        child: Text('Pantalla de Graficas'),
      ),
    );
  }
}
