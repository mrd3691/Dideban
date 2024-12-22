part of 'total_speed_report_bloc.dart';

@immutable
sealed class TotalSpeedReportState {}

final class TotalSpeedReportInitial extends TotalSpeedReportState {}


final class TotalSpeedReportInProgress extends TotalSpeedReportState {}

final class TotalSpeedReportSuccess extends TotalSpeedReportState {

  final List<TreeNode> treeNode;
  final List<TotalSpeedReport> totalSpeedReport;

  TotalSpeedReportSuccess({required this.treeNode, required this.totalSpeedReport});
}

final class TotalSpeedReportFailure extends TotalSpeedReportState {
  final String? message;
  TotalSpeedReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends TotalSpeedReportState {}

final class DrawerLoadSuccess extends TotalSpeedReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends TotalSpeedReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends TotalSpeedReportState {}

final class SearchDrawerDevicesSuccess extends TotalSpeedReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends TotalSpeedReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchTotalSpeedReportIsLoading extends TotalSpeedReportState {}

final class SearchTotalSpeedReportSuccess extends TotalSpeedReportState {
  final List<TotalSpeedReport> totalSpeedReport;
  final List<TreeNode> treeNode;
  SearchTotalSpeedReportSuccess({
    required this.totalSpeedReport,
    required this.treeNode
  });
}

final class SearchTotalSpeedReportFailed extends TotalSpeedReportState {
  final String? message;
  SearchTotalSpeedReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////