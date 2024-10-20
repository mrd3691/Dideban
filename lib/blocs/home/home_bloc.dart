import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dideban/data/home_api.dart';
import 'package:dideban/models/group.dart';
import 'package:dideban/models/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';

import '../../models/device.dart';
import '../../presentation/widgets/car_position.dart';
import '../../presentation/widgets/treeview_checkbox.dart';
import '../../utilities/util.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadDrawer>(loadDrawer);
    on<SearchDrawerDevices>(searchDrawerDevices);
    on<GetLocationOfSelectedDevices>(getLocationOfSelectedDevices);
    on<Update>(update);
  }

  FutureOr<void> update(Update event, Emitter<HomeState> emit,) async {

    List<TreeNode> treeNodes = event.treeNode;
    List<Marker>? markers;
    bool isOriginalTreeNode = event.isOriginalTreeNode;
    try{
      markers = await _makeLocationList(treeNodes,isOriginalTreeNode);
      emit(UpdateSuccess(markers: markers, treeNode: treeNodes));
    }catch(e){
      emit(UpdateFailure());
    }


  }

  FutureOr<void> getLocationOfSelectedDevices(GetLocationOfSelectedDevices event, Emitter<HomeState> emit,) async {

    emit(GetLocationOfSelectedDevicesInProgress());
    List<TreeNode> treeNodes = event.treeNode;
    List<Marker>? markers;
    bool isOriginalTreeNode = event.isOriginalTreeNode;
    try{
      markers = await _makeLocationList(treeNodes,isOriginalTreeNode);

      emit(GetLocationOfSelectedDevicesSuccess(markers: markers,treeNode: treeNodes));
    }catch(e){
      emit(GetLocationOfSelectedDevicesFailure(""));
    }


  }

  FutureOr<void> loadDrawer(LoadDrawer event, Emitter<HomeState> emit,) async {
    emit(DrawerIsLoading());
    try{
      final devices  = await HomeAPI.getAllDevices();
      if(devices == null){
        emit(DrawerLoadFailed());
      }
      final groups  = await HomeAPI.getAllGroups();
      List<TreeNode> totalNode = _makeNodes(devices!,groups!);
      emit(DrawerLoadSuccess(treeNode: totalNode));
    }catch(e){
      emit(DrawerLoadFailed());
    }
  }

  FutureOr<void> searchDrawerDevices(SearchDrawerDevices event, Emitter<HomeState> emit,) async {
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

  int getDeviceIdWithName(List<Device> devices, String name){
    try{
      for(int i=0;i<devices.length;i++){
        if(devices[i].name == name){
          return devices[i].id;
        }
      }
      return 0;
    }catch(e){
      return 0;
    }
  }

  Future<List<Marker>?> _makeLocationList(List<TreeNode> treeNode, bool isOriginalTreeNode)async{
    List<Marker> carMarkers = [];
    bool noDeviceSelected =true;
    try{
      final devices = await HomeAPI.getAllDevices();
      if(isOriginalTreeNode){
        for (int i = 0; i < treeNode.length; i++) {
          for (int j = 0; j < treeNode[i].children.length; j++) {
            for(int k=0;k<treeNode[i].children[j].children.length;k++){
              if(treeNode[i].children[j].children[k].isSelected){
                noDeviceSelected =false;
                int id = getDeviceIdWithName(devices!, treeNode[i].children[j].children[k].title);
                final devicePosition = await HomeAPI.getPosition(id);
                if(devicePosition != null){
                  final drivers = await HomeAPI.getDeviceDriver(id);
                  String driver ="";
                  if(drivers!=null && drivers.length>0){
                    driver =drivers[0].name;
                  }
                  String speed = (devicePosition.speed!*1.852).round().toString();
                  String jalaliDateTime=Util.georgianToJalaliWithGMTConvert(devicePosition.fixTime!);
                  carMarkers.add(
                      CarMarker(car:
                        Car(
                          name: treeNode[i].children[j].children[k].title,
                          speed: speed,
                          dateTime: jalaliDateTime,
                          acc: _getIgnitionFromAttributes(devicePosition.attributes),
                          driver: driver,
                          lat: devicePosition.latitude!,
                          long: devicePosition.longitude!
                        )
                      )
                  );

                }
              }
            }
          }
        }
      }else{
        for (int i = 0; i < treeNode.length; i++) {
          if(treeNode[i].isSelected){
            noDeviceSelected =false;
            int id = getDeviceIdWithName(devices!, treeNode[i].title);
            final devicePosition = await HomeAPI.getPosition(id);
            if(devicePosition != null){
              final drivers = await HomeAPI.getDeviceDriver(id);
              String driver ="";
              if(drivers!=null && drivers.length>0){
                driver =drivers[0].name;
              }
              String jalaliDateTime=Util.georgianToJalaliWithGMTConvert(devicePosition.fixTime!);
              String speed = (devicePosition.speed!*1.852).round().toString();
              carMarkers.add(
                  CarMarker(car:
                  Car(
                      name: treeNode[i].title,
                      speed: speed,
                      dateTime: jalaliDateTime,
                      acc: _getIgnitionFromAttributes(devicePosition.attributes),
                      driver: driver,
                      lat: devicePosition.latitude!,
                      long: devicePosition.longitude!
                  )
                  )
              );
            }
          }
        }
      }
      if(noDeviceSelected){
        return null;
      }
      return carMarkers;
    }catch(e){
      return carMarkers;
    }

  }

  String _getIgnitionFromAttributes(PositionAttributes? attributes){
    try{
      final ignition = attributes!.ignition;
      if(ignition != null){
        if(ignition){
          return "ON";
        }else{
          return "OFF";
        }
      }
      return "unknown";
    }catch(e){
      return "unknown";
    }
  }
}
