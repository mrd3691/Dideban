part of 'detail_speed_report_bloc.dart';

@immutable
sealed class DetailSpeedReportEvent {}

final class FetchDetailSpeedReport extends DetailSpeedReportEvent {
  final String deviceNames;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final int speedLimit;
  final List<TreeNode> treeNode;

  FetchDetailSpeedReport(this.deviceNames,this.startDate,this.startTime,this.endDate,this.endTime,this.speedLimit,this.treeNode);
}



final class LoadDrawerDetailSpeedReport extends DetailSpeedReportEvent{
  LoadDrawerDetailSpeedReport();
}

final class SearchDrawerDevicesDetailSpeedReport  extends DetailSpeedReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesDetailSpeedReport(this.treeNode,this.searchedValue);
}

final class SearchDetailSpeedReport extends DetailSpeedReportEvent{
  final DetailSpeedReport? detailSpeedReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchDetailSpeedReport(this.detailSpeedReport,this.searchedString,this.treeNode);
}