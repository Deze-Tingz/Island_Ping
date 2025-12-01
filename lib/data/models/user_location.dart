import 'package:equatable/equatable.dart';

class UserLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? area;
  final String? city;
  final String? country;
  final DateTime timestamp;

  const UserLocation({
    required this.latitude,
    required this.longitude,
    this.area,
    this.city,
    this.country,
    required this.timestamp,
  });

  factory UserLocation.fromJson(Map<String, dynamic> json) {
    return UserLocation(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      area: json['area'] as String?,
      city: json['city'] as String?,
      country: json['country'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'area': area,
      'city': city,
      'country': country,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  String get displayLocation {
    if (area != null && city != null) {
      return '$area, $city';
    } else if (city != null) {
      return city!;
    } else if (area != null) {
      return area!;
    }
    return 'Unknown Location';
  }

  @override
  List<Object?> get props => [latitude, longitude, area, city, country, timestamp];
}
