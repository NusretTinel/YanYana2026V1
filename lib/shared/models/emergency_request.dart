import 'package:latlong2/latlong.dart';

/// Emergency or safe-call request (local MVP; future Firestore `emergency_requests`).
class EmergencyRequest {
  final String id;
  final String userId;
  final String userName;
  final String type;
  final String status;
  final String? location;
  final String? trustedContactName;
  final DateTime createdAt;

  const EmergencyRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.type,
    required this.status,
    this.location,
    this.trustedContactName,
    required this.createdAt,
  });

  /// Requests with location stay on the map for this duration (MVP).
  static const mapDisplayDuration = Duration(hours: 24);

  LatLng? get latLng {
    final raw = location;
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split(',');
    if (parts.length != 2) return null;
    final lat = double.tryParse(parts[0].trim());
    final lon = double.tryParse(parts[1].trim());
    if (lat == null || lon == null) return null;
    return LatLng(lat, lon);
  }

  bool get hasMapLocation => latLng != null;

  bool get isVisibleOnMap {
    if (!hasMapLocation) return false;
    if (status == 'dismissed' || status == 'cancelled' || status == 'resolved') {
      return false;
    }
    return DateTime.now().difference(createdAt) < mapDisplayDuration;
  }

  String get typeLabel {
    switch (type) {
      case 'sos':
        return 'SOS';
      case 'safe_call':
        return 'Güvenli Destek';
      default:
        return 'Destek';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
      case 'created':
        return 'Beklemede';
      case 'dismissed':
        return 'Kapatıldı';
      case 'resolved':
        return 'Çözüldü';
      default:
        return status;
    }
  }

  EmergencyRequest copyWith({
    String? id,
    String? userId,
    String? userName,
    String? type,
    String? status,
    String? location,
    String? trustedContactName,
    DateTime? createdAt,
  }) {
    return EmergencyRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      type: type ?? this.type,
      status: status ?? this.status,
      location: location ?? this.location,
      trustedContactName: trustedContactName ?? this.trustedContactName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'userName': userName,
        'type': type,
        'status': status,
        'location': location,
        'trustedContactName': trustedContactName,
        'createdAt': createdAt.toIso8601String(),
      };

  factory EmergencyRequest.fromJson(Map<String, dynamic> json) {
    return EmergencyRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? '',
      type: json['type'] as String? ?? 'sos',
      status: json['status'] as String? ?? 'pending',
      location: json['location'] as String?,
      trustedContactName: json['trustedContactName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
