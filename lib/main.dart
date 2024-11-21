import 'package:flutter/material.dart';
import 'package:jasaivoy_driver/pages/login.dart';
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const SplashApp());
}

class SplashApp extends StatelessWidget {
  const SplashApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthModel(),
      child: MaterialApp(
        title: 'Jasai Voy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
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
    _requestAllPermissions().then((_) {
      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      });
    });
  }

  Future<void> _requestAllPermissions() async {
    // Lista de permisos requeridos
    List<Permission> permissions = [
      Permission.locationWhenInUse, // Acceso a la ubicación en uso
      Permission.locationAlways, // Acceso a la ubicación en segundo plano
      Permission.camera, // Acceso a la cámara
      Permission.microphone, // Acceso al micrófono
      Permission.photos, // Acceso a la galería de fotos
    ];

    // Solicita todos los permisos
    Map<Permission, PermissionStatus> statuses = await permissions.request();

    // Verifica si algún permiso fue denegado
    statuses.forEach((permission, status) {
      if (status.isDenied || status.isPermanentlyDenied) {
        // Manejar permisos denegados si es necesario
        print('$permission fue denegado');
      } else {
        print('$permission fue otorgado');
      }
    });

    // Si algún permiso crítico es denegado permanentemente, puedes redirigir al usuario a la configuración
    if (statuses.values.any((status) => status.isPermanentlyDenied)) {
      await _showSettingsDialog();
    }
  }

  Future<void> _showSettingsDialog() async {
    // Diálogo para redirigir a la configuración si algún permiso crítico es denegado permanentemente
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permisos necesarios'),
        content: const Text(
            'Algunos permisos han sido denegados permanentemente. Por favor, habilítalos en la configuración para continuar.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings(); // Abre la configuración de la app
            },
            child: const Text('Ir a configuración'),
          ),
        ],
      ),
    );
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
