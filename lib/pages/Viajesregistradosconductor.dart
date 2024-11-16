import 'package:flutter/material.dart';

class RegisteredTripsScreen extends StatelessWidget {
  const RegisteredTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Viajes registrados',
          style: TextStyle(color: Colors.black),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/perfilFoto.png', // Cambia la imagen según sea necesario
              ), // Imagen de perfil
            ),
          ),
        ],
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  _buildTripCard(
                    context,
                    origin: "UPCH.",
                    destination: "Dpto. Monaco",
                    date: "22/10/2024",
                    time: "14:00",
                    price: "10.00",
                  ),
                  _buildTripCard(
                    context,
                    origin: "Parque Sta.Anita",
                    destination: "Mercado",
                    date: "22/10/2024",
                    time: "14:00",
                    price: "20.00",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Lógica para agregar un nuevo viaje
              },
              icon: const Icon(Icons.add, color: Colors.grey),
              label: const Text(
                'Nuevo viaje',
                style: TextStyle(color: Colors.grey),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 197, 251, 246),
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_repair_service, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.black),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings, color: Colors.black),
            label: '',
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context, {
    required String origin,
    required String destination,
    required String date,
    required String time,
    required String price,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$origin - $destination',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Origen',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      origin,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Destino',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      destination,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fecha',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hora',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      time,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '\$ $price',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}