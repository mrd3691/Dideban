part of 'last_status_report_bloc.dart';

@immutable
sealed class LastStatusReportState {}

final class LastStatusReportInitial extends LastStatusReportState {}

final class LastStatusReportInProgress extends LastStatusReportState {}

final class LastStatusReportSuccess extends LastStatusReportState {

  final List<TreeNode> treeNode;
  final LastStatusReport lastStatusReport;

  LastStatusReportSuccess({required this.treeNode, required this.lastStatusReport});
}

final class LastStatusReportFailure extends LastStatusReportState {
  final String? message;
  LastStatusReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends LastStatusReportState {}

final class DrawerLoadSuccess extends LastStatusReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends LastStatusReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends LastStatusReportState {}

final class SearchDrawerDevicesSuccess extends LastStatusReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends LastStatusReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchLastStatusReportIsLoading extends LastStatusReportState {}

final class SearchLastStatusReportSuccess extends LastStatusReportState {
  final LastStatusReport lastStatusReport;
  final List<TreeNode> treeNode;
  SearchLastStatusReportSuccess({
    required this.lastStatusReport,
    required this.treeNode
  });
}

final class SearchLastStatusReportFailed extends LastStatusReportState {
  final String? message;
  SearchLastStatusReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
