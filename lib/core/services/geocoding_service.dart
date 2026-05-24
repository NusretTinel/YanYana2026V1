import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingResult {
  const GeocodingResult({
    required this.displayName,
    required this.latitude,
    required this.longitude,
    required this.kind,
  });

  final String displayName;
  final double latitude;
  final double longitude;
  final String kind;

  LatLng get latLng => LatLng(latitude, longitude);
}

/// OpenStreetMap Nominatim — semt/mahalle/şehir araması (ücretsiz, API anahtarı yok).
class GeocodingService {
  const GeocodingService();

  static const _userAgent = 'YanYana/1.0 (Flutter accessibility map)';

  Future<List<GeocodingResult>> searchLocations(
    String query, {
    int limit = 6,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      {
        'q': '$q, Türkiye',
        'format': 'json',
        'limit': '$limit',
        'countrycodes': 'tr',
        'addressdetails': '1',
      },
    );

    final response = await http.get(
      uri,
      headers: const {'User-Agent': _userAgent},
    );

    if (response.statusCode != 200) {
      throw Exception('Konum araması başarısız (${response.statusCode})');
    }

    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((raw) {
      final item = raw as Map<String, dynamic>;
      final name = item['display_name'] as String? ?? q;
      final lat = double.parse(item['lat'] as String);
      final lon = double.parse(item['lon'] as String);
      final type = item['type'] as String? ?? '';
      final category = item['class'] as String? ?? '';
      return GeocodingResult(
        displayName: name,
        latitude: lat,
        longitude: lon,
        kind: type.isNotEmpty ? type : category,
      );
    }).toList();
  }
}
