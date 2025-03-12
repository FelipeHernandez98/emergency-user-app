import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  // Expresión regular para validar la contraseña
  final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  // Función para validar el correo
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Correo no válido';
    }
    return null;
  }

  // Función para validar la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial';
    }
    return null;
  }

  // Función para enviar la petición de inicio de sesión
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final response = await http.post(
        Uri.parse('https://tu-backend.com/api/auth/login'),
        body: {
          'email': _emailController.text,
          'password': _passwordController.text,
        },
      );

      setState(() {
        _isLoading = false;
      });

      if (response.statusCode == 200) {
        // Manejar la respuesta exitosa
        final data = json.decode(response.body);
        print('Login exitoso: ${data['token']}');
        // Navegar a la pantalla principal
      } else {
        // Manejar el error
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Iniciar Sesión',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                SizedBox(height: 20),
                _isLoading
                    ? SpinKitFadingCircle(color: Colors.blue)
                    : ElevatedButton(
                      onPressed: _login,
                      child: Text('Ingresar'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    // Navegar a la pantalla de registro
                    Navigator.pushNamed(context, '/register');
                  },
                  child: Text('¿No tienes cuenta? Regístrate'),
                ),
                TextButton(
                  onPressed: () {
                    // Navegar a la pantalla de recuperación de contraseña
                    Navigator.pushNamed(context, '/forgot-password');
                  },
                  child: Text('¿Olvidaste la contraseña?'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
