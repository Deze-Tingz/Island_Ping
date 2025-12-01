import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../models/user_location.dart';

class LocationService {
  UserLocation? _currentLocation;
  UserLocation? get currentLocation => _currentLocation;

  final _locationController = StreamController<UserLocation>.broadcast();
  Stream<UserLocation> get locationStream => _locationController.stream;

  Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  Future<UserLocation?> getCurrentLocation() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) {
      return null;
    }

    try {
      // Use low accuracy for privacy (approximate location only)
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low, // ~1km accuracy for privacy
      );

      // Get area name from coordinates
      String? area;
      String? city;
      String? country;

      try {
        final placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;
          area = place.subLocality ?? place.locality;
          city = place.locality ?? place.administrativeArea;
          country = place.country;
        }
      } catch (_) {
        // Geocoding failed, continue without area name
      }

      _currentLocation = UserLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        area: area,
        city: city,
        country: country,
        timestamp: DateTime.now(),
      );

      _locationController.add(_currentLocation!);
      return _currentLocation;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _locationController.close();
  }
}
