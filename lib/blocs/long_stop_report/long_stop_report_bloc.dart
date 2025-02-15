import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/long_stop_report_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';
import '../../models/long_stop_report.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
import '../../utilities/util.dart';

part 'long_stop_report_event.dart';
part 'long_stop_report_state.dart';

class LongStopReportBloc extends Bloc<LongStopReportEvent, LongStopReportState> {
  LongStopReportBloc() : super(LongStopReportInitial()) {
    on<FetchLongStopReport>(fetchLongStopReport);
    on<LoadDrawerLongStopReport>(loadDrawerTotalSpeedReport);
    on<SearchDrawerDevicesLongStopReport>(searchDrawerDevicesTotalSpeedReport);

    on<SearchLongStopReport>(searchLongStopReport);
  }


  FutureOr<void> searchLongStopReport(SearchLongStopReport event, Emitter<LongStopReportState> emit,) async{
    try{
      emit(SearchLongStopReportIsLoading());
      List<LongStopReport> searchedLongStopReport = [];
      for(int i=0;i<event.longStopReport!.length;i++){
        String device = event.longStopReport![i].device;
        String driver = event.longStopReport![i].driver;
        if(device.contains(event.searchedString) || driver.contains(event.searchedString)){
          searchedLongStopReport.add(event.longStopReport![i]);
        }
      }
      emit(SearchLongStopReportSuccess(longStopReport: searchedLongStopReport, treeNode: event.treeNode));
    }catch(e){
      emit(SearchLongStopReportFailed(e.toString()));
    }

  }

  FutureOr<void> fetchLongStopReport(FetchLongStopReport event, Emitter<LongStopReportState> emit,) async{
    try{
      emit(LongStopReportInProgress());

      List<String> deviceNames = event.deviceNames;
      String startDateTime =Util.jalaliToGeorgianGMTConvert(event.startDate,event.startTime);
      String endDateTime =Util.jalaliToGeorgianGMTConvert(event.endDate,event.endTime);
      int drivingTimeTreshold = event.drivingTimeTreshold;

      List<LongStopReport> longStopReports = [];
      for(int i=0;i<deviceNames.length;i++){
        final longStopReport =await LongStopReportApi.fetchLongStopReport(deviceNames[i], startDateTime, endDateTime,drivingTimeTreshold);
        if(longStopReport != null) {
          if(longStopReport.message!="no_data_available"){
            longStopReports.add(longStopReport);
          }
        }
      }
      emit(LongStopReportSuccess(treeNode: event.treeNode, longStopReport: longStopReports));
    }catch(e){
      emit(LongStopReportFailure(e.toString()));
    }
  }

  FutureOr<void> loadDrawerTotalSpeedReport(LoadDrawerLongStopReport event, Emitter<LongStopReportState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await LongStopReportApi.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await LongStopReportApi.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesTotalSpeedReport(SearchDrawerDevicesLongStopReport event, Emitter<LongStopReportState> emit,) async {
    emit(SearchDrawerDevicesIsLoading());
    try{
      List<TreeNode> totalNode = event.treeNode;
      String searchedValue = event.searchedValue;
      List<TreeNode> searchedTreeNode = [];
      if(searchedValue.isEmpty){
        emit(SearchDrawerDevicesSuccess(treeNode: totalNode));
      }else{
        for(int i=0;i<totalNode.length;i++){
          for(int j=0;j<totalNode[i].children.length;j++){
            for(int k=0;k<totalNode[i].children[j].children.length;k++){
              if(totalNode[i].children[j].children[k].title.contains(searchedValue)){
                if(totalNode[i].children[j].children[k].isSelected){
                  searchedTreeNode.add(TreeNode(title: totalNode[i].children[j].children[k].title,isSelected: true));
                }else{
                  searchedTreeNode.add(TreeNode(title: totalNode[i].children[j].children[k].title,isSelected: false));
                }

              }
            }
          }
        }

        emit(SearchDrawerDevicesSuccess(treeNode: searchedTreeNode));
      }
    }catch(e){
      emit(SearchDrawerDevicesFailed());
    }
  }

  List<TreeNode> _makeSubNodes(List<Group> groups, List<TreeNode> totalNode) {
    try{
      for(int i=0;i<totalNode.length;i++){
        List<TreeNode> subNodes = [];
        for(int j=0;j<groups.length;j++){
          if(groups[j].groupId != 0){
            String rootName = getGroupNameWithId(groups, groups[j].groupId );
            if(totalNode[i].title == rootName){
              subNodes.add(TreeNode(title: groups[j].name));
            }
          }
        }
        totalNode[i].children =subNodes;
      }
      return totalNode;
    }catch(e){
      return totalNode;
    }
  }

  List<TreeNode> _makeNodes(List<Device> devices, List<Group> groups) {
    List<TreeNode> totalNode =[];
    try{
      totalNode = _makeRootNodes(groups);
      totalNode = _makeSubNodes(groups, totalNode);
      for(int i=0;i<totalNode.length;i++){
        for(int j=0;j<totalNode[i].children.length;j++){
          List<TreeNode> nodes = [];
          for(int k=0;k<devices.length;k++){
            if(devices[k].groupId == 0){
              //devices with no sub group
            }else{
              String subName = getGroupNameWithId(groups, devices[k].groupId);
              if(subName == totalNode[i].children[j].title){
                nodes.add(TreeNode(title: devices[k].name));
              }
            }
          }
          totalNode[i].children[j].children = nodes;
        }
      }
      return totalNode;
    }catch(e){
      return totalNode;
    }

  }

  List<TreeNode> _makeRootNodes(List<Group> groups) {
    List<TreeNode> totalNode = [];
    for(int i=0;i<groups.length;i++){
      if(groups[i].groupId == 0){
        TreeNode rootNode = TreeNode(title: groups[i].name);
        totalNode.add(rootNode);
      }
    }
    return totalNode;
  }

  String getGroupNameWithId(List<Group> groups, int groupId){
    for(int i=0;i<groups.length;i++){
      if(groups[i].id == groupId){
        return groups[i].name;
        break;
      }
    }
    return "";
  }
}
