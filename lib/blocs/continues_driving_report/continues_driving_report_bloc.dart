import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dideban/models/continues_driving_report.dart';
import 'package:meta/meta.dart';

import '../../data/continues_driving_report_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
import '../../utilities/util.dart';

part 'continues_driving_report_event.dart';
part 'continues_driving_report_state.dart';

class ContinuesDrivingReportBloc extends Bloc<ContinuesDrivingReportEvent, ContinuesDrivingReportState> {
  ContinuesDrivingReportBloc() : super(ContinuesDrivingReportInitial()) {
    on<FetchContinuesDrivingReport>(fetchContinuesDrivingReport);
    on<LoadDrawerContinuesDrivingReport>(loadDrawerContinuesDrivingReport);
    on<SearchDrawerDevicesContinuesDrivingReport>(searchDrawerDevicesContinuesDrivingReport);

    on<SearchContinuesDrivingReport>(searchContinuesDrivingReport);
  }


  FutureOr<void> searchContinuesDrivingReport(SearchContinuesDrivingReport event, Emitter<ContinuesDrivingReportState> emit,) async{
    try{
      emit(SearchContinuesDrivingReportIsLoading());
      List<ContinuesDrivingReport> searchedContinuesDrivingReport = [];
      for(int i=0;i<event.continuesDrivingReport!.length;i++){
        String device = event.continuesDrivingReport![i].device;
        String driver = event.continuesDrivingReport![i].driver;
        if(device.contains(event.searchedString) || driver.contains(event.searchedString)){
          searchedContinuesDrivingReport.add(event.continuesDrivingReport![i]);
        }
      }
      emit(SearchContinuesDrivingReportSuccess(continuesDrivingReport: searchedContinuesDrivingReport, treeNode: event.treeNode));
    }catch(e){
      emit(SearchContinuesDrivingReportFailed(e.toString()));
    }

  }

  FutureOr<void> fetchContinuesDrivingReport(FetchContinuesDrivingReport event, Emitter<ContinuesDrivingReportState> emit,) async{
    try{
      emit(ContinuesDrivingReportInProgress());

      List<String> deviceNames = event.deviceNames;
      String startDateTime =Util.jalaliToGeorgianGMTConvert(event.startDate,event.startTime);
      String endDateTime =Util.jalaliToGeorgianGMTConvert(event.endDate,event.endTime);
      int stopTreshold = event.stopTreshold;

      List<ContinuesDrivingReport> continuesDrivingReports = [];
      for(int i=0;i<deviceNames.length;i++){
        final continuesDrivingReport =await ContinuesDrivingReportApi.fetchContinuesDrivingReport(deviceNames[i], startDateTime, endDateTime,stopTreshold);
        if(continuesDrivingReport != null) {
          continuesDrivingReports.add(continuesDrivingReport);
        }
      }
      emit(ContinuesDrivingReportSuccess(treeNode: event.treeNode, continuesDrivingReport: continuesDrivingReports));
    }catch(e){
      emit(ContinuesDrivingReportFailure(e.toString()));
    }
  }

  FutureOr<void> loadDrawerContinuesDrivingReport(LoadDrawerContinuesDrivingReport event, Emitter<ContinuesDrivingReportState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await ContinuesDrivingReportApi.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await ContinuesDrivingReportApi.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesContinuesDrivingReport(SearchDrawerDevicesContinuesDrivingReport event, Emitter<ContinuesDrivingReportState> emit,) async {
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
