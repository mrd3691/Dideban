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

final class UpdateSuccess extends HomeState {
  final List<Marker>? markers;

  UpdateSuccess({
    required this.markers,
  });
}

final class UpdateFailure extends HomeState {
  UpdateFailure();
}