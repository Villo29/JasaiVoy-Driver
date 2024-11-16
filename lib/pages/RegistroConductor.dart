import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:jasaivoy_driver/pages/ReciboDeSolicitudViajeChofer.dart';

class RegisterDriverScreen extends StatefulWidget {
  const RegisterDriverScreen({super.key});

  @override
  State<RegisterDriverScreen> createState() => _RegisterDriverScreenState();
}

class _RegisterDriverScreenState extends State<RegisterDriverScreen> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();
  final TextEditingController _curpController = TextEditingController();
  final TextEditingController _matriculaController = TextEditingController();

  bool _isPasswordVisible = false;
  // ignore: unused_field
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 4) {
      // Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Image.asset(
                      'assets/images/taxis.png', // Imagen del conductor
                      height: 120,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Conductor',
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
              _buildTextField(
                controller: _companyController,
                labelText: 'Empresa',
                icon: Icons.business,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _emailController,
                labelText: 'Correo',
                icon: Icons.email,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _passwordController,
                labelText: 'Contraseña',
                icon: Icons.lock,
                isPassword: true,
                isPasswordVisible: _isPasswordVisible,
                togglePasswordVisibility: () {
                  setState(() {
                    _isPasswordVisible = !_isPasswordVisible;
                  });
                },
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _telefonoController,
                labelText: 'Teléfono',
                icon: Icons.phone,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _curpController,
                labelText: 'CURP',
                icon: Icons.person,
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: _matriculaController,
                labelText: 'Matrícula',
                icon: Icons.car_repair,
              ),
              const SizedBox(height: 20),
              Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      const TextSpan(
                        text: 'Al registrarse, acepta nuestros ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      TextSpan(
                        text: 'Términos y Condiciones',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navegar a Términos y Condiciones
                          },
                      ),
                      const TextSpan(
                        text: ' y ',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      TextSpan(
                        text: 'Política de privacidad',
                        style: const TextStyle(color: Colors.red, fontSize: 12),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            // Navegar a Política de privacidad
                          },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const HomeScreen(token: 'your_token_here'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Registrate',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool isPassword = false,
    bool isPasswordVisible = false,
    VoidCallback? togglePasswordVisibility,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword && !isPasswordVisible,
      decoration: InputDecoration(
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Icon(icon, color: Colors.red),
        ),
        labelText: labelText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
                onPressed: togglePasswordVisibility,
              )
            : null,
      ),
    );
  }
}
