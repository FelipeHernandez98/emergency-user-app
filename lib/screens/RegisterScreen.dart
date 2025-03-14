import 'package:emergency_user_app/screens/HomeScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _lastName = TextEditingController();
  final _identificationNumber = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneNumber = TextEditingController();
  final _emergencyContact = TextEditingController();
  bool _isLoading = false;

  final _passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$',
  );

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu correo';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Correo no válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingresa tu contraseña';
    }
    if (!_passwordRegex.hasMatch(value)) {
      return 'La contraseña debe tener al menos 8 caracteres, una mayúscula, una minúscula, un número y un carácter especial';
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cierra el diálogo
              },
              child: Text('Aceptar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse('http://localhost:3000/api/v1/auth/register'),
          headers: {'Accept': 'application/json'},
          body: {
            'name': _name.text,
            'lastname': _lastName.text,
            'identificationNumber': _identificationNumber.text,
            'email': _emailController.text,
            'password': _passwordController.text,
            'phoneNumber': _phoneNumber.text,
            'emergencyContact': _emergencyContact.text,
          },
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 201) {
          final data = json.decode(response.body);
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', data['access_token']);

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => HomeScreen()),
                (Route<dynamic> route) => false,
          );
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: ${response.body}')));
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Error al realizar la solicitud: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registrate')),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Register',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _name,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _lastName,
                  decoration: InputDecoration(
                    labelText: 'Last name',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _identificationNumber,
                  decoration: InputDecoration(
                    labelText: 'Identification number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _phoneNumber,
                  decoration: InputDecoration(
                    labelText: 'Phone number',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emergencyContact,
                  decoration: InputDecoration(
                    labelText: 'Emergency contact',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                _isLoading
                    ? SpinKitFadingCircle(color: Colors.blue)
                    : ElevatedButton(
                      onPressed: _register,
                      child: Text('Registrar'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
