import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:dideban/data/home_api.dart';
import 'package:dideban/models/group.dart';
import 'package:dideban/models/position.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';

import '../../config.dart';
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
    on<Update>(update);


  }

  late List<Device>? devices;

  void getDevices()async{
    devices = await HomeAPI.getAllDevices();
  }





  FutureOr<void> update(Update event, Emitter<HomeState> emit,) async {
    List<Marker>? markers;
    try{
      markers = await _makeLocationList(event.treeNode,event.isOriginalTreeNode,event.clickedTreeNode);
      emit(UpdateSuccess(markers: markers));
    }catch(e){
      emit(UpdateFailure());
    }
  }




  FutureOr<void> loadDrawer(LoadDrawer event, Emitter<HomeState> emit,) async {

    getDevices();
    //getLastPositions();


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
        for(int i=0;i<totalNode[0].children.length;i++){
          for(int j=0;j<totalNode[0].children[i].children.length;j++){
            for(int k=0;k<totalNode[0].children[i].children[j].children.length;k++){
              if(totalNode[0].children[i].children[j].children[k].title.contains(searchedValue)){
                if(totalNode[0].children[i].children[j].children[k].isSelected){
                  searchedTreeNode.add(TreeNode(title: totalNode[0].children[i].children[j].children[k].title,isSelected: true));
                }else{
                  searchedTreeNode.add(TreeNode(title: totalNode[0].children[i].children[j].children[k].title,isSelected: false));
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

      List<TreeNode> totalNode1 =[];
      TreeNode organNode = TreeNode(title: "${Config.organ}");
      organNode.children = totalNode;
      totalNode1.add(organNode);
      return totalNode1;
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

  String getDeviceNameWithId(int deviceId){
    try{
      for(int i=0;i<devices!.length;i++){
        if(devices![i].id == deviceId){
          return devices![i].name;
          break;
        }
      }
      return "";
    }catch(e){
      return "";
    }
  }



  Future<List<Marker>?> _makeLocationList(List<TreeNode> treeNode, bool isOriginalTreeNode,TreeNode clickedTreeNode)async{
    List<Marker> carMarkers = [];
    List<Position>? positions;
    try{
      positions  = await HomeAPI.getLastPositions();

      if(isOriginalTreeNode){
        for (int i = 0; i < treeNode[0].children.length; i++) {
          for (int j = 0; j <treeNode[0].children[i].children.length; j++) {
            for (int k = 0; k < treeNode[0].children[i].children[j].children.length; k++) {
              if (treeNode[0].children[i].children[j].children[k].isSelected){
                for(int m =0;m<positions!.length;m++){
                  String name = getDeviceNameWithId(positions[m].deviceId);
                  if(name == treeNode[0].children[i].children[j].children[k].title){
                    String speed = (positions[m].speed!*1.852).round().toString();
                    String jalaliDateTime=Util.georgianToJalaliWithGMTConvert(positions[m].fixTime!);
                    carMarkers.add(
                        CarMarkerLive(car:
                        Car(
                            name: name,
                            speed: speed,
                            dateTime: jalaliDateTime,
                            acc: _getIgnitionFromAttributes(positions[m].attributes),
                            driver: "",
                            lat: positions[m].latitude!,
                            long: positions[m].longitude!,
                            course: positions[m].course!,
                            fuelLevel: positions[m].attributes!.fuelLevel!,
                            mileage: (positions[m].attributes!.mileage!).round()

                        ), clickedTreeNode: clickedTreeNode
                        )
                    );
                    break;
                  }
                }
              }
            }
          }
        }
      }else{
        for (int i = 0; i < treeNode.length; i++) {
          if (treeNode[i].isSelected){
            for(int m =0;m<positions!.length;m++){
              String name = getDeviceNameWithId(positions[m].deviceId);
              if(name == treeNode[i].title){
                String speed = (positions[m].speed!*1.852).round().toString();
                String jalaliDateTime=Util.georgianToJalaliWithGMTConvert(positions[m].fixTime!);
                carMarkers.add(
                    CarMarkerLive(car:
                    Car(
                        name: name,
                        speed: speed,
                        dateTime: jalaliDateTime,
                        acc: _getIgnitionFromAttributes(positions[m].attributes),
                        driver: "",
                        lat: positions[m].latitude!,
                        long: positions[m].longitude!,
                        course: positions[m].course!,
                        fuelLevel: positions[m].attributes!.fuelLevel!,
                        mileage: (positions[m].attributes!.mileage!).round()
                    ), clickedTreeNode: clickedTreeNode
                    )
                );
                break;
              }
            }
          }
        }
      }


      /*for(int i =0;i<positions!.length;i++){
        String speed = (positions[i].speed!*1.852).round().toString();
        String jalaliDateTime=Util.georgianToJalaliWithGMTConvert(positions[i].fixTime!);
        String name = getDeviceNameWithId(positions[i].deviceId);
        carMarkers.add(
            CarMarker(car:
            Car(
                name: name,
                speed: speed,
                dateTime: jalaliDateTime,
                acc: _getIgnitionFromAttributes(positions[i].attributes),
                driver: "",
                lat: positions[i].latitude!,
                long: positions[i].longitude!
            )
            )
        );
      }*/
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
