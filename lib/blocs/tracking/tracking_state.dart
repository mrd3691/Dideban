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
