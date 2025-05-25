import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shamsi_date/shamsi_date.dart';

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
    required this.course,
    //required this.fuelLevel,
    //required this.mileage
  });

  final String name;
  final String speed;
  final String dateTime;
  final String acc;
  final String driver;
  final double lat;
  final double long;
  final double course;
  //final double fuelLevel;
  //final int mileage;
}


class IconMarker extends StatelessWidget {
  final dateTime;
  final String speed;
  final TreeNode clickedTreeNode;
  final String markerName;
  IconMarker( this.dateTime,this.speed,this.clickedTreeNode,this.markerName);

  final Jalali jalaliNow = Jalali.now();

  bool isIdle(String dateTime){
    try{
      var splittedDateTime = dateTime.split(" ");
      String jalaliDate = splittedDateTime[1];
      var splittedDate = jalaliDate.split("/");
      var jalaliYear=splittedDate[0];
      var jalaliMonth=splittedDate[1];
      var jalaliDay=splittedDate[2];
      if(int.parse(jalaliYear)<jalaliNow.year){
        return true;
      }
      if(int.parse(jalaliMonth)<jalaliNow.month){
        return true;
      }
      if(int.parse(jalaliDay)<jalaliNow.day){
        return true;
      }

      return false;
    }catch(e){
      return false;
    }
  }



  bool isNightMove(String speed){
    try{
      DateTime dtNow = DateTime.now();
      if((dtNow.hour < 6  || dtNow.hour >= 22 )&& int.parse(speed)>0){
        return true;
      }
      return false;
    }catch(e){
      return false;
    }
  }



  @override
  Widget build(BuildContext context) {


    if(clickedTreeNode.title == markerName) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Icon(
            Icons.circle,
            size: 30,// Directional arrow
            color:Colors.white,
          ),
          Positioned(
            child: Icon(
              size: 30,
              Icons.navigation, // Directional arrow
              color: (isIdle(dateTime))
                  ? Colors.black
                  :(int.parse(speed)>110)
                    ?Colors.redAccent
                      : (isNightMove(speed)) ?
                        Colors.yellowAccent :
                          Colors.blueAccent

            ),
          ),
        ],
      );
      return Icon(
        Icons.navigation,
        color: Colors.blue,
      );
    }else{
      if(isIdle(dateTime)){
        return Icon(
          Icons.navigation,
          color: Colors.black,
        );
      }else{
        return Icon(
          Icons.navigation, // Directional arrow
          color:(int.parse(speed)>110)? Colors.redAccent : (isNightMove(speed))? Colors.yellowAccent :  Colors.blueAccent ,
        );
      }
    }


   /*if(isIdle(dateTime)){
     return Stack(
       alignment: Alignment.center,
       children: [
         Icon(
           Icons.circle, // Directional arrow
           size: 30,
           color: Colors.black,
         ),
         Positioned(
           //bottom: 0,
           child: Icon(
             Icons.arrow_upward, // Directional arrow
             size: 30,
             color: (clickedTreeNode.title == markerName)?Colors.blueAccent:Colors.white,
           ),
         ),
       ],
     );
   }else{
     return Stack(
       alignment: Alignment.center,
       children: [
         Icon(
           Icons.circle, // Directional arrow
           size: 30,
           color:(int.parse(speed)>100)?Colors.redAccent :Colors.greenAccent,
         ),
         Positioned(
           //bottom: 0,
           child: Icon(
             Icons.arrow_upward, // Directional arrow
             size: 30,
             color: (clickedTreeNode.title == markerName)?Colors.blueAccent:Colors.black,
           ),
         ),
       ],
     );
   }*/
  }
}



class CarMarkerLive extends Marker {
  CarMarkerLive({required this.car,required this.clickedTreeNode})
      : super(
    alignment: Alignment.topCenter,
    height: Car.size,
    width: Car.size,
    point: LatLng(car.lat, car.long),
    //child: Icon(Icons.fire_truck, color: Colors.redAccent,),
      child: Transform.rotate(angle: (car.course) * (3.141592653589793 / 180), child: IconMarker(car.dateTime,car.speed,clickedTreeNode,car.name))


  );
  final Car car;
  final TreeNode clickedTreeNode;









}

class CarMarkerTracking extends Marker {
  CarMarkerTracking({required this.car})
      : super(
      alignment: Alignment.topCenter,
      height: Car.size,
      width: Car.size,
      point: LatLng(car.lat, car.long),
      //child: Icon(Icons.fire_truck, color: Colors.redAccent,),
      child: (int.parse(car.speed)>110)?// substring remove speed: from the first
      Icon(Icons.location_on_rounded, color: Colors.redAccent,):
      Icon(Icons.location_on_rounded, color: Colors.deepPurple,)
    /*Transform.rotate(
          angle: (car.course-180)* (3.141592653589793 / 180),
          child: Icon(Icons.arrow_upward, color: Colors.deepPurple,)
      ),*/
  );
  final Car car;
}





