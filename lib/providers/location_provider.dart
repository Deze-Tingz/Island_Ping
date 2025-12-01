import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/user_location.dart';
import '../data/services/location_service.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService();
  ref.onDispose(() => service.dispose());
  return service;
});

final currentLocationProvider = FutureProvider<UserLocation?>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.getCurrentLocation();
});

final locationStreamProvider = StreamProvider<UserLocation>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.locationStream;
});

final locationPermissionProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(locationServiceProvider);
  return await service.checkPermission();
});
