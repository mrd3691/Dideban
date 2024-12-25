import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dideban/models/detail_speed_report.dart';
import 'package:meta/meta.dart';

import '../../data/detail_speed_report_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
import '../../utilities/util.dart';

part 'detail_speed_report_event.dart';
part 'detail_speed_report_state.dart';

class DetailSpeedReportBloc extends Bloc<DetailSpeedReportEvent, DetailSpeedReportState> {
  DetailSpeedReportBloc() : super(DetailSpeedReportInitial()) {
    on<FetchDetailSpeedReport>(fetchDetailSpeedReport);
    on<LoadDrawerDetailSpeedReport>(loadDrawerDetailSpeedReport);
    on<SearchDrawerDevicesDetailSpeedReport>(searchDrawerDevicesDetailSpeedReport);

    on<SearchDetailSpeedReport>(searchDetailSpeedReport);
  }

  FutureOr<void> searchDetailSpeedReport(SearchDetailSpeedReport event, Emitter<DetailSpeedReportState> emit,) async{
    try{
      emit(SearchDetailSpeedReportIsLoading());
      DetailSpeedReport searchedTotalSpeedReport = DetailSpeedReport(isSuccess: true, message: "", device: event.detailSpeedReport!.device,
          driver: event.detailSpeedReport!.driver,
          group: event.detailSpeedReport!.group,
          overSpeedPoints: []);
      for(int i=0;i<event.detailSpeedReport!.overSpeedPoints.length;i++){
        int speed = event.detailSpeedReport!.overSpeedPoints[i].speed;
        if(speed  >= int.parse(event.searchedString)){
          searchedTotalSpeedReport.overSpeedPoints.add(event.detailSpeedReport!.overSpeedPoints[i]);
        }
      }
      emit(SearchDetailSpeedReportSuccess(detailSpeedReport: searchedTotalSpeedReport, treeNode: event.treeNode));
    }catch(e){
      emit(SearchDetailSpeedReportFailed(e.toString()));
    }

  }

  FutureOr<void> fetchDetailSpeedReport(FetchDetailSpeedReport event, Emitter<DetailSpeedReportState> emit,) async{
    try{
      emit(DetailSpeedReportInProgress());

      String deviceNames = event.deviceNames;
      String startDateTime =Util.jalaliToGeorgianGMTConvert(event.startDate,event.startTime);
      String endDateTime =Util.jalaliToGeorgianGMTConvert(event.endDate,event.endTime);
      int speedLimit = (event.speedLimit/1.852).round();


      final detailSpeedReport =await DetailSpeedReportApi.fetchDetailSpeedReport(deviceNames, startDateTime, endDateTime,speedLimit);


      emit(DetailSpeedReportSuccess(treeNode: event.treeNode, detailSpeedReport: detailSpeedReport!));
    }catch(e){
      emit(DetailSpeedReportFailure(e.toString()));
    }
  }

  FutureOr<void> loadDrawerDetailSpeedReport(LoadDrawerDetailSpeedReport event, Emitter<DetailSpeedReportState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await DetailSpeedReportApi.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await DetailSpeedReportApi.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesDetailSpeedReport(SearchDrawerDevicesDetailSpeedReport event, Emitter<DetailSpeedReportState> emit,) async {
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
