import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Car {
  static const double size = 25;

  Car({
    required this.name,
    required this.speed,
    required this.dateTime,
    required this.acc,
    required this.driver,
    required this.lat,
    required this.long,
  });

  final String name;
  final String speed;
  final String dateTime;
  final String acc;
  final String driver;
  final double lat;
  final double long;
}

class CarMarker extends Marker {
  CarMarker({required this.car})
      : super(
    alignment: Alignment.topCenter,
    height: Car.size,
    width: Car.size,
    point: LatLng(car.lat, car.long),
    child: const Icon(Icons.car_crash),
  );

  final Car car;
}

class CarMarkerPopup extends StatelessWidget {
  const CarMarkerPopup({super.key, required this.car});
  final Car car;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(10, 0, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(car.name),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(car.dateTime)),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(car.speed.toString())),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(car.acc)),
              Align(
                  alignment: Alignment.topLeft,
                  child: Text(car.driver)),
            ],
          ),
        ),
      ),
    );
  }
}