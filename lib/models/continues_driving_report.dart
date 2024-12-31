import 'package:shamsi_date/shamsi_date.dart';

class ContinuesDrivingReport{

  ContinuesDrivingReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.start_dateTime,
    required this.end_dateTime,
    required this.group,
    required this.max_driving_time,
    required this.start_date_max_driving,
    required this.end_date_max_driving,
    required this.start_long_max_driving,
    required this.start_lat_max_driving,
    required this.end_long_max_driving,
    required this.end_lat_max_driving
  });

  bool isSuccess;
  String message;
  String device;
  String driver;
  String start_dateTime;
  String end_dateTime;
  String group;
  int max_driving_time;
  String start_date_max_driving;
  String end_date_max_driving;
  String start_long_max_driving;
  String start_lat_max_driving;
  String end_long_max_driving;
  String end_lat_max_driving;




  factory ContinuesDrivingReport.fromMap( Map<String , dynamic> json) {

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

    String startMaxDrivingTimeJalali ="";
    if(json["start_date_max_driving"] != ""){
      DateTime startDateMaxDriving = DateTime.parse(json["start_date_max_driving"] );
      startDateMaxDriving = startDateMaxDriving.add(Duration(hours: 3,minutes: 30));
      final startMaxDrivingJalaliDateTime =  startDateMaxDriving.toJalali();
      startMaxDrivingTimeJalali = "${startMaxDrivingJalaliDateTime.year}/${startMaxDrivingJalaliDateTime.month}/${startMaxDrivingJalaliDateTime.day}  "
          "${startMaxDrivingJalaliDateTime.hour}:${startMaxDrivingJalaliDateTime.minute}:${startMaxDrivingJalaliDateTime.second}";
    }


    String endMaxDrivingTimeJalali = "";
    if(json["end_date_max_driving"] != ""){
      DateTime endDateMaxDriving = DateTime.parse(json["end_date_max_driving"]);
      endDateMaxDriving = endDateMaxDriving.add(Duration(hours: 3,minutes: 30));
      final endMaxDrivingJalaliDateTime =  endDateMaxDriving.toJalali();
      endMaxDrivingTimeJalali = "${endMaxDrivingJalaliDateTime.year}/${endMaxDrivingJalaliDateTime.month}/${endMaxDrivingJalaliDateTime.day}  "
          "${endMaxDrivingJalaliDateTime.hour}:${endMaxDrivingJalaliDateTime.minute}:${endMaxDrivingJalaliDateTime.second}";
    }




    return ContinuesDrivingReport(
      isSuccess: (json["isSuccess"] ?? false),
      message: (json["message"] ?? ""),
      device: (json["device"] ?? ""),
      driver: (json["driver"] ?? ""),
      start_dateTime: (startDateTimeJalali),
      end_dateTime: (endDateTimeJalali),
      group: (json["group"] ?? ""),
      max_driving_time: (json["max_driving_time"] ?? 0),
      start_date_max_driving: (startMaxDrivingTimeJalali),
      end_date_max_driving: (endMaxDrivingTimeJalali),
      start_long_max_driving: (json["start_long_max_driving"] ?? ""),
      start_lat_max_driving: (json["start_lat_max_driving"] ?? ""),
      end_long_max_driving: (json["end_long_max_driving"] ?? ""),
      end_lat_max_driving: (json["end_lat_max_driving"] ?? "")
    );
  }


}