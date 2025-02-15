import 'package:shamsi_date/shamsi_date.dart';

class LongStopReport{

  LongStopReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.group,
    required this.start_dateTime,
    required this.end_dateTime,
    required this.long_stop_latitude,
    required  this.long_stop_longitude,
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
  String long_stop_latitude;
  String long_stop_longitude;
  int driving_time;
  int unValid_records;


  factory LongStopReport.fromMap( Map<String , dynamic> json) {

    bool isSuccess= json["isSuccess"];
    String message = json["message"];
    String device = (json["device"] ?? "");
    String driver = (json["driver"] ?? "");
    String group = (json["group"] ?? "");
    String startDateTimeJalali ="----";
    String endDateTimeJalali ="----";
    String longStopLatitude="";
    String longStopLongitude="";
    int drivingTime=0;
    int unValidRecords=0;

    if(isSuccess) {
      if (message == "no_driving_detected") {
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

        drivingTime = json["driving_time"];
        drivingTime = (drivingTime/60).round();

        longStopLatitude=json["long_stop_latitude"];
        longStopLongitude=json["long_stop_longitude"];
        unValidRecords=json["unvalid_records"];
      } else {
        throw message;
      }
    }






    return LongStopReport(
        isSuccess: (isSuccess),
        message: (message),
        device: (device),
        driver: (driver),
        group: (group),
        start_dateTime: (startDateTimeJalali),
        end_dateTime: (endDateTimeJalali),
        long_stop_latitude: (longStopLatitude),
        long_stop_longitude: (longStopLongitude),
        driving_time:  drivingTime,
        unValid_records: unValidRecords
    );
  }


}