import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy_driver/models/auth_model.dart';

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
    );
  }
}





 