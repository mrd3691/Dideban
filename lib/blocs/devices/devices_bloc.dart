import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';
import 'package:dideban/models/deviceShow.dart';
import 'package:dideban/data/api.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';

import 'package:dideban/presentation/widgets/car_position.dart';

part 'devices_event.dart';
part 'devices_state.dart';

class DevicesBloc extends Bloc<DevicesEvent, DevicesState> {
  DevicesBloc() : super(DevicesInitial()) {
    on<FetchAllDevices>(getDevicesList);
    on<SearchDevices>(searchDevicesList);
    on<GetDevicesLocation>(getDevicesLocation);
    on<GetDevicesLocationFromSearchedNodes>(getDevicesLocationFromSearchedNodes);
  }


  FutureOr<void> getDevicesLocation(GetDevicesLocation event, Emitter<DevicesState> emit,) async {

    emit(GetLocationLoadingInProgress());
    List<TreeNode> treeNodes = event.treeNode;
    List<Marker> markers;
    markers = await _makeLocationList(treeNodes);

    emit(GetDevicesLocationSuccess(markers: markers,treeNode: treeNodes));

  }

  FutureOr<void> getDevicesLocationFromSearchedNodes(GetDevicesLocationFromSearchedNodes event, Emitter<DevicesState> emit,) async {

    emit(GetLocationLoadingInProgress());
    List<TreeNode> treeNodes = event.treeNode;
    List<Marker> markers;
    markers = await _makeLocationListFromSearchedNodes(treeNodes);
    emit(GetDevicesLocationSuccess(markers: markers,treeNode: treeNodes));
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

  Future<List<Marker>> _makeLocationList(List<TreeNode> treeNode)async{

    List<Marker> carMarkers = [];
    try{
      int i, j;
      for (i = 0; i < treeNode.length; i++) {
        for (j = 0; j < treeNode[i].children.length; j++) {
          TreeNode child = treeNode[i].children[j];
          if (child.checkBoxState == CheckBoxState.selected) {
            final deviceLocation = await API.fetchDeviceLocation(child.title);
            if(deviceLocation!.isNotEmpty){
              carMarkers.add(
                  CarMarker(car: Car(
                    name: child.title,
                    speed:  "speed: ${deviceLocation[0].speed}",
                    dateTime:  deviceLocation[0].fixTime,
                    acc:   "ignition: ${_getIgnitionFromAttributes(deviceLocation[0].attributes)}" ,
                    driver: "driver: ${deviceLocation[0].driver}",
                    lat: double.parse(deviceLocation[0].latitude),
                    long: double.parse(deviceLocation[0].longitude),
                  )
                  ));
            }else{
              //print("device ${child.title} has no position");
            }

          }
        }
      }
      return carMarkers;
    }catch(e){
      //print(e);
      return carMarkers;
    }
  }

  Future<List<Marker>> _makeLocationListFromSearchedNodes(List<TreeNode> treeNode)async{
    List<Marker> carMarkers = [];
    try{

      for (int i = 0; i <= treeNode.length-1; i++) {
          if (treeNode[i].checkBoxState == CheckBoxState.selected) {
            final deviceLocation = await API.fetchDeviceLocation(treeNode[i].title);
            carMarkers.add(
                CarMarker(
                    car: Car(
                      name: treeNode[i].title,
                      speed:  "speed: ${deviceLocation![0].speed}",
                      dateTime:  deviceLocation[0].fixTime,
                      acc:   "ignition: ${_getIgnitionFromAttributes(deviceLocation[0].attributes)}" ,
                      driver: "driver: ${deviceLocation[0].driver}",
                      lat: double.parse(deviceLocation[0].latitude),
                      long: double.parse(deviceLocation[0].longitude),
                    )
                )
            );
          }
      }
      return carMarkers;
    }catch(e){
      print(e);
      return carMarkers;
    }
  }


  FutureOr<void> searchDevicesList(
      SearchDevices event,
      Emitter<DevicesState> emit,) async {

    emit(DevicesLoadingInProgress());
    try {
      List<TreeNode> searchedTreeNode=[];
      if(event.searched.isEmpty){
        searchedTreeNode = _makeSearchListWithGroup(event.treeNode,event.searched);
      }else{
        searchedTreeNode = _makeSearchList(event.treeNode,event.searched);
      }

      emit(SearchDevicesLoadSuccess(searchedTreeNode: searchedTreeNode));
    } catch (e) {
      emit(
        DevicesLoadFailure(
          e.toString(),
        ),
      );
    }
  }

  FutureOr<void> getDevicesList(FetchAllDevices event,
      Emitter<DevicesState> emit,) async {
    emit(DevicesLoadingInProgress());

    try {
      final devicesShowList = await API.fetchAllUserDevices(event.userId);

      if (devicesShowList == null) {
        emit(
          DevicesLoadFailure("Some Errors Occured."),
        );
      } else if (devicesShowList.isEmpty) {
        emit(DevicesLoadEmpty());
      } else {
        List<TreeNode> totalNode = _makeNodes(devicesShowList);
        emit(
          DevicesLoadSuccess(
            treeNode: totalNode,
          ),
        );
      }
    } catch (e) {
      emit(
        DevicesLoadFailure(
          e.toString(),
        ),
      );
    }
  }

  List<TreeNode> _makeNodes(List<DeviceShow> devicesList) {

    List<TreeNode> totalNode = [];
    String currentGroup = devicesList[0].groupName;
    int i = 0;
    while (i < devicesList.length) {
      List<TreeNode> nodes = [];
      TreeNode childNode = TreeNode(title: devicesList[i].groupName);
      while (devicesList[i].groupName == currentGroup &&
          i < devicesList.length) {
        nodes.add(TreeNode(
          title: devicesList[i].deviceName,

          )
        );
        i++;
        if (i == devicesList.length) {
          break;
        }
      }
      if (i < devicesList.length) {
        currentGroup = devicesList[i].groupName;
      }
      childNode.children = nodes;
      totalNode.add(childNode);
    }
    return totalNode;
  }

  List<TreeNode> _makeSearchListWithGroup(List<TreeNode> treeNode, String searchedString){
    List<TreeNode> searchedTreeNode = [];
    int i, j;
    for (i = 0; i < treeNode.length; i++) {
      searchedTreeNode.add(TreeNode(title: treeNode[i].title));
    }
    for (i = 0; i < searchedTreeNode.length; i++) {
      List<TreeNode> nodes = [];
      for (j = 0; j < treeNode[i].children.length; j++) {
        TreeNode child = treeNode[i].children[j];
        if (child.title.contains(searchedString)) {
          nodes.add(TreeNode(title: child.title));
        }
      }
      if (nodes.isNotEmpty) {
        searchedTreeNode[i].children = nodes;
      }
    }
    searchedTreeNode.removeWhere((element) => element.children.isEmpty);
    return searchedTreeNode;
  }

  List<TreeNode> _makeSearchList(List<TreeNode> treeNode, String searchedString){
    List<TreeNode> searchedTreeNode = [];
    int i, j;
    for (i = 0; i < treeNode.length; i++) {
      for (j = 0; j < treeNode[i].children.length; j++) {
        TreeNode child = treeNode[i].children[j];
        if (child.title.contains(searchedString)) {
          searchedTreeNode.add(TreeNode(title: child.title));
        }
      }
    }

    return searchedTreeNode;
  }

}