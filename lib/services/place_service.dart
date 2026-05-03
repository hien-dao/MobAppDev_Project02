import 'dart:convert';
import 'package:http/http.dart' as http;

class PlaceService {
  Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      "https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5",
    );

    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'TripPlannerApp/1.0', // required by OSM
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch places');
    }

    final data = jsonDecode(response.body) as List;

    return data.map((item) {
      return {
        'name': item['display_name'],
        'lat': double.parse(item['lat']),
        'lon': double.parse(item['lon']),
      };
    }).toList();
  }
}