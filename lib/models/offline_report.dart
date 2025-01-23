import 'package:shamsi_date/shamsi_date.dart';

class OfflineReport{

  OfflineReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.group,
    required this.last_dateTime,
    required this.last_lat,
    required this.last_long

  });

  bool isSuccess;
  String message;
  String device;
  String driver;
  String group;
  String last_dateTime;
  String last_lat;
  String last_long;



  factory OfflineReport.fromMap( Map<String , dynamic> json)  {

    bool isSuccess= json["isSuccess"];
    String message = json["message"];
    String device = (json["device"] ?? "");
    String driver = (json["driver"] ?? "");
    String group = (json["group"] ?? "");
    String lastDateTimeJalali ="----";
    String lastLat =(json["lastLat"] ?? "");
    String lastLong =(json["lastLong"] ?? "");

    if(isSuccess){
      if(message == "offline"){
        DateTime lastDateTime = DateTime.parse(json["lastDateTime"]);
        lastDateTime = lastDateTime.add(Duration(hours: 3,minutes: 30));
        final lastJalaliDateTime =  lastDateTime.toJalali();
        lastDateTimeJalali = "${lastJalaliDateTime.year}/${lastJalaliDateTime.month}/${lastJalaliDateTime.day}  "
            "${lastJalaliDateTime.hour}:${lastJalaliDateTime.minute}:${lastJalaliDateTime.second}";

      }
    }else{
      throw message;
    }


    return OfflineReport(
      isSuccess: (isSuccess),
      message: (message),
      device: (device),
      driver: (driver),
      group: (group),
      last_dateTime: (lastDateTimeJalali),
      last_lat: lastLat,
      last_long: lastLong

    );
  }


}