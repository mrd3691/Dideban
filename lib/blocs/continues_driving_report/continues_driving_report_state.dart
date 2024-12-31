part of 'continues_driving_report_bloc.dart';

@immutable
sealed class ContinuesDrivingReportState {}

final class ContinuesDrivingReportInitial extends ContinuesDrivingReportState {}


final class ContinuesDrivingReportInProgress extends ContinuesDrivingReportState {}

final class ContinuesDrivingReportSuccess extends ContinuesDrivingReportState {

  final List<TreeNode> treeNode;
  final List<ContinuesDrivingReport> continuesDrivingReport;

  ContinuesDrivingReportSuccess({required this.treeNode, required this.continuesDrivingReport});
}

final class ContinuesDrivingReportFailure extends ContinuesDrivingReportState {
  final String? message;
  ContinuesDrivingReportFailure(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
final class DrawerIsLoading extends ContinuesDrivingReportState {}

final class DrawerLoadSuccess extends ContinuesDrivingReportState {
  final List<TreeNode> treeNode;
  DrawerLoadSuccess({
    required this.treeNode,
  });
}

final class DrawerLoadFailed extends ContinuesDrivingReportState {}
/////////////////////////////////////////////////////////////////////////////////
final class SearchDrawerDevicesIsLoading extends ContinuesDrivingReportState {}

final class SearchDrawerDevicesSuccess extends ContinuesDrivingReportState {
  final List<TreeNode> treeNode;
  SearchDrawerDevicesSuccess({
    required this.treeNode,
  });
}

final class SearchDrawerDevicesFailed extends ContinuesDrivingReportState {}
/////////////////////////////////////////////////////////////////////////////////

final class SearchContinuesDrivingReportIsLoading extends ContinuesDrivingReportState {}

final class SearchContinuesDrivingReportSuccess extends ContinuesDrivingReportState {
  final List<ContinuesDrivingReport> continuesDrivingReport;
  final List<TreeNode> treeNode;
  SearchContinuesDrivingReportSuccess({
    required this.continuesDrivingReport,
    required this.treeNode
  });
}

final class SearchContinuesDrivingReportFailed extends ContinuesDrivingReportState {
  final String? message;
  SearchContinuesDrivingReportFailed(this.message);
}
/////////////////////////////////////////////////////////////////////////////////
