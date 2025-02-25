
import 'package:shamsi_date/shamsi_date.dart';

class LastStatusReport{

  LastStatusReport({
    required this.isSuccess,
    required this.message,
    required this.devices,


  });

  bool isSuccess;
  String message;
  List<DeviceList> devices;


  factory LastStatusReport.fromMap( Map<String , dynamic> json) {



    return LastStatusReport(
      isSuccess: (json["isSuccess"] ?? false),
      message: (json["message"] ?? ""),
      devices:  json["deviceList"].map<DeviceList>( (json) =>  DeviceList.fromMap(json)).toList(),
    );
  }


}

class DeviceList{

  DeviceList({
    required this.deviceName,
    required this.groupName,
    required this.driverName,
    required this.fixTime,
    required this.latitude,
    required this.longitude,
    required this.odometer


  });

  String deviceName;
  String groupName;
  String driverName;
  String fixTime;
  String latitude;
  String longitude;
  int odometer;


  factory DeviceList.fromMap( Map<String , dynamic> json) {

    DateTime fixTime = DateTime.parse(json["fixtime"]);
    fixTime = fixTime.add(Duration(hours: 3,minutes: 30));
    final JalaliFixTime =  fixTime.toJalali();
    String fixTimeJalali = "${JalaliFixTime.year}/${JalaliFixTime.month}/${JalaliFixTime.day}  "
        "${JalaliFixTime.hour}:${JalaliFixTime.minute}:${JalaliFixTime.second}";

    return DeviceList(
      deviceName: (json["device_name"] ?? ""),
      groupName: (json["group_name"] ?? ""),
      driverName: (json["driver_name"] ?? ""),
      fixTime: (fixTimeJalali),
      latitude: (json["latitude"] ?? ""),
      longitude: (json["longitude"] ?? ""),
      odometer: (json["odometer"] ?? 0)
    );
  }


}