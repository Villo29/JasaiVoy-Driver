import 'package:flutter/material.dart';
import 'package:jasaivoy_driver/pages/login.dart';
import 'package:jasaivoy_driver/pages/ReciboDeSolicitudViajeChofer.dart'; // Importa la pantalla principal
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para operaciones asíncronas antes de runApp
  final authModel = AuthModel();
  await authModel.loadSession(); // Cargar la sesión al iniciar

  runApp(
    ChangeNotifierProvider(
      create: (_) => authModel,
      child: const SplashApp(),
    ),
  );
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jasai Voy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuthentication(); // Verificar autenticación al iniciar
  }

  void _checkAuthentication() async {
    final authModel = Provider.of<AuthModel>(context, listen: false);
    if (authModel.isLoggedIn) {
      // Si el usuario está autenticado, redirigir a la pantalla principal
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen(token: authModel.token)),
      );
    } else {
      // Si no está autenticado, ir a la pantalla de inicio de sesión
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logoJasaiVOY.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const Text(
              'Jasai Voy',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Viajes seguro y fácil',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
