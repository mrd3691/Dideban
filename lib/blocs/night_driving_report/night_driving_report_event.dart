part of 'night_driving_report_bloc.dart';

@immutable
sealed class NightDrivingReportEvent {}

final class FetchNightDrivingReport extends NightDrivingReportEvent {
  final List<String> deviceNames;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final int stopTreshold;
  final int drivingTreshold;
  final List<TreeNode> treeNode;

  FetchNightDrivingReport(this.deviceNames,this.startDate,this.startTime,this.endDate,this.endTime,this.stopTreshold,this.drivingTreshold,this.treeNode);
}



final class LoadDrawerNightDrivingReport extends NightDrivingReportEvent{
  LoadDrawerNightDrivingReport();
}

final class SearchDrawerDevicesNightDrivingReport extends NightDrivingReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesNightDrivingReport(this.treeNode,this.searchedValue);
}

final class SearchNightDrivingReport extends NightDrivingReportEvent{
  final List<NightDrivingReport>? nightDrivingReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchNightDrivingReport(this.nightDrivingReport,this.searchedString,this.treeNode);
}