import 'package:http/http.dart' as http;

class AuthService {
  final String apiUrl = 'https://tu-backend.com/api';

  Future<void> login(String email, String password) async {
    final response = await http.post('$apiUrl/auth/login', body: {
      'email': email,
      'password': password,
    });
    // Manejar la respuesta
  }
}