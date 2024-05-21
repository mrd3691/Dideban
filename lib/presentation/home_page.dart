import 'dart:convert';
import 'package:dideban/presentation/tracking.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:dideban/blocs/devices/devices_bloc.dart';
import 'package:dideban/blocs/tracking/tracking_bloc.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:latlong2/latlong.dart';
import 'package:dideban/presentation/widgets/car_position.dart';
import 'login.dart';

class Home extends StatelessWidget {
  Home(this.username,this.id ,{ super.key});
  String username = "";
  String id = "";
  List<TreeNode> treeNode = [];
  List<Marker> markers = [];
  final PopupController _popupLayerController = PopupController();
  TextEditingController searchedValueController = TextEditingController();

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
          appBar: AppBar(
            title: Text("user:$username  id:$id"),
            actions: [

              IconButton(
                tooltip: "report",
                icon: const Icon(
                  Icons.report_gmailerrorred_rounded,
                ),
                onPressed: () {},
              ),
              IconButton(
                tooltip: "tracking",
                icon: const Icon(
                  Icons.track_changes,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) =>
                          MultiBlocProvider(providers: [
                            BlocProvider(create: (context) => DevicesBloc()..add(FetchAllDevices(id))),
                            BlocProvider(create: (context) => TrackingBloc())
                          ], child: Tracking(username,id)),
                          /*BlocProvider(
                            create: (context) =>
                            DevicesBloc()
                              ..add(
                                FetchAllDevices(id),
                              ),
                            child: Tracking(username,id),
                          ),*/
                    ),
                  );
                },
              ),
              IconButton(
                tooltip: "setting",
                icon: const Icon(
                  Icons.settings,
                ),
                onPressed: () {},
              ),
              IconButton(
                tooltip: "account",
                icon: const Icon(
                  Icons.account_circle,
                ),
                onPressed: () {},
              ),
              IconButton(
                tooltip: "logout",
                icon: const Icon(
                  Icons.logout,
                ),
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
              ),
            ],
          ),
          body:homeBody(context),
          drawer: drawer(context)
        ));
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
              return Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                    const CircularProgressIndicator(
                      color: Colors.red,
                    ),
                    Text("Loading..."),
                  ],
                ),
              );
            }
            if (state is DevicesLoadFailure) {
              return Center(
                child: Text(state.message ?? "Some Error Occured"),
              );
            }
            if (state is DevicesLoadSuccess) {
              treeNode = state.treeNode;
            }
            if (state is SearchDevicesLoadSuccess){
              return Column(children: [
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      if(searchedValueController.text.isEmpty){
                        context.read<DevicesBloc>().add(GetDevicesLocation(newNodes),);
                      }else{
                        context.read<DevicesBloc>().add(GetDevicesLocationFromSearchedNodes(newNodes),);
                      }
                    },
                    nodes: state.searchedTreeNode,
                  ),
                ),
              ]);
            }
            if (state is GetDevicesLocationSuccess){
              return Column(children: [
                Container(
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      if(searchedValueController.text.isEmpty){
                        context.read<DevicesBloc>().add(GetDevicesLocation(newNodes),);
                      }else{
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
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.9,
                child: TreeView(
                  onChanged: (newNodes) {
                    if(searchedValueController.text.isEmpty){
                      context.read<DevicesBloc>().add(GetDevicesLocation(newNodes),);
                    }else{
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
    return FlutterMap(
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
          urlTemplate:
          'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
        ),

        BlocBuilder<DevicesBloc, DevicesState>(
          builder: (context, state) {
            if(state is GetDevicesLocationSuccess){
              markers = state.markers;
            }
            if(state is GetLocationLoadingInProgress){

            }

            return PopupMarkerLayer(
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
            );

          },
        ),

      ],
    );
  }
}
