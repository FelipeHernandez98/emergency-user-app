import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;

class RequestAmbulanceScreen extends StatefulWidget {
  @override
  _RequestAmbulanceScreenState createState() => _RequestAmbulanceScreenState();
}

class _RequestAmbulanceScreenState extends State<RequestAmbulanceScreen> {
  final _formKey = GlobalKey<FormState>();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int? _selectedEmergencyType;
  Position? _currentPosition;
  bool _isLoadingLocation = false;
  bool _isLoading = false;
  IO.Socket? _socket;
  String? _emergencyId;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeSocket();
  }

  @override
  void dispose() {
    _socket?.disconnect();
    super.dispose();
  }

  void _initializeSocket() {
    _socket = IO.io('http://localhost:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    _socket?.on('connect', (_) {
      print('Conectado al servidor de WebSocket');
    });

    _socket?.on('emergencyReceived', (data) {
      print("Evento recibido: $data");

      // Asegúrate de que `data` es un Map y procesa sus valores
      if (data is Map<String, dynamic>) {
        String emergencyId = data['emergencyId'] ?? '';
        String ambulanceId = data['ambulanceId'] ?? '';

        // Comparar con `_emergencyId`
        if (emergencyId == _emergencyId) {
          setState(() {
            _statusMessage = "Ambulancia asignada. Está en camino.";
          });
        }
      } else {
        print("Formato inesperado: $data");
      }
    });

    // Escuchar el evento `locationUpdated`
    _socket?.on('locationUpdated', (data) {
      print("Location updated: $data");
      if (data != null && data is Map<String, dynamic>) {
        final ambulanceId = data['ambulanceId'];
        final location = data['location'];
        final latitude = location['latitude'];
        final longitude = location['longitude'];
        setState(() {
        _statusMessage =
            "La ubicación de la ambulancia $ambulanceId es: $latitude y $longitude";
        });
      }
    });

    _socket?.on('disconnect', (_) {
      print('Desconectado del servidor de WebSocket');
    });
  }

  Future<void> _requestAmbulance() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');

      if (accessToken == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: No se encontró el token de acceso.')),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final response = await http.post(
        Uri.parse('http://localhost:3000/api/v1/emergency'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'idUser': 'd94c72fd-9337-422f-8ac7-0e4d8bb47743',
          'idType': _selectedEmergencyType, // Asegúrate de que sea int
          'location': jsonEncode({
            'latitude': _currentPosition!.latitude,
            'longitude': _currentPosition!.longitude,
          }),
          'idStatus': 1, // Se envía como número
        }),
      );

      if (response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print(responseData['id']);
        setState(() {
          _emergencyId = responseData['id'];
          _statusMessage =
              "Solicitud enviada. Esperando asignación de ambulancia...";
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error de red: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _currentPosition = position;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo obtener permiso de ubicación.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener la ubicación: $e')),
      );
    } finally {
      setState(() {
        _isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openEndDrawer();
            },
          ),
        ],
      ),
      endDrawer: Drawer(
        width: MediaQuery.of(context).size.width * 0.3,
        shape: RoundedRectangleBorder(),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.grey),
              child: SizedBox(
                height: 50,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/perfil.jpg'),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Tu Nombre',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Ítem'),
              onTap: () {
                Navigator.pop(context);
                print('Ítem seleccionado');
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('access_token');
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Fondo (puedes añadir un mapa, imagen, o color aquí)
          Container(
            color: Colors.white, // Color de fondo
          ),

          // Formulario flotante en la parte inferior
          Align(
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.4, // Ajusta el porcentaje de altura aquí (40%)
              widthFactor: 1.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.all(16.0),
                child:
                    _statusMessage == null
                        ? Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<int>(
                                value: _selectedEmergencyType,
                                decoration: InputDecoration(
                                  labelText: 'Tipo de emergencia',
                                  border: OutlineInputBorder(),
                                ),
                                items: List.generate(
                                  5,
                                  (index) => DropdownMenuItem(
                                    value: index + 1,
                                    child: Text('Emergencia ${index + 1}'),
                                  ),
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedEmergencyType = value;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Selecciona un tipo de emergencia';
                                  }
                                  return null;
                                },
                              ),
                              SizedBox(height: 16),
                              Row(
                                children: [
                                  Text(
                                    'Ubicación actual: ',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  _isLoadingLocation
                                      ? CircularProgressIndicator()
                                      : Text(
                                        _currentPosition != null
                                            ? 'Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}'
                                            : 'No disponible',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                ],
                              ),
                              Spacer(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  ElevatedButton(
                                    onPressed: _requestAmbulance,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                    ),
                                    child: Text('Solicitar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    child: Text('Cancelar'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                        : Center(
                          child: Text(
                            _statusMessage!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[800],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
