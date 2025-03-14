import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RequestAmbulanceScreen extends StatefulWidget {
  @override
  _RequestAmbulanceScreenState createState() => _RequestAmbulanceScreenState();
}

class _RequestAmbulanceScreenState extends State<RequestAmbulanceScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String? _selectedEmergencyType;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
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
            desiredAccuracy: LocationAccuracy.high);
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _selectedEmergencyType,
                      decoration: InputDecoration(
                        labelText: 'Tipo de emergencia',
                        border: OutlineInputBorder(),
                      ),
                      items: List.generate(
                        5,
                            (index) => DropdownMenuItem(
                          value: '${index + 1}',
                          child: Text('Emergencia ${index + 1}'),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          _selectedEmergencyType = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Ubicación actual: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        _isLoadingLocation
                            ? CircularProgressIndicator()
                            : Text(
                          _currentPosition != null
                              ? 'Lat: ${_currentPosition!.latitude}, Long: ${_currentPosition!.longitude}'
                              : 'No disponible',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                    Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Acción de solicitar
                          },
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
              ),
            ),
          ),
        ],
      ),
    );
  }
}
