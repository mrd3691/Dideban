part of 'devices_bloc.dart';

@immutable
sealed class DevicesEvent {}

final class FetchAllDevices extends DevicesEvent {
  final String userId;
  FetchAllDevices(this.userId);
}

final class SearchDevices extends DevicesEvent {
  final String searched;
  final List<TreeNode> treeNode;
  SearchDevices(this.treeNode,this.searched);
}

final class GetDevicesLocation extends DevicesEvent {
  final List<TreeNode> treeNode;
  GetDevicesLocation(this.treeNode);
}

final class GetDevicesLocationFromSearchedNodes extends DevicesEvent {
  final List<TreeNode> treeNode;
  GetDevicesLocationFromSearchedNodes(this.treeNode);
}