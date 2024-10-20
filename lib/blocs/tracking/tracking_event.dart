part of 'tracking_bloc.dart';

@immutable
sealed class TrackingEvent {}

final class FetchTrackingPoints extends TrackingEvent {
  final String deviceName;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final List<TreeNode> treeNode;

  FetchTrackingPoints(this.deviceName,this.startDate,this.startTime,this.endDate,this.endTime,this.treeNode);
}

final class SliderChanged extends TrackingEvent {
  List<Marker> markers = [];
  double sliderValue ;
  final List<TreeNode> treeNode;

  SliderChanged(this.markers,this.sliderValue,this.treeNode);
}

final class LoadDrawerTracking extends TrackingEvent{
  LoadDrawerTracking();
}

final class SearchDrawerDevicesTracking extends TrackingEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesTracking(this.treeNode,this.searchedValue);
}
