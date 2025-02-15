part of 'long_stop_report_bloc.dart';

@immutable
sealed class LongStopReportState {}

final class LongStopReportInitial extends LongStopReportState {}


final class LongStopReportInProgress extends LongStopReportState {}

final class LongStopReportSuccess extends LongStopReportState {

  final List<TreeNode> treeNode;
  final List<LongStopReport> longStopReport;

  LongStopReportSuccess({required this.treeNode, required this.longStopReport});
}

final class LongStopReportFailure extends LongStopReportState {
  final String? message;
  LongStopReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends LongStopReportState {}

final class DrawerLoadSuccess extends LongStopReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends LongStopReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends LongStopReportState {}

final class SearchDrawerDevicesSuccess extends LongStopReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends LongStopReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchLongStopReportIsLoading extends LongStopReportState {}

final class SearchLongStopReportSuccess extends LongStopReportState {
  final List<LongStopReport> longStopReport;
  final List<TreeNode> treeNode;
  SearchLongStopReportSuccess({
    required this.longStopReport,
    required this.treeNode
  });
}

final class SearchLongStopReportFailed extends LongStopReportState {
  final String? message;
  SearchLongStopReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////