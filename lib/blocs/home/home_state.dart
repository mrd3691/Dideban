part of 'home_bloc.dart';

@immutable
sealed class HomeState {}

final class HomeInitial extends HomeState {}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends HomeState {}

final class DrawerLoadSuccess extends HomeState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends HomeState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends HomeState {}

final class SearchDrawerDevicesSuccess extends HomeState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends HomeState {}
/////////////////////////////////////////////////////////////////////////////////
final class GetLocationOfSelectedDevicesInProgress extends HomeState {}

final class GetLocationOfSelectedDevicesSuccess extends HomeState {
  final List<Marker>? markers;
  final List<TreeNode> treeNode;
  GetLocationOfSelectedDevicesSuccess({
    required this.markers,
    required this.treeNode

  });
}

final class GetLocationOfSelectedDevicesFailure extends HomeState {
  final String? message;

  GetLocationOfSelectedDevicesFailure(this.message,);
}
/////////////////////////////////////////////////////////////////////////////////
final class UpdateSuccess extends HomeState {
  final List<Marker>? markers;
  final List<TreeNode> treeNode;
  UpdateSuccess({
    required this.markers,
    required this.treeNode
  });
}

final class UpdateFailure extends HomeState {
  UpdateFailure();
}