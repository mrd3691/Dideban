part of 'detail_speed_report_bloc.dart';

@immutable
sealed class DetailSpeedReportState {}

final class DetailSpeedReportInitial extends DetailSpeedReportState {}


final class DetailSpeedReportInProgress extends DetailSpeedReportState {}

final class DetailSpeedReportSuccess extends DetailSpeedReportState {

  final List<TreeNode> treeNode;
  final DetailSpeedReport detailSpeedReport;

  DetailSpeedReportSuccess({required this.treeNode, required this.detailSpeedReport});
}

final class DetailSpeedReportFailure extends DetailSpeedReportState {
  final String? message;
  DetailSpeedReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends DetailSpeedReportState {}

final class DrawerLoadSuccess extends DetailSpeedReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends DetailSpeedReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends DetailSpeedReportState {}

final class SearchDrawerDevicesSuccess extends DetailSpeedReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends DetailSpeedReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchDetailSpeedReportIsLoading extends DetailSpeedReportState {}

final class SearchDetailSpeedReportSuccess extends DetailSpeedReportState {
  final DetailSpeedReport detailSpeedReport;
  final List<TreeNode> treeNode;
  SearchDetailSpeedReportSuccess({
    required this.detailSpeedReport,
    required this.treeNode
  });
}

final class SearchDetailSpeedReportFailed extends DetailSpeedReportState {
  final String? message;
  SearchDetailSpeedReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////