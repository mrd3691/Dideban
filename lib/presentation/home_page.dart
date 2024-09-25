import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:dideban/blocs/devices/devices_bloc.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:latlong2/latlong.dart';
import 'package:dideban/presentation/widgets/car_position.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<TreeNode> treeNode = [];
  List<TreeNode> treeNodeForUpdate = [];
  List<Marker> markers = [];
  final PopupController _popupLayerController = PopupController();
  final MapController _mapController = MapController();
  TextEditingController searchedValueController = TextEditingController();



  void update(){

    Timer timer = Timer.periodic(Duration(seconds: 60), (Timer timer) {
        int t = timer.tick;
      _popupLayerController.hideAllPopups();
      if(treeNodeForUpdate.length != 0){
        if(isAnyDeviceSelected(treeNodeForUpdate)){
          if(searchedValueController.text.isEmpty){
            EasyLoading.show(status: "Updating");
            context.read<DevicesBloc>().add(GetDevicesLocation(treeNodeForUpdate),);
          }else{
            EasyLoading.show(status: "Updating");
            context.read<DevicesBloc>().add(GetDevicesLocationFromSearchedNodes(treeNodeForUpdate),);
          }
        }
      }
    });

  }


  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    update();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _popupLayerController.dispose();
    _mapController.dispose();
    searchedValueController.dispose();
  }






  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dideban",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
          //appBar: DidebanAppBar.call(widget.username,widget.userId,context),
        appBar: const AppBarDideban(),
          body: homeBody(context),
          drawer: drawer(context)
      ),
      /*routes:{
          //"/":(context) => LoginScreen(),
          '/home': (context) => Home(username,id),
        } ,*/
    );
  }

  bool isAnyDeviceSelected(List<TreeNode> treeNode){
    int i, j;
    for (i = 0; i < treeNode.length; i++) {
      if(treeNode[i].checkBoxState == CheckBoxState.selected ){
        return true;
      }
      for (j = 0; j < treeNode[i].children.length; j++) {
        TreeNode child = treeNode[i].children[j];
        if (child.checkBoxState == CheckBoxState.selected) {
          return true;
        }
      }
    }
    return false;
  }

  Widget drawer(BuildContext context){
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                ),
                controller: searchedValueController,
                onChanged: (value) {
                  //final currentNode = context.read<DevicesBloc>().state;
                  context.read<DevicesBloc>().add(SearchDevices(treeNode, value),);
                },
              ),
            ),
          ),
          BlocBuilder<DevicesBloc, DevicesState>(builder: (context, state) {
            if (state is DevicesLoadingInProgress) {
              return SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Shimmer.fromColors(
                    baseColor: Colors.grey.shade400,
                    highlightColor: Colors.white,
                    child: ListView.builder(
                        itemCount: 10,
                        itemBuilder: (context, index){
                          return Row(
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 8.0,bottom: 8,left: 15),
                                child: CircleAvatar(
                                  backgroundColor: Colors.white,
                                  radius: 30,
                                  child: Icon(Icons.add),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0, left: 8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 100,
                                      height: 15,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(10),
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: SizedBox(
                                        width: 50,
                                        height: 15,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(10),
                                            color: Colors.white,
                                          ),                                                       ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),


                            ],
                          );
                        }
                    )
                ),
              );
            }
            if (state is DevicesLoadFailure) {
              return Center(
                child: Text(state.message ?? "Some Error Occured in loading Devices list"),
              );
            }
            if (state is DevicesLoadSuccess) {
              treeNode = state.treeNode;
              treeNodeForUpdate = state.treeNode;
            }
            if(state is SearchDevicesLoadSuccess){
              treeNodeForUpdate = state.searchedTreeNode;
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      _popupLayerController.hideAllPopups();
                      if(searchedValueController.text.isEmpty){
                        EasyLoading.show(status: "Please Wait");
                        context.read<DevicesBloc>().add(GetDevicesLocation(newNodes),);
                      }else{
                        EasyLoading.show(status: "Please Wait");
                        context.read<DevicesBloc>().add(GetDevicesLocationFromSearchedNodes(newNodes),);
                      }
                    },
                    nodes: state.searchedTreeNode,
                  ),
                ),
              ]);
            }
            if(state is GetDevicesLocationSuccess){
              treeNodeForUpdate = state.treeNode;
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      _popupLayerController.hideAllPopups();
                      if(searchedValueController.text.isEmpty){
                        EasyLoading.show(status: "Please Wait");
                        context.read<DevicesBloc>().add(GetDevicesLocation(newNodes),);
                      }else{
                        EasyLoading.show(status: "Please Wait");
                        context.read<DevicesBloc>().add(GetDevicesLocationFromSearchedNodes(newNodes),);
                      }
                    },
                    nodes: state.treeNode,
                  ),
                ),
              ]);
            }
            return Column(children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: TreeView(
                  onChanged: (newNodes) {
                    _popupLayerController.hideAllPopups();
                    if(searchedValueController.text.isEmpty){
                      EasyLoading.show(status: "Please Wait");
                      context.read<DevicesBloc>().add(GetDevicesLocation(newNodes),);
                    }else{
                      EasyLoading.show(status: "Please Wait");
                      context.read<DevicesBloc>().add(GetDevicesLocationFromSearchedNodes(newNodes),);
                    }
                  },
                  nodes: treeNode,
                ),
              ),
            ]);
          }),
        ],
      ),
    );
  }

  Widget homeBody(BuildContext context){
    return BlocBuilder<DevicesBloc, DevicesState>(
      builder: (context, state) {
        if(state is GetDevicesLocationSuccess){
          EasyLoading.dismiss();
          markers = state.markers;
          LatLng newCenter =const LatLng(33.81275, 51.52094);
          double newZoom =5.0;
          if(markers.length==1){
            newCenter = LatLng(markers[0].point.latitude, markers[0].point.longitude); // New center (e.g., Paris)
            newZoom = 12.0; // New zoom level
            //_mapController.move(newCenter, newZoom);
          }
          _mapController.move(newCenter, newZoom);
          if(markers.isEmpty &&  isAnyDeviceSelected(state.treeNode)){
            EasyLoading.showError("No data available");
          }
          return FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter:  newCenter,
              initialZoom: newZoom,
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all,
              ),
              onTap: (_, __) => _popupLayerController.hideAllPopups(),
            ),
            children: <Widget>[
              TileLayer(
                urlTemplate: 'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
                tileProvider: CancellableNetworkTileProvider() // Use the cancellable tile provider

                //urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              ),

              PopupMarkerLayer(
                options: PopupMarkerLayerOptions(
                  markers: markers,
                  popupController: _popupLayerController,
                  popupDisplayOptions: PopupDisplayOptions(
                    builder: (_, Marker marker) {
                      if(marker is CarMarker) {
                        return CarMarkerPopup(car: marker.car);
                      }
                      return const Card(child: Text('No data available'));
                      //return  Card(child: marker.child);
                    },
                  ),

                ),
              )
            ],
          );
        }
        return FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(33.81275, 51.52094),
            initialZoom: 5.0,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.all,
            ),
            onTap: (_, __) => _popupLayerController.hideAllPopups(),
          ),
          children: <Widget>[
            TileLayer(
              //urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
              urlTemplate: 'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
              tileProvider: CancellableNetworkTileProvider(),
            ),
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: markers,
                popupController: _popupLayerController,
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (_, Marker marker) {
                    if(marker is CarMarker) {
                      return CarMarkerPopup(car: marker.car);
                    }
                    return const Card(child: Text('No data available'));
                    //return  Card(child: marker.child);
                  },
                ),

              ),
            )
          ],
        );
      },
    );
  }

}



