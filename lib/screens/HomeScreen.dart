import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'profile') {
                Navigator.pushNamed(context, '/profile');
              } else if (value == 'logout') {
                // Lógica para cerrar sesión
                print('Cerrar sesión');
              } else if (value == 'item') {
                print('Ítem seleccionado');
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 'profile', child: Text('Perfil')),
                PopupMenuItem(value: 'logout', child: Text('Cerrar sesión')),
                PopupMenuItem(value: 'item', child: Text('Ítem')),
              ];
            },
            icon: CircleAvatar(
              backgroundImage: AssetImage(
                'assets/profile.png',
              ), // Ruta de la imagen de perfil
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/emergency-history');
              },
              child: Text(
                'Ver historial de emergencias',
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
            ),
            SizedBox(height: 120),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/request-emergency');
              },
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.all(20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.phone, size: 50),
                  SizedBox(height: 15),
                  Text('Emergencia!!', style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
