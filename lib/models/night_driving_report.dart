import 'package:dideban/data/night_driving_report_api.dart';
import 'package:shamsi_date/shamsi_date.dart';

class NightDrivingReport{

  NightDrivingReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.group,
    required this.start_dateTime,
    required this.end_dateTime,
    required this.start_date_driving,
    required this.start_lat_driving,
    required this.start_long_driving,
    required this.end_date_driving,
    required this.end_lat_driving,
    required this.end_long_driving,
    required this.driving_time,
    required this.distance,
    required this.max_speed,
    required this.start_address,
    required this.end_address
  });

  bool isSuccess;
  String message;
  String device;
  String driver;
  String group;
  String start_dateTime;
  String end_dateTime;
  String start_date_driving;
  String start_lat_driving;
  String start_long_driving;
  String end_date_driving;
  String end_lat_driving;
  String end_long_driving;
  int driving_time;
  int distance;
  int max_speed;
  String start_address;
  String end_address;


  Future<String?> getAddress(String lat, String long) async {
    String? address  =await  NightDrivingReportApi.ReverseGeocode(lat,long);
    return address;
  }

  factory NightDrivingReport.fromMap( Map<String , dynamic> json)  {

    bool isSuccess= json["isSuccess"];
    String message = json["message"];
    String device = (json["device"] ?? "");
    String driver = (json["driver"] ?? "");
    String group = (json["group"] ?? "");
    String startDateTimeJalali ="----";
    String endDateTimeJalali ="----";
    String startDrivingDateTimeJalali = "----";
    String endDrivingDateTimeJalali = "----";
    String start_lat_driving = "";
    String start_long_driving ="";
    String end_lat_driving ="";
    String end_long_driving = "";
    int driving_time = 0;
    int max_speed =0;
    int distance = 0;


    if(isSuccess){
      if(message == "ok"){
        DateTime startDateTime = DateTime.parse(json["start_dateTime"]);
        startDateTime = startDateTime.add(Duration(hours: 3,minutes: 30));
        final startJalaliDateTime =  startDateTime.toJalali();
        startDateTimeJalali = "${startJalaliDateTime.year}/${startJalaliDateTime.month}/${startJalaliDateTime.day}  "
            "${startJalaliDateTime.hour}:${startJalaliDateTime.minute}:${startJalaliDateTime.second}";

        DateTime endDateTime = DateTime.parse(json["end_dateTime"]);
        endDateTime = endDateTime.add(Duration(hours: 3,minutes: 30));
        final endJalaliDateTime =  endDateTime.toJalali();
        endDateTimeJalali = "${endJalaliDateTime.year}/${endJalaliDateTime.month}/${endJalaliDateTime.day}  "
            "${endJalaliDateTime.hour}:${endJalaliDateTime.minute}:${endJalaliDateTime.second}";

        DateTime startDrivingDateTime = DateTime.parse(json["start_date_driving"]);
        startDrivingDateTime = startDrivingDateTime.add(Duration(hours: 3,minutes: 30));
        final startDrivingJalaliDateTime =  startDrivingDateTime.toJalali();
        startDrivingDateTimeJalali = "${startDrivingJalaliDateTime.year}/${startDrivingJalaliDateTime.month}/${startDrivingJalaliDateTime.day}  "
            "${startDrivingJalaliDateTime.hour}:${startDrivingJalaliDateTime.minute}:${startDrivingJalaliDateTime.second}";

        DateTime endDrivingDateTime = DateTime.parse(json["end_date_driving"]);
        endDrivingDateTime = endDrivingDateTime.add(Duration(hours: 3,minutes: 30));
        final endDrivingJalaliDateTime =  endDrivingDateTime.toJalali();
        endDrivingDateTimeJalali = "${endDrivingJalaliDateTime.year}/${endDrivingJalaliDateTime.month}/${endDrivingJalaliDateTime.day}  "
            "${endDrivingJalaliDateTime.hour}:${endDrivingJalaliDateTime.minute}:${endDrivingJalaliDateTime.second}";

        distance = json["distance"];
        distance = (distance/1000).round();

        start_lat_driving = (json["start_lat_driving"] ?? "");
        start_long_driving = (json["start_long_driving"] ?? "");

        end_lat_driving =  (json["end_lat_driving"] ?? "");
        end_long_driving =  (json["end_long_driving"] ?? "");
        driving_time= (json["driving_time"]?? 0);
        max_speed=  (json["max_speed"] ?? 0);
      }
    }else{
      throw message;
    }







    return NightDrivingReport(
      isSuccess: (isSuccess),
      message: (message),
      device: (device),
      driver: (driver),
      group: (group),
      start_dateTime: (startDateTimeJalali),
      end_dateTime: (endDateTimeJalali),
      start_date_driving: (startDrivingDateTimeJalali),
      start_lat_driving: (start_lat_driving),
      start_long_driving: (start_long_driving),
      end_date_driving: (endDrivingDateTimeJalali),
      end_lat_driving: (end_lat_driving),
      end_long_driving: (end_long_driving),
      driving_time: (driving_time),
      distance: (distance),
      max_speed: (max_speed),
      start_address: "----",
      end_address: "----",
    );
  }


}