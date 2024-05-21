part of 'tracking_bloc.dart';

@immutable
sealed class TrackingState {}

final class TrackingInitial extends TrackingState {}

final class TrackingInProgress extends TrackingState {}

final class TrackingSuccess extends TrackingState {
  final List<Marker> markers;
  TrackingSuccess({required this.markers});
}

final class TrackingFailure extends TrackingState {
  final String? message;
  TrackingFailure(this.message);
}

final class SliderNewState extends TrackingState {
  final double value;
  List<Marker> markers = [];
  SliderNewState(this.value, this.markers);
}
