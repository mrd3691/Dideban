part of 'last_status_report_bloc.dart';

@immutable
sealed class LastStatusReportEvent {}

final class FetchLastStatusReport extends LastStatusReportEvent {
  final List<TreeNode> treeNode;
  FetchLastStatusReport(this.treeNode);
}

final class LoadDrawerLastStatusReport extends LastStatusReportEvent{
  LoadDrawerLastStatusReport();
}

final class SearchDrawerDevicesLastStatusReport  extends LastStatusReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesLastStatusReport(this.treeNode,this.searchedValue);
}

final class SearchLastStatusReport extends LastStatusReportEvent{
  final LastStatusReport? lastStatusReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchLastStatusReport(this.lastStatusReport,this.searchedString,this.treeNode);
}