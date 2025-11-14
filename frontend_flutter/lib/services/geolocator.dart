import 'package:geolocator/geolocator.dart';

class GeolocatorServices {
  // Bukannya jadi saingan location malah error
  Future<Position> getLocation() async {
    // final locationResult = await _location.getLocation();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  }

  Future<Position?> handleGetLastKnownPosition() async {
    Position? position = await Geolocator.getLastKnownPosition();

    return position;
  }
}
