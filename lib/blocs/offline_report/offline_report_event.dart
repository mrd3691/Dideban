part of 'offline_report_bloc.dart';

@immutable
sealed class OfflineReportEvent {}

final class FetchOfflineReport extends OfflineReportEvent {
  final List<String> deviceNames;
  final int timeTreshold;
  final List<TreeNode> treeNode;

  FetchOfflineReport(this.deviceNames,this.timeTreshold,this.treeNode);
}



final class LoadDrawerOfflineReport extends OfflineReportEvent{
  LoadDrawerOfflineReport();
}

final class SearchDrawerDevicesOfflineReport  extends OfflineReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesOfflineReport(this.treeNode,this.searchedValue);
}

final class SearchOfflineReport extends OfflineReportEvent{
  final List<OfflineReport>? offlineReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchOfflineReport(this.offlineReport,this.searchedString,this.treeNode);
}