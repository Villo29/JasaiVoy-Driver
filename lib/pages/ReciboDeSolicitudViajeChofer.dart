import 'dart:convert';
import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart' as location_package;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:http/http.dart' as http;
import 'package:jasaivoy_driver/pages/conductorapartado.dart';
import 'package:jasaivoy_driver/pages/Viajesregistradosconductor.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AuthModel(),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: HomeScreen(token: ''),
      ),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  late GoogleMapController _mapController;
  location_package.Location location = location_package.Location();
  LatLng? _currentLatLng;
  LatLng? _startLatLng;
  LatLng? _destinationLatLng;
  Marker? _startMarker;
  Marker? _destinationMarker;
  Polyline? _routePolyline;
  Polyline? _routeToDestination;
  StreamSubscription<geolocator.Position>? _positionStream;
  DateTime tripStartTime = DateTime.now();
  late IO.Socket socket;
  bool isTripStarted = false;
  String? _passengerId;
  final String apiKey = "AIzaSyABT2XqfABLKZHWlxg_IF412hYYOqZWYAk";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initializeSocket();
      await _checkLocationPermission();
      await _getCurrentLocation();
      _startLocationUpdates();
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    socket.dispose();
    super.dispose();
  }

  Future<void> _initializeSocket() async {
    socket = IO.io('http://35.175.159.211:4000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.onConnect((_) {
      print('Conectado al servidor WebSocket');
    });

    socket.on('newRideRequest', (data) {
      print('Nueva solicitud de viaje recibida: $data');
      _showRideRequestDialog(data);
    });

    socket.onDisconnect((_) {
      print('Desconectado del servidor WebSocket');
    });
  }

  Future<void> _checkLocationPermission() async {
    location_package.PermissionStatus permission =
        await location.hasPermission();
    if (permission == location_package.PermissionStatus.denied) {
      permission = await location.requestPermission();
    }

    if (permission == location_package.PermissionStatus.granted) {
      final currentLocation = await location.getLocation();
      setState(() {
        _currentLatLng =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Se requiere acceso a la ubicación para continuar.'),
        ),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      location_package.LocationData currentLocation =
          await location.getLocation();
      if (mounted) {
        setState(() {
          _currentLatLng =
              LatLng(currentLocation.latitude!, currentLocation.longitude!);
        });
      }
    } catch (e) {
      print('Error al obtener la ubicación actual: $e');
    }
  }

  void _updatePolyline() {
    if (_currentLatLng == null || _routePolyline == null) return;

    final remainingPoints = <LatLng>[];

    for (var point in _routePolyline!.points) {
      final distance = _calculateDistance(_currentLatLng!, point);
      if (distance > 30) {
        // Elimina puntos alcanzados si están dentro de 30 metros
        remainingPoints.add(point);
      }
    }

    setState(() {
      if (remainingPoints.isNotEmpty) {
        _routePolyline = Polyline(
          polylineId: const PolylineId('route_to_start'),
          points: remainingPoints,
          color: Colors.blue,
          width: 5,
        );
      } else {
        _routePolyline =
            null; // Si no hay puntos restantes, elimina la polilínea
      }
    });
  }

  double _calculateDistance(LatLng point1, LatLng point2) {
    const double radiusEarth = 6371e3; // Radio de la Tierra en metros
    final double lat1 = point1.latitude * (math.pi / 180);
    final double lat2 = point2.latitude * (math.pi / 180);
    final double deltaLat =
        (point2.latitude - point1.latitude) * (math.pi / 180);
    final double deltaLon =
        (point2.longitude - point1.longitude) * (math.pi / 180);

    final double a = (math.sin(deltaLat / 2) * math.sin(deltaLat / 2)) +
        (math.cos(lat1) *
            math.cos(lat2) *
            math.sin(deltaLon / 2) *
            math.sin(deltaLon / 2));
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return radiusEarth * c;
  }

  void _startLocationUpdates() {
    _positionStream = geolocator.Geolocator.getPositionStream(
      locationSettings: const geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
      ),
    ).listen((geolocator.Position position) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
        _updatePolyline(); // Aquí actualizamos la polilínea cuando hay una nueva posición
      });
    });
  }

  void _showRideRequestDialog(dynamic data) {
    if (data == null) return;

    setState(() {
      _startLatLng =
          LatLng(data['start']['latitude'], data['start']['longitude']);
      _destinationLatLng = LatLng(
          data['destination']['latitude'], data['destination']['longitude']);
      _startMarker = Marker(
        markerId: const MarkerId('start'),
        position: _startLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      );
      _destinationMarker = Marker(
        markerId: const MarkerId('destination'),
        position: _destinationLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
    });

    _drawRouteToStart();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nueva solicitud de viaje'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Nombre de Pasajero: ${data['passengerName']}\nNumero de Pasajero: ${data['phoneNumber']}',
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                width: double.infinity,
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _startLatLng ?? const LatLng(0, 0),
                    zoom: 12.0,
                  ),
                  markers: {
                    if (_startMarker != null) _startMarker!,
                    if (_destinationMarker != null) _destinationMarker!,
                  },
                  polylines: {
                    if (_routePolyline != null) _routePolyline!,
                  },
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Has rechazado el viaje.')),
                );
              },
              child: const Text('Rechazar'),
            ),
            TextButton(
              onPressed: () {
                _acceptRideRequest(data);
                Navigator.pop(context);
              },
              child: const Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  void _acceptRideRequest(dynamic data) {
    if (_currentLatLng == null) return;

    final authModel = Provider.of<AuthModel>(context, listen: false);
    final driverName = authModel.currentUser?.nombre ?? "Nombre desconocido";
    final driverPhone = authModel.currentUser?.telefono ?? "Número desconocido";
    final driverMatricula =
        authModel.currentUser?.matricula ?? "Matrícula desconocida";

    setState(() {
      _startLatLng =
          LatLng(data['start']['latitude'], data['start']['longitude']);
      _destinationLatLng = LatLng(
          data['destination']['latitude'], data['destination']['longitude']);
      _passengerId = data['passengerId']; // Guardar el passengerId
      isTripStarted = true;
    });

    _drawRouteToStart();

    // Emitir al servidor que el viaje ha sido aceptado
    socket.emit('acceptRide', {
      'rideId': data['rideId'],
      'passengerId': data['passengerId'], // Pasajero para notificar
      'driverLocation': {
        'latitude': _currentLatLng?.latitude,
        'longitude': _currentLatLng?.longitude,
      },
      'driverInfo': {
        'name': driverName,
        'phone': driverPhone,
        'matricula': driverMatricula,
      },
    });

    print("Viaje aceptado con passengerId: $_passengerId");
  }

  Future<void> _drawRouteToStart() async {
    if (_currentLatLng == null || _startLatLng == null) return;

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${_currentLatLng!.latitude},${_currentLatLng!.longitude}&"
      "destination=${_startLatLng!.latitude},${_startLatLng!.longitude}&"
      "key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        final polylineCoordinates = _decodePolyline(polylinePoints);

        setState(() {
          _routePolyline = Polyline(
            polylineId: const PolylineId('route_to_start'),
            points: polylineCoordinates,
            color: Colors.blue,
            width: 5,
          );
        });
      }
    }
  }

  Future<void> _drawRouteToDestination() async {
    if (_startLatLng == null || _destinationLatLng == null) return;

    final url = Uri.parse(
      "https://maps.googleapis.com/maps/api/directions/json?"
      "origin=${_startLatLng!.latitude},${_startLatLng!.longitude}&"
      "destination=${_destinationLatLng!.latitude},${_destinationLatLng!.longitude}&"
      "key=$apiKey",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['routes'].isNotEmpty) {
        final polylinePoints = data['routes'][0]['overview_polyline']['points'];
        final polylineCoordinates = _decodePolyline(polylinePoints);

        setState(() {
          _routeToDestination = Polyline(
            polylineId: const PolylineId('route_to_destination'),
            points: polylineCoordinates,
            color: Colors.red,
            width: 5,
          );
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return points;
  }

  void _endTrip() {
    if (isTripStarted && _passengerId != null) {
      final tripEndTime = DateTime.now();
      final tripDuration = tripEndTime.difference(tripStartTime);

      // Emitimos el mensaje al servidor
      socket.emit('tripEnded', {
        'message': 'Viaje finalizado',
        'duration': tripDuration.inMinutes, // Duración en minutos
        'passengerId': _passengerId, // Usamos el passengerId almacenado
        'details': {
          'start': {
            'latitude': _startLatLng?.latitude,
            'longitude': _startLatLng?.longitude,
          },
          'destination': {
            'latitude': _destinationLatLng?.latitude,
            'longitude': _destinationLatLng?.longitude,
          },
        },
      });

      print("Emitido tripEnded con passengerId: $_passengerId");

      setState(() {
        _routeToDestination = null;
        _routePolyline = null;
        _startLatLng = null;
        _destinationLatLng = null;
        _startMarker = null;
        _destinationMarker = null;
        isTripStarted = false;
        _passengerId =
            null; // Limpiamos el passengerId después de finalizar el viaje
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El viaje ha finalizado.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'No hay un viaje activo para finalizar o falta el passengerId.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio - Token: ${widget.token}'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: CameraPosition(
              target: _currentLatLng ?? const LatLng(0, 0),
              zoom: 14.0,
            ),
            myLocationEnabled: true,
            markers: {
              if (_startMarker != null) _startMarker!,
              if (_destinationMarker != null) _destinationMarker!,
            },
            polylines: {
              if (_routePolyline != null) _routePolyline!,
              if (_routeToDestination != null) _routeToDestination!,
            },
          ),
          if (_startLatLng != null && _destinationLatLng != null)
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Inicio: $_startLatLng\nDestino: $_destinationLatLng',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _drawRouteToDestination,
                            child: const Text('Iniciar recorrido'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              print(
                                  "isTripStarted: $isTripStarted, _passengerId: $_passengerId");
                              _endTrip();
                            },
                            child: const Text('Finalizar viaje'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
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

          // Maneja la redirección con if
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraphScreen()),
            );
          } else if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const GraphScreen()),
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
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          }
        },
        showSelectedLabels: false,
        showUnselectedLabels: false,
      ),
    );
  }
}
