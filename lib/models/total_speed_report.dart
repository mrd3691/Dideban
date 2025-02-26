import 'package:shamsi_date/shamsi_date.dart';

class TotalSpeedReport{

  TotalSpeedReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.group,
    required this.start_dateTime,
    required this.end_dateTime,
    required this.distance,
    required  this.over_speed_distance,
    required this.max_speed,
    required this.max_speed_latitude,
    required this.max_speed_longitude,
    required this.max_speed_course,
    required this.max_speed_dateTime,
    required this.driving_time,
    required this.unValid_records

  });

  bool isSuccess;
  String message;
  String device;
  String driver;
  String group;
  String start_dateTime;
  String end_dateTime;
  int distance;
  int over_speed_distance;
  int max_speed;
  String max_speed_latitude;
  String max_speed_longitude;
  String max_speed_course;
  String max_speed_dateTime;
  int driving_time;
  int unValid_records;


  factory TotalSpeedReport.fromMap( Map<String , dynamic> json) {

    bool isSuccess= json["isSuccess"];
    String message = json["message"];
    String device = (json["device"] ?? "");
    String driver = (json["driver"] ?? "");
    String group = (json["group"] ?? "");
    String startDateTimeJalali ="----";
    String endDateTimeJalali ="----";
    int distance = 0;
    int overSpeedDistance=0;
    int maxSpeed=0;
    String max_speed_latitude="";
    String max_speed_longitude="";
    String max_speed_course="";
    String maxSpeedDateTimeJalali="";
    int drivingTime=0;
    String maxSpeedLatitude="";
    String maxSpeedLongitude="";
    String maxSpeedCourse="";
    int unValid_records=0;

    if(isSuccess) {
        if(json["start_dateTime"] != ""){
          DateTime startDateTime = DateTime.parse(json["start_dateTime"]);
          startDateTime = startDateTime.add(Duration(hours: 3,minutes: 30));
          final startJalaliDateTime =  startDateTime.toJalali();
          startDateTimeJalali = "${startJalaliDateTime.year}/${startJalaliDateTime.month}/${startJalaliDateTime.day}  "
              "${startJalaliDateTime.hour}:${startJalaliDateTime.minute}:${startJalaliDateTime.second}";
        }


        if(json["end_dateTime"] != ""){
          DateTime endDateTime = DateTime.parse(json["end_dateTime"]);
          endDateTime = endDateTime.add(Duration(hours: 3,minutes: 30));
          final endJalaliDateTime =  endDateTime.toJalali();
          endDateTimeJalali = "${endJalaliDateTime.year}/${endJalaliDateTime.month}/${endJalaliDateTime.day}  "
              "${endJalaliDateTime.hour}:${endJalaliDateTime.minute}:${endJalaliDateTime.second}";
        }


        if(json["max_speed_dateTime"] != ""){
          DateTime maxSpeedDateTime = DateTime.parse(json["max_speed_dateTime"]);
          maxSpeedDateTime = maxSpeedDateTime.add(Duration(hours: 3,minutes: 30));
          final maxSpeedJalaliDateTime =  maxSpeedDateTime.toJalali();
          maxSpeedDateTimeJalali = "${maxSpeedJalaliDateTime.year}/${maxSpeedJalaliDateTime.month}/${maxSpeedJalaliDateTime.day}  "
              "${maxSpeedJalaliDateTime.hour}:${maxSpeedJalaliDateTime.minute}:${maxSpeedJalaliDateTime.second}";
        }



        distance = json["distance"];
        if(distance>0){
          distance = (distance/1000).round();
        }


        overSpeedDistance = json["over_speed_distance"];
        if(overSpeedDistance>0){
          overSpeedDistance = (overSpeedDistance/1000).round();
        }


        drivingTime = json["driving_time"];
        if(drivingTime >0){
          drivingTime = (drivingTime/60).round();
        }


        maxSpeed = json["max_speed"];

        maxSpeedLatitude=json["max_speed_latitude"];
        maxSpeedLongitude=json["max_speed_longitude"];
        maxSpeedCourse=json["max_speed_course"];
        unValid_records=json["unvalid_records"];

    }






    return TotalSpeedReport(
      isSuccess: (isSuccess),
      message: (message),
      device: (device),
      driver: (driver),
      group: (group),
      start_dateTime: (startDateTimeJalali),
      end_dateTime: (endDateTimeJalali),
      distance: (distance),
      over_speed_distance: (overSpeedDistance),
      max_speed: (maxSpeed),
      max_speed_latitude: (maxSpeedLatitude),
      max_speed_longitude: (maxSpeedLongitude),
      max_speed_course: (maxSpeedCourse),
      max_speed_dateTime: (maxSpeedDateTimeJalali),
      driving_time:  drivingTime,
      unValid_records: unValid_records

    );
  }


}