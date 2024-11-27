import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:jasaivoy_driver/models/auth_model.dart';

class ViajesRegistradosScreen extends StatefulWidget {
  const ViajesRegistradosScreen({super.key});

  @override
  _ViajesRegistradosScreenState createState() =>
      _ViajesRegistradosScreenState();
}

class _ViajesRegistradosScreenState extends State<ViajesRegistradosScreen> {
  List<dynamic> viajes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchViajes();
  }

  Future<void> fetchViajes() async {
    try {
      final authModel = Provider.of<AuthModel>(context, listen: false);
      final fetchedViajes = await authModel.fetchViajes();
      setState(() {
        viajes = fetchedViajes;
        isLoading = false;
      });
    } catch (e) {
      print('Error al cargar los viajes: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Viajes registrados'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : viajes.isEmpty
              ? const Center(
                  child: Text('No hay viajes registrados.'),
                )
              : ListView.builder(
                  itemCount: viajes.length,
                  itemBuilder: (context, index) {
                    final viaje = viajes[index];
                    return _buildTravelCard(
                      context,
                      driverPhone: viaje['driver_phone'] ?? 'No disponible',
                      startCoordinates: LatLng(
                        double.tryParse(viaje['start_latitude']) ?? 0.0,
                        double.tryParse(viaje['start_longitude']) ?? 0.0,
                      ),
                      destinationCoordinates: LatLng(
                        double.tryParse(viaje['destination_latitude']) ?? 0.0,
                        double.tryParse(viaje['destination_longitude']) ?? 0.0,
                      ),
                    );
                  },
                ),
    );
  }

  Widget _buildTravelCard(
    BuildContext context, {
    required String driverPhone,
    required LatLng startCoordinates,
    required LatLng destinationCoordinates,
  }) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              'Teléfono del conductor: $driverPhone',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: startCoordinates,
                  zoom: 14.0,
                ),
                markers: {
                  Marker(
                    markerId: const MarkerId('start'),
                    position: startCoordinates,
                    infoWindow: const InfoWindow(title: 'Inicio del viaje'),
                  ),
                  Marker(
                    markerId: const MarkerId('destination'),
                    position: destinationCoordinates,
                    infoWindow: const InfoWindow(title: 'Destino del viaje'),
                  ),
                },
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('route'),
                    points: [startCoordinates, destinationCoordinates],
                    color: Colors.blue,
                    width: 4,
                  ),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
