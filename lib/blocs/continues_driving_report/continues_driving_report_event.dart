part of 'continues_driving_report_bloc.dart';

@immutable
sealed class ContinuesDrivingReportEvent {}

final class FetchContinuesDrivingReport extends ContinuesDrivingReportEvent {
  final List<String> deviceNames;
  final String startDate;
  final String startTime;
  final String endDate;
  final String endTime;
  final int stopTreshold;
  final List<TreeNode> treeNode;

  FetchContinuesDrivingReport(this.deviceNames,this.startDate,this.startTime,this.endDate,this.endTime,this.stopTreshold,this.treeNode);
}



final class LoadDrawerContinuesDrivingReport extends ContinuesDrivingReportEvent{
  LoadDrawerContinuesDrivingReport();
}

final class SearchDrawerDevicesContinuesDrivingReport extends ContinuesDrivingReportEvent {
  final String searchedValue;
  final List<TreeNode> treeNode;
  SearchDrawerDevicesContinuesDrivingReport(this.treeNode,this.searchedValue);
}

final class SearchContinuesDrivingReport extends ContinuesDrivingReportEvent{
  final List<ContinuesDrivingReport>? continuesDrivingReport;
  final List<TreeNode> treeNode;
  final String searchedString;
  SearchContinuesDrivingReport(this.continuesDrivingReport,this.searchedString,this.treeNode);
}