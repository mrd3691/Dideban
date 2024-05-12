part of 'devices_bloc.dart';

@immutable
sealed class DevicesState {}

final class DevicesInitial extends DevicesState {}

final class DevicesLoadingInProgress extends DevicesState {}

final class DevicesLoadSuccess extends DevicesState {
  //final List<Device> devicesList;
  final List<TreeNode> treeNode;

  DevicesLoadSuccess({
    required this.treeNode,
  });
}

final class DevicesLoadFailure extends DevicesState {
  final String? message;

  DevicesLoadFailure(this.message);
}

final class DevicesLoadEmpty extends DevicesState {}



final class SearchDevicesLoadSuccess extends DevicesState {
  final List<TreeNode> searchedTreeNode;
  SearchDevicesLoadSuccess({
    required this.searchedTreeNode,
  });
}



final class GetLocationInitial extends DevicesState {}

final class GetLocationLoadingInProgress extends DevicesState {}

final class GetDevicesLocationSuccess extends DevicesState {
  final List<Marker> markers;
  final List<TreeNode> treeNode;
  GetDevicesLocationSuccess({
    required this.markers,
    required this.treeNode
  });
}

final class GetDevicesLocationFailure extends DevicesState {
  final String? message;
  GetDevicesLocationFailure(this.message);
}

final class GetDevicesLocationEmpty extends DevicesState {
  GetDevicesLocationEmpty();
}

