
class DeviceShow{

  DeviceShow({
    required this.deviceName,
    required this.groupName,
    required this.imei,
    required this.driver
  });

  String deviceName;
  String groupName;
  String imei;
  String driver;



  factory DeviceShow.fromMap( Map<String , dynamic> json) {
    return DeviceShow(
      deviceName: json["deviceName"],
      groupName: (json["groupName"] ?? "No Group"),
      imei: json["IMEI"],
      driver: (json["driver"] ?? ""),
    );
  }

  Map<String , dynamic> toMap() => {
    "deviceName":deviceName,
    "groupName":groupName,
    "imei":imei,
    "driver":driver,
  };
}