import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dideban/utilities/util.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';
import 'package:dideban/data/api.dart';

import '../../presentation/widgets/car_position.dart';
part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc() : super(TrackingInitial()) {
    on<FetchTrackingPoints>((event, emit) async {
      try{
        emit(TrackingInProgress());
        String deviceName = event.deviceName;
        String startDate = Util.jalaliToGeorgian(event.startDate);
        String startTime = event.startTime;
        String endDate = Util.jalaliToGeorgian(event.endDate);
        String endTime = event.endTime;
        String startDateTime = "$startDate $startTime";
        String endDateTime = "$endDate $endTime";

        final points =await API.fetchTrackingPoints(deviceName, startDateTime, endDateTime);
        List<Marker> carMarkers = [];
        if(points!.isEmpty){
          emit(TrackingSuccess(markers: carMarkers));
        }
        points?.forEach((element) {
          carMarkers.add(
              CarMarker(
                  car: Car(
                    name: deviceName,
                    speed:  "speed: ${element.speed}",
                    dateTime:  element.fixTime,
                    acc:   "ignition: ${_getIgnitionFromAttributes(element.attributes)}" ,
                    driver: "driver: ${element.driver}",
                    lat: double.parse(element.latitude),
                    long: double.parse(element.longitude),
                  )
              ));
        });
        emit(TrackingSuccess(markers: carMarkers));
      }catch(e){
        emit(TrackingFailure(e.toString()));
      }
    });
    on<SliderChanged>((event, emit) async {
      double newValue = event.sliderValue;


      emit(SliderNewState(newValue,event.markers));
    });
  }

  String _getIgnitionFromAttributes(String attributes){
    try{
      final parsed = jsonDecode(attributes);
      bool ignition = parsed["ignition"];
      if(ignition){
        return "ON";
      }else{
        return "OFF";
      }
    }catch(e){
      return "unknown";
    }
  }
}
