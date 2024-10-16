part of 'home_bloc.dart';

@immutable
sealed class HomeEvent {}

final class LoadDrawer extends HomeEvent{
  LoadDrawer();
}

final class SearchDrawerDevices extends HomeEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevices(this.treeNode,this.searchedValue);
}

final class GetLocationOfSelectedDevices extends HomeEvent {
  final List<TreeNode> treeNode;
  final bool isOriginalTreeNode;
  GetLocationOfSelectedDevices(this.treeNode,this.isOriginalTreeNode);
}

final class Update extends HomeEvent {
  final List<TreeNode> treeNode;
  final bool isOriginalTreeNode;
  Update(this.treeNode,this.isOriginalTreeNode);
}