import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service class to interact with the OpenRouteService API
class RouteOptimizerService {
  /// API key stored securely (preferably in environment variables or secure storage)
  /// Do not hard-code in production!
  final String apiKey;
  final String baseUrl = 'https://api.openrouteservice.org/v2';

  RouteOptimizerService({required this.apiKey});

  /// Calculate distance/duration matrix between multiple locations
  /// [locations] must be a list of [longitude, latitude] pairs
  Future<Map<String, dynamic>> getDistanceMatrix(List<List<double>> locations) async {
    final url = Uri.parse('$baseUrl/matrix/driving-car');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'locations': locations,
          'metrics': ['distance', 'duration'],
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get distance matrix: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error accessing OpenRouteService: $e');
    }
  }

  /// Get detailed directions between multiple waypoints
  /// [coordinates] must be a list of [longitude, latitude] pairs
  Future<Map<String, dynamic>> getDirections(List<List<double>> coordinates) async {
    final url = Uri.parse('$baseUrl/directions/driving-car');
    
    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': apiKey,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'coordinates': coordinates,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get directions: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error accessing OpenRouteService: $e');
    }
  }

  /// Forward geocoding - convert place names to coordinates
  Future<Map<String, dynamic>> geocode(String placeName) async {
    final encodedPlace = Uri.encodeComponent(placeName);
    final url = Uri.parse('$baseUrl/geocode/search?api_key=$apiKey&text=$encodedPlace');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to geocode: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Error accessing OpenRouteService geocoding: $e');
    }
  }
}
