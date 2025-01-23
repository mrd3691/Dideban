import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dideban/models/offline_report.dart';
import 'package:meta/meta.dart';

import '../../data/offline_report_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
import '../../utilities/util.dart';

part 'offline_report_event.dart';
part 'offline_report_state.dart';

class OfflineReportBloc extends Bloc<OfflineReportEvent, OfflineReportState> {
  OfflineReportBloc() : super(OfflineReportInitial()) {
    on<FetchOfflineReport>(fetchOfflineReport);
    on<LoadDrawerOfflineReport>(loadDrawerOfflineReport);
    on<SearchDrawerDevicesOfflineReport>(searchDrawerDevicesOfflineReport);
    on<SearchOfflineReport>(searchOfflineReport);
  }

  FutureOr<void> searchOfflineReport(SearchOfflineReport event, Emitter<OfflineReportState> emit,) async{
    try{
      emit(SearchOfflineReportIsLoading());
      List<OfflineReport> searchedOfflineReport = [];
      for(int i=0;i<event.offlineReport!.length;i++){
        String device = event.offlineReport![i].device;
        String driver = event.offlineReport![i].driver;
        if(device.contains(event.searchedString) || driver.contains(event.searchedString)){
          searchedOfflineReport.add(event.offlineReport![i]);
        }
      }
      emit(SearchOfflineReportSuccess(offlineReport: searchedOfflineReport, treeNode: event.treeNode));
    }catch(e){
      emit(SearchOfflineReportFailed(e.toString()));
    }

  }

  FutureOr<void> fetchOfflineReport(FetchOfflineReport event, Emitter<OfflineReportState> emit,) async{
    try{
      emit(OfflineReportInProgress());

      List<String> deviceNames = event.deviceNames;
      int timeTreshold = event.timeTreshold;

      List<OfflineReport> offlineReports = [];
      for(int i=0;i<deviceNames.length;i++){
        final offlineReport =await OfflineReportApi.fetchOfflineReport(deviceNames[i],timeTreshold);
        if(offlineReport != null) {
          if(offlineReport.message!="no_data_available" && offlineReport.message!="online"){
            offlineReports.add(offlineReport);
          }
        }
      }
      emit(OfflineReportSuccess(treeNode: event.treeNode, offlineReport: offlineReports));
    }catch(e){
      emit(OfflineReportFailure(e.toString()));
    }
  }

  FutureOr<void> loadDrawerOfflineReport(LoadDrawerOfflineReport event, Emitter<OfflineReportState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await OfflineReportApi.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await OfflineReportApi.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesOfflineReport(SearchDrawerDevicesOfflineReport event, Emitter<OfflineReportState> emit,) async {
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
