import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/last_status_report_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';
import '../../models/last_status_report.dart';
import '../../presentation/widgets/treeview_checkbox.dart';

part 'last_status_report_event.dart';
part 'last_status_report_state.dart';

class LastStatusReportBloc extends Bloc<LastStatusReportEvent, LastStatusReportState> {
  LastStatusReportBloc() : super(LastStatusReportInitial()) {
    on<FetchLastStatusReport>(fetchLastStatusReport);
    on<LoadDrawerLastStatusReport>(loadDrawerLastStatusReport);
    on<SearchDrawerDevicesLastStatusReport>(searchDrawerDevicesLastStatusReport);
    on<SearchLastStatusReport>(searchLastStatusReport);
  }

  FutureOr<void> searchLastStatusReport(SearchLastStatusReport event, Emitter<LastStatusReportState> emit,) async{
    try{
      emit(SearchLastStatusReportIsLoading());
      LastStatusReport searchedLastStatusReport = LastStatusReport(isSuccess: true, message: "", devices: []);
      for(int i=0;i<event.lastStatusReport!.devices.length;i++){
        String device = event.lastStatusReport!.devices[i].deviceName;
        String driver = event.lastStatusReport!.devices[i].driverName;
        if(device.contains(event.searchedString) || driver.contains(event.searchedString)){
          searchedLastStatusReport.devices.add(event.lastStatusReport!.devices[i]);
        }
      }
      emit(SearchLastStatusReportSuccess(lastStatusReport: searchedLastStatusReport, treeNode: event.treeNode));
    }catch(e){
      emit(SearchLastStatusReportFailed(e.toString()));
    }

  }

  FutureOr<void> fetchLastStatusReport(FetchLastStatusReport event, Emitter<LastStatusReportState> emit,) async{
    try{
      emit(LastStatusReportInProgress());
      final lastStatusReport =await LastStatusReportApi.fetchLastStatusReport();
      emit(LastStatusReportSuccess(treeNode: event.treeNode, lastStatusReport: lastStatusReport!));
    }catch(e){
      emit(LastStatusReportFailure(e.toString()));
    }
  }

  FutureOr<void> loadDrawerLastStatusReport(LoadDrawerLastStatusReport event, Emitter<LastStatusReportState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await LastStatusReportApi.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await LastStatusReportApi.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesLastStatusReport(SearchDrawerDevicesLastStatusReport event, Emitter<LastStatusReportState> emit,) async {
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
