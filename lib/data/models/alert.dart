import 'package:equatable/equatable.dart';

enum AlertType { outageDetected, outageResolved, systemUpdate, info }

class Alert extends Equatable {
  final String id;
  final String title;
  final String message;
  final AlertType type;
  final String? outageId;
  final DateTime createdAt;
  final bool isRead;

  const Alert({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.outageId,
    required this.createdAt,
    this.isRead = false,
  });

  Alert copyWith({
    String? id,
    String? title,
    String? message,
    AlertType? type,
    String? outageId,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return Alert(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      outageId: outageId ?? this.outageId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      type: AlertType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AlertType.info,
      ),
      outageId: json['outageId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'outageId': outageId,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  @override
  List<Object?> get props => [id, title, message, type, outageId, createdAt, isRead];
}
