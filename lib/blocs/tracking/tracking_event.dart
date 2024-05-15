part of 'tracking_bloc.dart';

@immutable
sealed class TrackingEvent {}

final class FetchPoints extends TrackingEvent {
  final String deviceId;
  final String startDateTime;
  final String endDateTime;

  FetchPoints(this.deviceId,this.startDateTime,this.endDateTime);
}
