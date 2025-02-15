part of 'long_stop_report_bloc.dart';

@immutable
sealed class LongStopReportEvent {}

final class FetchLongStopReport extends LongStopReportEvent {
  final List<String> deviceNames;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final int drivingTimeTreshold;
  final List<TreeNode> treeNode;

  FetchLongStopReport(this.deviceNames,this.startDate,this.startTime,this.endDate,this.endTime,this.drivingTimeTreshold,this.treeNode);
}



final class LoadDrawerLongStopReport extends LongStopReportEvent{
  LoadDrawerLongStopReport();
}

final class SearchDrawerDevicesLongStopReport  extends LongStopReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesLongStopReport(this.treeNode,this.searchedValue);
}

final class SearchLongStopReport extends LongStopReportEvent{
  final List<LongStopReport>? longStopReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchLongStopReport(this.longStopReport,this.searchedString,this.treeNode);
}