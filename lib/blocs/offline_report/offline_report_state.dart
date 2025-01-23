part of 'offline_report_bloc.dart';

@immutable
sealed class OfflineReportState {}

final class OfflineReportInitial extends OfflineReportState {}

final class OfflineReportInProgress extends OfflineReportState {}

final class OfflineReportSuccess extends OfflineReportState {

  final List<TreeNode> treeNode;
  final List<OfflineReport> offlineReport;

  OfflineReportSuccess({required this.treeNode, required this.offlineReport});
}

final class OfflineReportFailure extends OfflineReportState {
  final String? message;
  OfflineReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends OfflineReportState {}

final class DrawerLoadSuccess extends OfflineReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends OfflineReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends OfflineReportState {}

final class SearchDrawerDevicesSuccess extends OfflineReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends OfflineReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchOfflineReportIsLoading extends OfflineReportState {}

final class SearchOfflineReportSuccess extends OfflineReportState {
  final List<OfflineReport> offlineReport;
  final List<TreeNode> treeNode;
  SearchOfflineReportSuccess({
    required this.offlineReport,
    required this.treeNode
  });
}

final class SearchOfflineReportFailed extends OfflineReportState {
  final String? message;
  SearchOfflineReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////