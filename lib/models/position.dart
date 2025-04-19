class Position {
  int id;
  PositionAttributes? attributes;
  int deviceId;
  String? protocol;
  DateTime? serverTime;
  DateTime? deviceTime;
  DateTime? fixTime;
  bool? outdated;
  bool? valid;
  double? latitude;
  double? longitude;
  double? altitude;
  double? speed;
  double? course;
  String? address;
  double? accuracy;
  dynamic network;

  Position({
    required this.id,
    required this.attributes,
    required this.deviceId,
    required this.protocol,
    required this.serverTime,
    required this.deviceTime,
    required this.fixTime,
    required this.outdated,
    required this.valid,
    required this.latitude,
    required this.longitude,
    required this.altitude,
    required this.speed,
    required this.course,
    this.address,
    required this.accuracy,
    this.network,
  });

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'],
      attributes: PositionAttributes.fromJson(json['attributes']),
      deviceId: json['deviceId'],
      protocol: json['protocol'] ?? "",
      serverTime: DateTime.parse(json['serverTime']) ,
      deviceTime: DateTime.parse(json['deviceTime']),
      fixTime: DateTime.parse(json['fixTime']),
      outdated: json['outdated'] ?? false,
      valid: json['valid'] ?? true,
      latitude: json['latitude'].toDouble() ?? 0,
      longitude: json['longitude'].toDouble() ?? 0,
      altitude: json['altitude'].toDouble() ?? 0,
      speed: json['speed'].toDouble() ?? 0,
      course: json['course'].toDouble() ?? 0,
      address: json['address'] ?? "",
      accuracy: json['accuracy'].toDouble() ?? 0,
      network: json['network'],
    );
  }


}

class PositionAttributes {
  int? priority;
  int? sat;
  int? event;
  double? distance;
  double? totalDistance;
  bool? motion;
  bool? ignition;
  int? fuelLevel;

  PositionAttributes({
    required this.priority,
    required this.sat,
    required this.event,
    required this.distance,
    required this.totalDistance,
    required this.motion,
    required this.ignition,
    required this.fuelLevel,
  });

  factory PositionAttributes.fromJson(Map<String, dynamic> json) {
    return PositionAttributes(
      priority: json['priority'],
      sat: json['sat'],
      event: json['event'],
      distance: json['distance'].toDouble(),
      totalDistance: json['totalDistance'].toDouble(),
      motion: json['motion'],
      ignition: json['ignition'],
      fuelLevel: (json['io89'] ?? 0)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priority': priority,
      'sat': sat,
      'event': event,
      'distance': distance,
      'totalDistance': totalDistance,
      'motion': motion,
    };
  }
}
