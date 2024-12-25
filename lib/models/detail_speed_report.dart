
import 'package:shamsi_date/shamsi_date.dart';

class DetailSpeedReport{

  DetailSpeedReport({
    required this.isSuccess,
    required this.message,
    required this.device,
    required this.driver,
    required this.group,
    required this.overSpeedPoints,


  });

  bool isSuccess;
  String message;
  String device;
  String driver;
  String group;
  List<OverSpeedPoints> overSpeedPoints;


  factory DetailSpeedReport.fromMap( Map<String , dynamic> json) {



    return DetailSpeedReport(
      isSuccess: (json["isSuccess"] ?? false),
      message: (json["message"] ?? ""),
      device: (json["device"] ?? ""),
      driver: (json["driver"] ?? ""),
      group: (json["group"] ?? ""),
      overSpeedPoints:  json["overSpeedPoints"].map<OverSpeedPoints>( (json) =>  OverSpeedPoints.fromMap(json)).toList(),
      //overSpeedPoints: OverSpeedPoints.fromMap(json["overSpeedPoints"]),
    );
  }


}

class OverSpeedPoints{

  OverSpeedPoints({
    required this.fixTime,
    required this.valid,
    required this.latitude,
    required this.longitude,
    required this.speed,
    required this.course,


  });

  String fixTime;
  String valid;
  String latitude;
  String longitude;
  int speed;
  String course;



  factory OverSpeedPoints.fromMap( Map<String , dynamic> json) {

    DateTime fixTime = DateTime.parse(json["fixtime"]);
    fixTime = fixTime.add(Duration(hours: 3,minutes: 30));
    final JalaliFixTime =  fixTime.toJalali();
    String fixTimeJalali = "${JalaliFixTime.year}/${JalaliFixTime.month}/${JalaliFixTime.day}  "
        "${JalaliFixTime.hour}:${JalaliFixTime.minute}:${JalaliFixTime.second}";

    return OverSpeedPoints(
      fixTime: (fixTimeJalali),
      valid: (json["valid"] ?? ""),
      latitude: (json["latitude"] ?? ""),
      longitude: (json["longitude"] ?? ""),
      speed: ( (double.parse(json["speed"])*1.852).round() ?? 0),
      course: (json["course"] ?? ""),


    );
  }


}