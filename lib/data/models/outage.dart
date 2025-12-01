import 'package:equatable/equatable.dart';

enum OutageStatus { active, resolved, investigating }

enum OutageSeverity { minor, moderate, major, critical }

class Outage extends Equatable {
  final String id;
  final String title;
  final String description;
  final String area;
  final double latitude;
  final double longitude;
  final double radiusKm;
  final OutageStatus status;
  final OutageSeverity severity;
  final String telecomProvider;
  final DateTime reportedAt;
  final DateTime? resolvedAt;
  final int affectedUsers;

  const Outage({
    required this.id,
    required this.title,
    required this.description,
    required this.area,
    required this.latitude,
    required this.longitude,
    required this.radiusKm,
    required this.status,
    required this.severity,
    required this.telecomProvider,
    required this.reportedAt,
    this.resolvedAt,
    this.affectedUsers = 0,
  });

  bool get isActive => status == OutageStatus.active;

  factory Outage.fromJson(Map<String, dynamic> json) {
    return Outage(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      area: json['area'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      radiusKm: (json['radiusKm'] as num).toDouble(),
      status: OutageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => OutageStatus.active,
      ),
      severity: OutageSeverity.values.firstWhere(
        (e) => e.name == json['severity'],
        orElse: () => OutageSeverity.moderate,
      ),
      telecomProvider: json['telecomProvider'] as String,
      reportedAt: DateTime.parse(json['reportedAt'] as String),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.parse(json['resolvedAt'] as String)
          : null,
      affectedUsers: json['affectedUsers'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'area': area,
      'latitude': latitude,
      'longitude': longitude,
      'radiusKm': radiusKm,
      'status': status.name,
      'severity': severity.name,
      'telecomProvider': telecomProvider,
      'reportedAt': reportedAt.toIso8601String(),
      'resolvedAt': resolvedAt?.toIso8601String(),
      'affectedUsers': affectedUsers,
    };
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        area,
        latitude,
        longitude,
        radiusKm,
        status,
        severity,
        telecomProvider,
        reportedAt,
        resolvedAt,
        affectedUsers,
      ];
}
