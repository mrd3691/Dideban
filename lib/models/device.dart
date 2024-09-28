
class Device{

  Device({
    required this.id,
    required this.attributes,
    required this.groupId,
    required this.name,
    required this.uniqueId,
    required this.status,
    required this.lastUpdate,
    required this.positionId,
    required this.geofenceIds,
    required this.phone,
    required this.model,
    required this.contact,
    required this.category,
    required this.disabled,
    required this.expirationTime
  });

  int id;
  final attributes;
  int? groupId;
  String name;
  String uniqueId;
  String? status;
  String? lastUpdate;
  int? positionId;
  int? geofenceIds;
  String? phone;
  String? model;
  String? contact;
  String? category;
  bool? disabled;
  String? expirationTime;



  factory Device.fromMap( Map<String , dynamic> json) {
    return Device(
      id: json["id"],
      attributes: json["attributes"],
      groupId: (json["groupId"]),
      name: (json["name"]) ?? "",
      uniqueId: (json["uniqueId"]),
      status: json["status"],
      lastUpdate: json["lastUpdate"],
      positionId: (json["positionId"]),
      geofenceIds: (json["geofenceIds"]),
      phone: (json["phone"]) ?? "",
      model: json["model"] ?? "",
      contact: json["contact"],
      category: (json["category"]),
      disabled: (json["disabled"]),
      expirationTime: (json["expirationTime"]),
    );
  }


  Map<String , dynamic> toMap() => {
    "id": id,
    "attributes": attributes,
    "groupId": groupId,
    "name": name,
    "uniqueId": uniqueId,
    "status": status,
    "lastUpdate": lastUpdate,
    "positionId": positionId,
    "geofenceIds": geofenceIds,
    "phone": phone,
    "model": model,
    "contact": contact,
    "category": category,
    "disabled": disabled,
    "expirationTime": expirationTime,

  };
}