part of 'night_driving_report_bloc.dart';

@immutable
sealed class NightDrivingReportState {}

final class NightDrivingReportInitial extends NightDrivingReportState {}

final class NightDrivingReportInProgress extends NightDrivingReportState {}

final class NightDrivingReportSuccess extends NightDrivingReportState {

  final List<TreeNode> treeNode;
  final List<NightDrivingReport> nightDrivingReport;

  NightDrivingReportSuccess({required this.treeNode, required this.nightDrivingReport});
}

final class NightDrivingReportFailure extends NightDrivingReportState {
  final String? message;
  NightDrivingReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends NightDrivingReportState {}

final class DrawerLoadSuccess extends NightDrivingReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends NightDrivingReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends NightDrivingReportState {}

final class SearchDrawerDevicesSuccess extends NightDrivingReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends NightDrivingReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchNightDrivingReportIsLoading extends NightDrivingReportState {}

final class SearchNightDrivingReportSuccess extends NightDrivingReportState {
  final List<NightDrivingReport> nightDrivingReport;
  final List<TreeNode> treeNode;
  SearchNightDrivingReportSuccess({
    required this.nightDrivingReport,
    required this.treeNode
  });
}

final class SearchNightDrivingReportFailed extends NightDrivingReportState {
  final String? message;
  SearchNightDrivingReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////