part of 'tracking_bloc.dart';

@immutable
sealed class TrackingState {}

final class TrackingInitial extends TrackingState {}

final class TrackingInProgress extends TrackingState {}

final class TrackingSuccess extends TrackingState {

  final List<TreeNode> treeNode;
  final List<Marker> markers;
  TrackingSuccess({required this.markers,required this.treeNode});
}

final class TrackingFailure extends TrackingState {
  final String? message;
  TrackingFailure(this.message);
}

final class SliderNewState extends TrackingState {
  final double value;
  List<Marker> markers = [];
  final List<TreeNode> treeNode;
  SliderNewState(this.value, this.markers,this.treeNode);
}

/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends TrackingState {}

final class DrawerLoadSuccess extends TrackingState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends TrackingState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends TrackingState {}

final class SearchDrawerDevicesSuccess extends TrackingState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends TrackingState {}
/////////////////////////////////////////////////////////////////////////////////
