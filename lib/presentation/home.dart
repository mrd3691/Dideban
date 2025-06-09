

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dideban/blocs/home/home_bloc.dart';
import 'package:dideban/config.dart';
import '../../utilities/util.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:latlong2/latlong.dart';
import 'package:dideban/presentation/widgets/car_position.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  List<TreeNode> originalTreeNode = [];
  List<TreeNode> searchedTreeNode = [];
  List<TreeNode> selectedTreeNode = [];


  TextEditingController searchedValueController = TextEditingController();
  List<Marker>? markers = [];
  final MapController _mapController = MapController();
  bool rebuildDrawer=true;



  String clickedDeviceName="";
  String clickedDeviceSpeed ="";
  String clickedDeviceDate = "";
  String clickedDeviceTime = "";
  String clickedDeviceFuelLevel = "";
  String clickedDeviceMileage = "";

  Marker clickedMarker =CarMarkerLive(car: Car(name: "", speed: "0", dateTime: "2024-10-16", acc: "", driver: "", lat: 0, long: 0,course: -1,fuelLevel: 0,mileage: 0), clickedTreeNode: TreeNode(title: ""));
  TreeNode clickedTreeNode = TreeNode(title: "");

  @override
  void initState() {
    super.initState();
    if(searchedValueController.text.isEmpty){
      context.read<HomeBloc>().add(Update(selectedTreeNode,true,clickedTreeNode),);
    }else{
      context.read<HomeBloc>().add(Update(selectedTreeNode,false,clickedTreeNode),);
    }
  }

  @override
  void dispose() {
    super.dispose();
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
          appBar: const AppBarDideban(),
          body: homeBody(context),
          drawer: drawer(context),
      ),
    );
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
                //enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                ),
                controller: searchedValueController,
                onChanged: (value) {
                  rebuildDrawer =true;
                  context.read<HomeBloc>().add(SearchDrawerDevices(originalTreeNode, value),);
                  if(value.isEmpty){
                    selectedTreeNode=originalTreeNode;
                  }
                },
              ),
            ),
          ),
          BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (previous, current) {
                return rebuildDrawer;
              },
              builder: (context, state) {
            if(state is DrawerIsLoading) {

              EasyLoading.dismiss();
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
            if(state is DrawerLoadSuccess){
              originalTreeNode =state.treeNode;
            }
            if(state is DrawerLoadFailed){
              return Center(
                child: Text("Some Error Occured in loading Devices list"),
              );
            }
            if(state is SearchDrawerDevicesSuccess){
              searchedTreeNode =state.treeNode;
              selectedTreeNode =searchedTreeNode;
            }
            if(state is SearchDrawerDevicesFailed){
              return Center(
                child: Text("Some Error occured in searching Devices list"),
              );
            }



            return Column(children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: TreeView(
                  onTap:(val){
                    clickedTreeNode = val;
                    LatLng newCenter =const LatLng(33.81275, 51.52094);
                    double newZoom =5.0;
                    for(int i=0;i<markers!.length;i++){
                      Marker marker = markers![i];
                      if(marker is CarMarkerLive){
                        if(val.title == marker.car.name){
                          newCenter = LatLng(marker.point.latitude, marker.point.longitude); // New center (e.g., Paris)
                          newZoom = 12.0;
                          _mapController.move(newCenter, newZoom);
                          clickedDeviceName = marker.car.name;
                          clickedDeviceSpeed = "  سرعت:  ${marker.car.speed}";
                          //String dateTime = marker.car.dateTime;
                          var dtArray = marker.car.dateTime.split(" ");
                          clickedDeviceDate = "تاریخ: ${dtArray[1]}";
                          clickedDeviceTime ="ساعت: ${dtArray[0]}";
                          clickedDeviceFuelLevel = "  سوخت:  ${marker.car.fuelLevel}";
                          clickedDeviceMileage = "  کیلومتر:  ${marker.car.mileage}";
                          break;
                        }
                      }
                    }
                  },
                  onChanged: (newNodes) {
                    selectedTreeNode = newNodes;
                  },
                  nodes: (searchedValueController.text.isEmpty)? originalTreeNode:searchedTreeNode,

                ),
              ),
            ]);

          }),
        ],
      ),
    );
  }







  Duration? dateTimeDiffFromNow(Marker newAlarm){
    Duration? diff = null;
    try{
      if(newAlarm is CarMarkerLive){
        var splittedDateTime = newAlarm.car.dateTime.split(" ");
        String jalaliDate = splittedDateTime[1];
        String time = splittedDateTime[0];
        DateTime? georgianDateTime = Util.jalaliToGeorgianDateTime(jalaliDate,time);
        if(georgianDateTime == null){
          return null;
        }
        DateTime dateTimeNow =DateTime.now();
        diff = dateTimeNow.difference(georgianDateTime);
      }
      return diff;
    }catch(e){
      return diff;
    }
  }

  Widget homeBody(BuildContext context){
    return Stack(
      children: [
        BlocBuilder<HomeBloc,HomeState>(
            builder: (context, state){
              if(state is DrawerLoadSuccess){
                originalTreeNode =state.treeNode;
                selectedTreeNode = state.treeNode;
              }
              if(state is UpdateSuccess){
                EasyLoading.dismiss();
                markers = state.markers;
                if(state.markers != null){
                  for(int i=0;i<state.markers!.length;i++){
                    Marker newMarker = markers![i];
                    if(newMarker is CarMarkerLive) {
                      if(newMarker.car.name == clickedDeviceName){
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          clickedDeviceSpeed =" سرعت: ${newMarker.car.speed}";

                          var dtArray = newMarker.car.dateTime.split(" ");
                          clickedDeviceDate = "تاریخ: ${dtArray[1]}";
                          clickedDeviceTime ="ساعت: ${dtArray[0]}";
                          clickedDeviceFuelLevel = "  سوخت:  ${newMarker.car.fuelLevel}";
                          clickedDeviceMileage = "  کیلومتر:  ${newMarker.car.mileage}";
                        });
                      }

                    }
                  }
                }
              }

              if(searchedValueController.text.isEmpty){
                context.read<HomeBloc>().add(Update(selectedTreeNode,true,clickedTreeNode),);
              }else{
                context.read<HomeBloc>().add(Update(selectedTreeNode,false,clickedTreeNode),);
              }

              return FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: const LatLng(33.81275, 51.52094),
                  initialZoom: 5.0,
                  interactionOptions: const InteractionOptions(
                    flags: InteractiveFlag.all,
                  ),
                  onTap: (_, __) {
                    clickedDeviceDate ="";
                    clickedDeviceTime ="";
                    clickedDeviceSpeed = "";
                    clickedDeviceName = "";
                    clickedDeviceFuelLevel ="";
                    clickedDeviceMileage = "";

                    //_popupLayerController.hideAllPopups();
                  }
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate: "${Config.mapAddress}",
                    //urlTemplate: "assets/tiles/{z}/{x}/{y}.png",
                    tileProvider: CancellableNetworkTileProvider(),
                  ),

                  /*MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      onMarkerTap: (value){
                        if(value is CarMarkerLive){
                          deviceNameController.text = value.car.name;
                          deviceSpeedController.text = "  سرعت: ${value.car.speed}" ;
                          deviceDateTimeController.text =value.car.dateTime;
                        }
                        clickedMarker=value;
                      },
                      maxClusterRadius: 0,
                      size: const Size(30, 30),
                      alignment: Alignment.center,
                      //padding: const EdgeInsets.all(50),
                      maxZoom: 10,
                      markers: markers!,
                      builder: (context, markers) {
                        return Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.blue),
                          child: Center(
                            child: Text(
                              markers.length.toString(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),*/

                  PopupMarkerLayer(
                    options: PopupMarkerLayerOptions(
                      markers: markers ?? [],
                      //popupController: _popupLayerController,
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (_, Marker marker) {


                          WidgetsBinding.instance
                              .addPostFrameCallback((_)  {

                            if(marker is CarMarkerLive){
                              if(clickedDeviceName != marker.car.name){
                                var dtArray = marker.car.dateTime.split(" ");
                                clickedDeviceDate = "تاریخ: ${dtArray[1]}";
                                clickedDeviceTime ="ساعت: ${dtArray[0]}";
                                clickedDeviceSpeed = "  سرعت: ${marker.car.speed}" ;
                                clickedDeviceFuelLevel ="  سوخت: ${marker.car.fuelLevel}" ;
                                clickedDeviceMileage ="  کیلومتر: ${marker.car.mileage}" ;
                                clickedDeviceName = marker.car.name;
                              }

                            }
                            clickedMarker=marker;


                          });

                          return Container();


                        },
                      ),

                    ),
                  )
                ],
              );

            }),

        Positioned(
          left: 0,
          bottom: 0,
          right: 0,
          child: BottomAppBar(
            color: Colors.white,
            child:Directionality(
              textDirection: TextDirection.rtl,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(clickedDeviceName
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(clickedDeviceDate
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(clickedDeviceTime
                            ),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(clickedDeviceSpeed
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(clickedDeviceFuelLevel
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: AutoSizeText(clickedDeviceMileage
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),



      ],
    );
  }

}
