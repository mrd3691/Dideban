import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../../data/night_driving_report_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';
import '../../models/night_driving_report.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
import '../../utilities/util.dart';

part 'night_driving_report_event.dart';
part 'night_driving_report_state.dart';

class NightDrivingReportBloc extends Bloc<NightDrivingReportEvent, NightDrivingReportState> {
  NightDrivingReportBloc() : super(NightDrivingReportInitial()) {
    on<FetchNightDrivingReport>(fetchNightDrivingReport);
    on<LoadDrawerNightDrivingReport>(loadDrawerNightDrivingReport);
    on<SearchDrawerDevicesNightDrivingReport>(searchDrawerDevicesNightDrivingReport);
    on<SearchNightDrivingReport>(searchNightDrivingReport);
  }

  FutureOr<void> searchNightDrivingReport(SearchNightDrivingReport event, Emitter<NightDrivingReportState> emit,) async{
    try{
      emit(SearchNightDrivingReportIsLoading());
      List<NightDrivingReport> searchedNightDrivingReport = [];
      for(int i=0;i<event.nightDrivingReport!.length;i++){
        String device = event.nightDrivingReport![i].device;
        String driver = event.nightDrivingReport![i].driver;
        if(device.contains(event.searchedString) || driver.contains(event.searchedString)){
          searchedNightDrivingReport.add(event.nightDrivingReport![i]);
        }
      }
      emit(SearchNightDrivingReportSuccess(nightDrivingReport: searchedNightDrivingReport, treeNode: event.treeNode));
    }catch(e){
      emit(SearchNightDrivingReportFailed(e.toString()));
    }

  }

  FutureOr<void> fetchNightDrivingReport(FetchNightDrivingReport event, Emitter<NightDrivingReportState> emit,) async{
    try{
      emit(NightDrivingReportInProgress());

      List<String> deviceNames = event.deviceNames;
      String startDateTime =Util.jalaliToGeorgianGMTConvert(event.startDate,event.startTime);
      String endDateTime =Util.jalaliToGeorgianGMTConvert(event.endDate,event.endTime);
      int stopTreshold = event.stopTreshold;
      int drivingTreshold = event.drivingTreshold;

      List<NightDrivingReport> nightDrivingReports = [];
      for(int i=0;i<deviceNames.length;i++){
        final nightDrivingReport =await NightDrivingReportApi.fetchNightDrivingReport(deviceNames[i], startDateTime, endDateTime,stopTreshold,drivingTreshold);

        if(nightDrivingReport != null) {
          String? start_add = await NightDrivingReportApi.ReverseGeocode(nightDrivingReport.start_lat_driving, nightDrivingReport.start_long_driving);

          nightDrivingReport.start_address=start_add!;

          String? end_add = await NightDrivingReportApi.ReverseGeocode(nightDrivingReport.end_lat_driving, nightDrivingReport.end_long_driving);
          nightDrivingReport.end_address=end_add!;
          nightDrivingReports.add(nightDrivingReport);
        }
      }
      emit(NightDrivingReportSuccess(treeNode: event.treeNode, nightDrivingReport: nightDrivingReports));
    }catch(e){
      emit(NightDrivingReportFailure(e.toString()));
    }
  }

  FutureOr<void> loadDrawerNightDrivingReport(LoadDrawerNightDrivingReport event, Emitter<NightDrivingReportState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await NightDrivingReportApi.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await NightDrivingReportApi.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesNightDrivingReport(SearchDrawerDevicesNightDrivingReport event, Emitter<NightDrivingReportState> emit,) async {
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
