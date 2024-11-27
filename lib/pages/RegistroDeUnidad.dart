import 'package:flutter/material.dart';

class RegistroUnidadPage extends StatefulWidget {
  const RegistroUnidadPage({super.key});

  @override
  _RegistroUnidadPageState createState() => _RegistroUnidadPageState();
}

class _RegistroUnidadPageState extends State<RegistroUnidadPage> {
  final _colorController = TextEditingController();
  final _placaController = TextEditingController();
  final _tarjetaController = TextEditingController();
  final _caracteristicaController = TextEditingController();

  int _selectedIndex = 0;

  @override
  void dispose() {
    _colorController.dispose();
    _placaController.dispose();
    _tarjetaController.dispose();
    _caracteristicaController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Registro de unidad',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: GestureDetector(
                onTap: () {
                },
                child: Container(
                  height: 120,
                  width: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _colorController,
              decoration: const InputDecoration(
                labelText: 'Color de mototaxi',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _placaController,
              decoration: const InputDecoration(
                labelText: 'N° de placa del mototaxi',
                hintText: 'Ej. WLU-94-69',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _tarjetaController,
              decoration: const InputDecoration(
                labelText: 'Tarjeta de circulación',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _caracteristicaController,
              decoration: const InputDecoration(
                labelText: 'Característica de la mototaxi',
              ),
            ),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  print('Unidad registrada');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreenAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text('Registrar'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 30, 30, 30),
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar1.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar2.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar3.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar4.png', height: 30),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/IcoNavBar5.png', height: 30),
            label: '',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.yellow,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}