import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart' as geolocator;
import 'package:location/location.dart' as location_package;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:provider/provider.dart';
import 'package:jasaivoy_driver/models/auth_model.dart';
import 'package:http/http.dart' as http;

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

  late IO.Socket socket;
  bool isTripStarted = false;

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

  void _startLocationUpdates() {
    _positionStream = geolocator.Geolocator.getPositionStream(
      locationSettings: const geolocator.LocationSettings(
        accuracy: geolocator.LocationAccuracy.high,
      ),
    ).listen((geolocator.Position position) {
      setState(() {
        _currentLatLng = LatLng(position.latitude, position.longitude);
      });
    });
  }
  void _showRideRequestDialog(dynamic data) {
    if (data == null) return;

    setState(() {
      _startLatLng =
          LatLng(data['start']['latitude'], data['start']['longitude']);
      _destinationLatLng =
          LatLng(data['destination']['latitude'], data['destination']['longitude']);
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
          content: Text(
            'Solicitud desde (${data['start']['latitude']}, ${data['start']['longitude']}) '
            'hasta (${data['destination']['latitude']}, ${data['destination']['longitude']}).',
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

  setState(() {
    _startLatLng = LatLng(data['start']['latitude'], data['start']['longitude']);
    _destinationLatLng =
        LatLng(data['destination']['latitude'], data['destination']['longitude']);
  });

  _drawRouteToStart();

  // Emitir al servidor que el viaje ha sido aceptado
  socket.emit('acceptRide', {
    'rideId': data['rideId'], // Asegúrate de enviar el rideId recibido
    'passengerId': data['passengerId'], // Pasajero para notificar
    'driverLocation': {
      'latitude': _currentLatLng?.latitude,
      'longitude': _currentLatLng?.longitude,
    },
    'driverInfo': {
      'name': driverName,
      'phone': driverPhone,
    },
  });
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
    setState(() {
      _routeToDestination = null;
      _routePolyline = null;
      _startLatLng = null;
      _destinationLatLng = null;
      _startMarker = null;
      _destinationMarker = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El viaje ha finalizado.')),
    );
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
                            onPressed: _endTrip,
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
    );
  }
}

