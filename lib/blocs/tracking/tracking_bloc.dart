import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dideban/data/tracking_api.dart';
import 'package:dideban/utilities/util.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';
import 'package:dideban/data/api.dart';

import '../../models/device.dart';
import '../../models/group.dart';
import '../../presentation/widgets/car_position.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc() : super(TrackingInitial()) {
    on<FetchTrackingPoints>(fetchTrackingPoints);
    on<SliderChanged>(sliderChanged);
    on<LoadDrawerTracking>(loadDrawerTracking);
    on<SearchDrawerDevicesTracking>(searchDrawerDevicesTracking);
  }

  FutureOr<void> fetchTrackingPoints(FetchTrackingPoints event, Emitter<TrackingState> emit,) async{
    try{
      emit(TrackingInProgress());
      String deviceName = event.deviceName;
      /*String startDate = Util.jalaliToGeorgian(event.startDate);
        String startTime = event.startTime;
        String endDate = Util.jalaliToGeorgian(event.endDate);
        String endTime = event.endTime;
        String startDateTime = "$startDate $startTime";
        String endDateTime = "$endDate $endTime";*/

      String startDateTime =Util.jalaliToGeorgianGMTConvert(event.startDate,event.startTime);
      String endDateTime =Util.jalaliToGeorgianGMTConvert(event.endDate,event.endTime);




      final points =await API.fetchTrackingPoints(deviceName, startDateTime, endDateTime);
      List<Marker> carMarkers = [];
      if(points!.isEmpty){
        emit(TrackingSuccess(markers: carMarkers,treeNode: event.treeNode));
      }
      points.forEach((element) async {


        /*final drivers = await HomeAPI.getDeviceDriver(id);
        String driver ="";
        if(drivers!=null && drivers.length>0){
          driver =drivers[0].name;
        }
        String speed = (devicePosition.speed!*1.852).round().toString();
        String jalaliDateTime=Util.georgianToJalaliWithGMTConvert(devicePosition.fixTime!);*/



        carMarkers.add(
            CarMarkerTracking(
                car: Car(
                  name: deviceName,
                  speed:  element.speed,
                  dateTime:  element.fixTime,
                  acc:   _getIgnitionFromAttributes(element.attributes) ,
                  driver: element.driver,
                  lat: double.parse(element.latitude),
                  long: double.parse(element.longitude),
                  course: -1,
                  fuelLevel: 0,
                  mileage: 0

                )
            ));
      });
      emit(TrackingSuccess(markers: carMarkers,treeNode: event.treeNode));
    }catch(e){
      emit(TrackingFailure(e.toString()));
    }
  }

  FutureOr<void> sliderChanged(SliderChanged event, Emitter<TrackingState> emit,) async{
    double newValue = event.sliderValue;
    emit(SliderNewState(newValue,event.markers,event.treeNode));
  }

  FutureOr<void> loadDrawerTracking(LoadDrawerTracking event, Emitter<TrackingState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await TrackingAPI.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await TrackingAPI.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevicesTracking(SearchDrawerDevicesTracking event, Emitter<TrackingState> emit,) async {
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

  String _getIgnitionFromAttributes(String attributes){
    try{
      final parsed = jsonDecode(attributes);
      bool ignition = parsed["ignition"];
      if(ignition){
        return "ON";
      }else{
        return "OFF";
      }
    }catch(e){
      return "unknown";
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
