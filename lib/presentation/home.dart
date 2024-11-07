import 'package:dideban/blocs/home/home_bloc.dart';
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

  double _bottomBarHeight = 160.0;
  List<TreeNode> originalTreeNode = [];
  List<TreeNode> searchedTreeNode = [];
  List<TreeNode> selectedTreeNode = [];


  final ScrollController speedAlarmListController = ScrollController();
  final ScrollController idleAlarmListController = ScrollController();
  bool autoUpdateSelect=true;

  List<Marker> _speedAlarmItems =[];
  List<Marker> _idleAlarmItems =[];
  TextEditingController searchedValueController = TextEditingController();
  List<Marker>? markers = [];
  final MapController _mapController = MapController();
  bool rebuildDrawer=true;

  TextEditingController deviceNameController = TextEditingController();
  TextEditingController deviceDateTimeController = TextEditingController();
  TextEditingController deviceSpeedController = TextEditingController();

  Marker clickedMarker =CarMarkerLive(car: Car(name: "", speed: "0", dateTime: "2024-10-16", acc: "", driver: "", lat: 0, long: 0,course: -1,), clickedTreeNode: TreeNode(title: ""));
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
                          deviceNameController.text=marker.car.name;
                          deviceDateTimeController.text=marker.car.dateTime;
                          deviceSpeedController.text ="  سرعت:  ${marker.car.speed}";
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

  bool checkSpeedAlarmExistence(Marker newAlarm){

    bool alarmAlreadyExist = false;
    try{
      for(int j=_speedAlarmItems.length-1;j>=0;j--){ //check alarm exist
        Marker oldAlarm = _speedAlarmItems[j];
        if(oldAlarm is CarMarkerLive && newAlarm is CarMarkerLive){
          if(oldAlarm.car.dateTime == newAlarm.car.dateTime){
            if(newAlarm.car.name == oldAlarm.car.name){
              alarmAlreadyExist =true;
              break;
            }
          }
        }
      }
      return alarmAlreadyExist;
    }
    catch(e){
      return true;
    }
  }

  bool checkIdleAlarmExistence(Marker newAlarm){
    bool alarmAlreadyExist = false;
    try{
      for(int j=_idleAlarmItems.length-1;j>=0;j--){ //check alarm exist
        Marker oldAlarm = _idleAlarmItems[j];
        if(oldAlarm is CarMarkerLive && newAlarm is CarMarkerLive){
          if(oldAlarm.car.dateTime == newAlarm.car.dateTime){
            if(newAlarm.car.name == oldAlarm.car.name){
              alarmAlreadyExist =true;
              break;
            }
          }
        }
      }
      return alarmAlreadyExist;
    }
    catch(e){
      return true;
    }
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



                /*LatLng newCenter =const LatLng(33.81275, 51.52094);
                double newZoom =5.0;
                _popupLayerController.hideAllPopups();
                if(markers != null){
                  if(markers!.length==1){
                    newCenter = LatLng(markers![0].point.latitude, markers![0].point.longitude); // New center (e.g., Paris)
                    newZoom = 12.0; // New zoom level
                    //_mapController.move(newCenter, newZoom);
                  }
                  _mapController.move(newCenter, newZoom);
                  if(markers!.isEmpty){
                    EasyLoading.showError("No data available");
                  }
                }*/
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
                    deviceNameController.text="";
                    deviceDateTimeController.text="";
                    deviceSpeedController.text ="";
                    //_popupLayerController.hideAllPopups();
                  }
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    //urlTemplate: "assets/tiles/{z}/{x}/{y}.png",
                    tileProvider: CancellableNetworkTileProvider(),
                  ),

                  MarkerClusterLayerWidget(
                    options: MarkerClusterLayerOptions(
                      onMarkerTap: (value){
                        if(value is CarMarkerLive){
                          deviceNameController.text = value.car.name;
                          deviceSpeedController.text = "  سرعت: ${value.car.speed}" ;
                          deviceDateTimeController.text =value.car.dateTime;
                        }
                        clickedMarker=value;
                      },
                      maxClusterRadius: 30,
                      size: const Size(30, 30),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(50),
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
                  ),

                  /*PopupMarkerLayer(
                    options: PopupMarkerLayerOptions(
                      markers: markers ?? [],
                      popupController: _popupLayerController,
                      popupDisplayOptions: PopupDisplayOptions(
                        builder: (_, Marker marker) {

                          if(marker is CarMarker) {
                            return CarMarkerPopup(car: marker.car);
                          }
                          return const Card(child: Text('No data available'));
                        },
                      ),

                    ),
                  )*/
                ],
              );
            }),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              setState(() {
                _bottomBarHeight -= details.delta.dy;
                if (_bottomBarHeight < 100) _bottomBarHeight = 100; // Minimum height
                if (_bottomBarHeight > 300) _bottomBarHeight = 300; // Maximum height
              });
            },
            child: Container(
              height: _bottomBarHeight,
              color: Colors.blue,
              child: BottomAppBar(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Flexible(
                            flex: 2,
                            child: TextField(
                              readOnly: true,
                              controller: deviceNameController,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: TextField(
                              readOnly: true,
                              controller: deviceSpeedController,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Flexible(
                            flex: 2,
                            child: TextField(
                              readOnly: true,
                              controller: deviceDateTimeController,
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: 3,
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          ChoiceChip(
                            label: Text("Auto scroll"),
                            selected: autoUpdateSelect,
                            onSelected: (value){
                              setState(() {
                                if(value){
                                  autoUpdateSelect = true;
                                }else{
                                  autoUpdateSelect =false;
                                }
                              });
                            },
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          ChoiceChip(
                            label: Text("Clear"),
                            selected: false,
                            onSelected: (value){
                              originalTreeNode[0].children[0].children[0].isSelected =true;
                              _speedAlarmItems.clear();
                            },
                          ),
                        ],

                      ),
                    ),
                    SizedBox(
                      height: 3,
                    ),
                    Expanded(
                      child: BlocBuilder<HomeBloc, HomeState>(
                        builder: (context, state) {
                          if(state is UpdateSuccess){
                            if(state.markers != null){
                              for(int i=0;i<state.markers!.length;i++){
                                Marker newMarker = markers![i];
                                if(newMarker is CarMarkerLive) {
                                  if(newMarker.car.name == deviceNameController.text){
                                    WidgetsBinding.instance.addPostFrameCallback((_) {
                                      //deviceNameController.text = newMarker.car.name;
                                      deviceSpeedController.text = " سرعت: ${newMarker.car.speed}";
                                      deviceDateTimeController.text = newMarker.car.dateTime;
                                    });
                                  }
                                  Duration? diff=dateTimeDiffFromNow(newMarker);
                                  if(diff == null){
                                    continue;
                                  }
                                  if(diff>Duration(hours: 24)){
                                    bool alarmAlreadyExist = checkIdleAlarmExistence(newMarker);
                                    if(!alarmAlreadyExist){
                                      _idleAlarmItems.add(state.markers![i]);
                                    }
                                    continue;
                                  }
                                  if(diff>Duration(minutes: 10)){
                                    continue;
                                  }
                                  int speed = int.parse(newMarker.car.speed);
                                  if (speed > 100) {
                                    bool alarmAlreadyExist = checkSpeedAlarmExistence(newMarker);
                                    if(!alarmAlreadyExist){
                                      _speedAlarmItems.add(state.markers![i]);
                                    }
                                    continue;
                                  }
                                }
                              }


                              if(autoUpdateSelect){
                                speedAlarmListController.animateTo(
                                  speedAlarmListController.position.maxScrollExtent,
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                                idleAlarmListController.animateTo(
                                  idleAlarmListController.position.maxScrollExtent,
                                  duration: Duration(seconds: 1),
                                  curve: Curves.easeOut,
                                );
                              }




                            }
                          }

                          if(searchedValueController.text.isEmpty){
                            context.read<HomeBloc>().add(Update(selectedTreeNode,true,clickedTreeNode),);
                          }else{
                            context.read<HomeBloc>().add(Update(selectedTreeNode,false,clickedTreeNode),);
                          }



                          return Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Flexible(
                                flex:2,
                                child: Card(
                                  child: ListView.builder(
                                    controller: speedAlarmListController,
                                    itemCount: _idleAlarmItems.length,
                                    itemBuilder: (context, index) {
                                      Marker marker = _idleAlarmItems[index];
                                      String alarmText="";
                                      if(marker is CarMarkerLive){
                                        Duration? diff =  dateTimeDiffFromNow(marker);
                                        if(diff! > Duration(hours: 24)){
                                          alarmText = "هشدار عدم ارسال اطلاعات : ${marker.car.name} آخرین ارسال اطلاعات: ${marker.car.dateTime}";
                                        }else if(int.parse(marker.car.speed) > 100){
                                          alarmText = "هشدار سرعت غیر مجاز : ${marker.car.name}  ${marker.car.speed} ${marker.car.dateTime}";
                                        }
                                      }
                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ListTile(
                                          title:Text(alarmText),
                                          onTap: (){
                                            _showAlarm(_idleAlarmItems[index]);

                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Flexible(
                                flex:2,
                                child: Card(
                                  child: ListView.builder(
                                    controller: idleAlarmListController,
                                    itemCount: _speedAlarmItems.length,
                                    itemBuilder: (context, index) {
                                      Marker marker = _speedAlarmItems[index];
                                      String alarmText="";
                                      if(marker is CarMarkerLive){
                                        Duration? diff =  dateTimeDiffFromNow(marker);
                                        if(diff! > Duration(hours: 24)){
                                          alarmText = "هشدار عدم ارسال اطلاعات : ${marker.car.name} آخرین ارسال اطلاعات: ${marker.car.dateTime}";
                                        }else if(int.parse(marker.car.speed) > 100){
                                          alarmText = "هشدار سرعت غیر مجاز : ${marker.car.name}  ${marker.car.speed} ${marker.car.dateTime}";
                                        }
                                      }
                                      return Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: ListTile(
                                          title:Text(alarmText),
                                          onTap: (){
                                            _showAlarm(_speedAlarmItems[index]);
                                            /*LatLng newCenter =LatLng(_alarmItems[index].point.latitude, _alarmItems[index].point.longitude);
                                          double newZoom =12.0; // New zoom level
                                          _mapController.move(newCenter, newZoom);*/
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],

                          );
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showAlarm(Marker alarmMarker)  {
    List<Marker> alarmMarkers = [alarmMarker];
    TextEditingController alarmDetailsController =TextEditingController();
    try{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            double initialZoom =  5.0;
            late LatLng initialCenter;
            if(alarmMarker is CarMarkerLive){
              initialCenter=  LatLng(alarmMarker.point.latitude, alarmMarker.point.longitude);

              alarmDetailsController.text = alarmMarker.car.name + "     سرعت:" + alarmMarker.car.speed + "    " + alarmMarker.car.dateTime;
            }
            return AlertDialog(
              title: const Text("Alarm details"),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.5,
                child: FlutterMap(
                    options: MapOptions(
                        initialCenter:initialCenter,
                        initialZoom: initialZoom,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                        onTap: (_, __) {

                        }
                    ),
                    children: <Widget>[
                      TileLayer(
                        urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        //urlTemplate: "assets/tiles/{z}/{x}/{y}.png",
                        tileProvider: CancellableNetworkTileProvider(),
                      ),
                      MarkerLayer(markers: alarmMarkers),
                    ]
                ),
              ),
              actions: [
                Directionality(
                  textDirection: TextDirection.rtl,
                  child: TextField(
                    controller: alarmDetailsController,
                    readOnly: true,
                  ),
                )
              ],
            );

          }
      );
    }catch(e){
      var t=0;
    }


  }
}
