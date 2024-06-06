import 'package:shamsi_date/shamsi_date.dart';

class DeviceLocation{

  DeviceLocation({
    required this.fixTime,
    required this.longitude,
    required this.latitude,
    required this.speed,
    required this.driver,
    required this.attributes
  });

  String fixTime;
  String longitude;
  String latitude;
  String speed;
  String driver;
  String attributes;

  factory DeviceLocation.fromMap( Map<String , dynamic> json) {

    String speed =(double.parse(json["speed"])*1.852).round().toString();

    DateTime dateTime = DateTime.parse(json["fixtime"]);
    dateTime = dateTime.add(Duration(hours: 3,minutes: 30));
    final jalaliDateTime =  dateTime.toJalali();

    String dateTimeJalali = "${jalaliDateTime.year}/${jalaliDateTime.month}/${jalaliDateTime.day}  "
        "${jalaliDateTime.hour}:${jalaliDateTime.minute}:${jalaliDateTime.second}";


    return DeviceLocation(
      fixTime: (dateTimeJalali),
      longitude: (json["longitude"] ?? ""),
      latitude: (json["latitude"] ?? ""),
      speed: (speed ?? ""),
      driver: (json["driver"] ?? "نامشخص"),
      attributes: (json["attributes"] ?? ""),
    );
  }

  Map<String , dynamic> toMap() => {
    "fixtime":fixTime,
    "longitude":longitude,
    "latitude":latitude,
    "speed":speed,
    "driver":driver,
    "attributes":attributes
  };
}