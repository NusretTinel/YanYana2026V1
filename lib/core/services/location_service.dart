import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// GPS / permission wrapper for the map module.
class LocationService {
  const LocationService();

  static const LatLng defaultCenter = LatLng(39.9208, 32.8541); // Ankara

  Future<bool> isServiceEnabled() => Geolocator.isLocationServiceEnabled();

  Future<LocationPermission> checkPermission() => Geolocator.checkPermission();

  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  /// Returns current position or throws [LocationFailure].
  Future<LatLng> getCurrentPosition() async {
    final enabled = await isServiceEnabled();
    if (!enabled) {
      throw const LocationFailure(
        'Konum servisi kapalı. Lütfen cihaz ayarlarından GPS\'i açın.',
      );
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationFailure(
        'Konum izni verilmedi. Haritada konumunuzu göstermek için izin gerekir.',
      );
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationFailure(
        'Konum izni kalıcı olarak reddedildi. Ayarlardan izin verebilirsiniz.',
      );
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    return LatLng(pos.latitude, pos.longitude);
  }
}

class LocationFailure implements Exception {
  const LocationFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
