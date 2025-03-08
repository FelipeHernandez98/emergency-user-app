import 'package:http/http.dart' as http;

class AmbulanceService {
  final String apiUrl = 'https://tu-backend.com/api';

  Future<List<Ambulance>> getAmbulances() async {
    final response = await http.get('$apiUrl/ambulances');
    // Convertir la respuesta a una lista de ambulancias
  }
}
