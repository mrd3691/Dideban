part of 'tracking_bloc.dart';

@immutable
sealed class TrackingEvent {}

final class FetchTrackingPoints extends TrackingEvent {
  final String deviceName;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;

  FetchTrackingPoints(this.deviceName,this.startDate,this.startTime,this.endDate,this.endTime);
}

final class SliderChanged extends TrackingEvent {
  List<Marker> markers = [];
  double sliderValue ;

  SliderChanged(this.markers,this.sliderValue);
}