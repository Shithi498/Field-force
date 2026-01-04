// journey_model.dart
import 'package:latlong2/latlong.dart' as ll;


class JourneyCheckEvent {
  final String type;
  final DateTime timestamp;
  final ll.LatLng location;
  final String address;
  final bool isAuto;

  JourneyCheckEvent({
    required this.type,
    required this.timestamp,
    required this.location,
    required this.address, required this.isAuto,
  });

  factory JourneyCheckEvent.fromJson(Map<String, dynamic> json) {
    return JourneyCheckEvent(
      type: json['type'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      location: ll.LatLng(
        (json['lat'] as num).toDouble(),
        (json['lng'] as num).toDouble(),
      ),
      address: json['address'] as String? ?? '',
      isAuto: json['isAuto'] as bool? ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'timestamp': timestamp.toIso8601String(),
      'lat': location.latitude,
      'lng': location.longitude,
      'address': address,
      'isAuto' : isAuto
    };
  }
}


class Journey {
  final String? id;
  final ll.LatLng startLocation;
  final ll.LatLng? endLocation;
  final String startAddress;
  final String? endAddress;
  final double? distanceInMeters;
  final List<JourneyCheckEvent> events;
  final DateTime startedAt;
  final DateTime? endedAt;

  Journey({
    this.id,
    required this.startLocation,
    this.endLocation,
    required this.startAddress,
    this.endAddress,
    this.distanceInMeters,
    required this.events,
    required this.startedAt,
    this.endedAt,
  });

  Journey copyWith({
    String? id,
    ll.LatLng? startLocation,
    ll.LatLng? endLocation,
    String? startAddress,
    String? endAddress,
    double? distanceInMeters,
    List<JourneyCheckEvent>? events,
    DateTime? startedAt,
    DateTime? endedAt,
  }) {
    return Journey(
      id: id ?? this.id,
      startLocation: startLocation ?? this.startLocation,
      endLocation: endLocation ?? this.endLocation,
      startAddress: startAddress ?? this.startAddress,
      endAddress: endAddress ?? this.endAddress,
      distanceInMeters: distanceInMeters ?? this.distanceInMeters,
      events: events ?? this.events,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  factory Journey.fromJson(Map<String, dynamic> json) {
    return Journey(
      id: json['id']?.toString(),
      startLocation: ll.LatLng(
        (json['start_lat'] as num).toDouble(),
        (json['start_lng'] as num).toDouble(),
      ),
      endLocation: (json['end_lat'] != null && json['end_lng'] != null)
          ? ll.LatLng(
        (json['end_lat'] as num).toDouble(),
        (json['end_lng'] as num).toDouble(),
      )
          : null,
      startAddress: json['start_address'] as String? ?? '',
      endAddress: json['end_address'] as String?,
      distanceInMeters: json['distance_in_meters'] != null
          ? (json['distance_in_meters'] as num).toDouble()
          : null,
      events: (json['events'] as List<dynamic>? ?? [])
          .map((e) => JourneyCheckEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['started_at'] as String),
      endedAt: json['ended_at'] != null
          ? DateTime.parse(json['ended_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'start_lat': startLocation.latitude,
      'start_lng': startLocation.longitude,
      'end_lat': endLocation?.latitude,
      'end_lng': endLocation?.longitude,
      'start_address': startAddress,
      'end_address': endAddress,
      'distance_in_meters': distanceInMeters,
      'events': events.map((e) => e.toJson()).toList(),
      'started_at': startedAt.toIso8601String(),
      'ended_at': endedAt?.toIso8601String(),
    };
  }
}
