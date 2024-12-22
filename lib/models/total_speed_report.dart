import 'package:shamsi_date/shamsi_date.dart';

class TotalSpeedReport{

  TotalSpeedReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.start_dateTime,
    required this.end_dateTime,
    required this.distance,
    required  this.over_speed_distance,
    required this.max_speed,
    required this.max_speed_latitude,
    required this.max_speed_longitude,
    required this.max_speed_course,
    required this.max_speed_dateTime,
    required this.group
  });

  bool isSuccess;
  String message;
  String device;
  String driver;
  String start_dateTime;
  String end_dateTime;
  int distance;
  int over_speed_distance;
  int max_speed;
  String max_speed_latitude;
  String max_speed_longitude;
  String max_speed_course;
  String max_speed_dateTime;
  String group;

  factory TotalSpeedReport.fromMap( Map<String , dynamic> json) {

    DateTime startDateTime = DateTime.parse(json["start_dateTime"]);
    startDateTime = startDateTime.add(Duration(hours: 3,minutes: 30));
    final startJalaliDateTime =  startDateTime.toJalali();
    String startDateTimeJalali = "${startJalaliDateTime.year}/${startJalaliDateTime.month}/${startJalaliDateTime.day}  "
        "${startJalaliDateTime.hour}:${startJalaliDateTime.minute}:${startJalaliDateTime.second}";

    DateTime endDateTime = DateTime.parse(json["end_dateTime"]);
    endDateTime = endDateTime.add(Duration(hours: 3,minutes: 30));
    final endJalaliDateTime =  endDateTime.toJalali();
    String endDateTimeJalali = "${endJalaliDateTime.year}/${endJalaliDateTime.month}/${endJalaliDateTime.day}  "
        "${endJalaliDateTime.hour}:${endJalaliDateTime.minute}:${endJalaliDateTime.second}";

    DateTime maxSpeedDateTime = DateTime.parse(json["max_speed_dateTime"]);
    maxSpeedDateTime = maxSpeedDateTime.add(Duration(hours: 3,minutes: 30));
    final maxSpeedJalaliDateTime =  maxSpeedDateTime.toJalali();
    String maxSpeedDateTimeJalali = "${maxSpeedJalaliDateTime.year}/${maxSpeedJalaliDateTime.month}/${maxSpeedJalaliDateTime.day}  "
        "${maxSpeedJalaliDateTime.hour}:${maxSpeedJalaliDateTime.minute}:${maxSpeedJalaliDateTime.second}";

    int distance = json["distance"];
    distance = (distance/1000).round();

    int overSpeedDistance = json["over_speed_distance"];
    overSpeedDistance = (overSpeedDistance/1000).round();


    return TotalSpeedReport(
      isSuccess: (json["isSuccess"] ?? false),
      message: (json["message"] ?? ""),
      device: (json["device"] ?? ""),
      driver: (json["driver"] ?? ""),
      start_dateTime: (startDateTimeJalali),
      end_dateTime: (endDateTimeJalali),
      distance: (distance),
      over_speed_distance: (overSpeedDistance),
      max_speed: (json["max_speed"] ?? 0),
      max_speed_latitude: (json["max_speed_latitude"] ?? ""),
      max_speed_longitude: (json["max_speed_longitude"] ?? ""),
      max_speed_course: (json["max_speed_course"] ?? ""),
      max_speed_dateTime: (maxSpeedDateTimeJalali),
      group: (json["group"] ?? ""),
    );
  }


}