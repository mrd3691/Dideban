part of 'total_speed_report_bloc.dart';

@immutable
sealed class TotalSpeedReportEvent {}

final class FetchTotalSpeedReport extends TotalSpeedReportEvent {
  final List<String> deviceNames;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final int speedLimit;
  final List<TreeNode> treeNode;

  FetchTotalSpeedReport(this.deviceNames,this.startDate,this.startTime,this.endDate,this.endTime,this.speedLimit,this.treeNode);
}



final class LoadDrawerTotalSpeedReport extends TotalSpeedReportEvent{
  LoadDrawerTotalSpeedReport();
}

final class SearchDrawerDevicesTotalSpeedReport  extends TotalSpeedReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesTotalSpeedReport(this.treeNode,this.searchedValue);
}

final class SearchTotalSpeedReport extends TotalSpeedReportEvent{
  final List<TotalSpeedReport>? totalSpeedReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchTotalSpeedReport(this.totalSpeedReport,this.searchedString,this.treeNode);
}