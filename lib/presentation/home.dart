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

  double _rightBarWidth = 250.0;
  List<TreeNode> originalTreeNode = [];
  List<TreeNode> searchedTreeNode = [];
  List<TreeNode> selectedTreeNode = [];


  final ScrollController speedAlarmListController = ScrollController();
  final ScrollController idleAlarmListController = ScrollController();
  bool autoScrollSelect=true;

  List<Marker> _speedAlarmItems =[];
  List<Marker> _idleAlarmItems =[];
  TextEditingController searchedValueController = TextEditingController();
  List<Marker>? markers = [];
  final MapController _mapController = MapController();
  bool rebuildDrawer=true;



  String clickedDeviceName="";
  String clickedDeviceSpeed ="";
  String clickedDeviceDate = "";
  String clickedDeviceTime = "";

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
                          clickedDeviceName = marker.car.name;
                          clickedDeviceSpeed = "  سرعت:  ${marker.car.speed}";
                          //String dateTime = marker.car.dateTime;
                          var dtArray = marker.car.dateTime.split(" ");
                          clickedDeviceDate = "تاریخ: ${dtArray[1]}";
                          clickedDeviceTime ="ساعت: ${dtArray[0]}";
                          break;
                        }
                      }
                    }
                  },
                  onChanged: (newNodes) {
                    selectedTreeNode = newNodes;
                    _speedAlarmItems.clear();
                    _idleAlarmItems.clear();
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
                    clickedDeviceDate ="";
                    clickedDeviceTime ="";
                    clickedDeviceSpeed = "";
                    clickedDeviceName = "";
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
          top: 0,
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onHorizontalDragUpdate: (details) {
              setState(() {
                _rightBarWidth -= details.delta.dx;
                if (_rightBarWidth < 200) _rightBarWidth = 200; // Minimum height
                if (_rightBarWidth > 700) _rightBarWidth = 700; // Maximum height
              });
            },
            child: Container(
              width: _rightBarWidth,
              color: Colors.white,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if(state is UpdateSuccess){
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
                          if (speed > 105) {
                            bool alarmAlreadyExist = checkSpeedAlarmExistence(newMarker);
                            if(!alarmAlreadyExist){
                              _speedAlarmItems.add(state.markers![i]);
                            }
                            continue;
                          }
                        }
                      }


                      if(autoScrollSelect){
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



                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Spacer(flex: 1,),
                      Flexible(
                        flex:2,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            children: [
                              SizedBox(width: 5,),
                              ChoiceChip(
                                label: Text("Auto scroll"),
                                selected: autoScrollSelect,
                                onSelected: (value){
                                  setState(() {
                                    if(value){
                                      autoScrollSelect = true;
                                    }else{
                                      autoScrollSelect =false;
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
                                  _speedAlarmItems.clear();
                                  _idleAlarmItems.clear();
                                },
                              ),
                            ],

                          ),
                        ),
                      ),
                      Spacer(flex: 1,),
                      Flexible(
                          flex:2,
                          child: Text("هشدار عدم ارسال اطلاعات")
                      ),

                      Flexible(
                        flex:20,
                        child: Card(
                          child: ListView.builder(
                            controller: idleAlarmListController,
                            itemCount: _idleAlarmItems.length,
                            itemBuilder: (context, index) {

                              Marker marker = _idleAlarmItems[index];
                              String alarmText="";
                              String idleAlarmName ="";
                              String idleAlarmDateTime ="";
                              if(marker is CarMarkerLive){
                                idleAlarmName = marker.car.name;
                                idleAlarmDateTime = marker.car.dateTime;
                                /*Duration? diff =  dateTimeDiffFromNow(marker);
                                if(diff! > Duration(hours: 24)){
                                  alarmText = " ${marker.car.name}  ${marker.car.dateTime}";
                                }else if(int.parse(marker.car.speed) > 100){
                                  alarmText = " ${marker.car.name}  ${marker.car.speed} ${marker.car.dateTime}";
                                }*/
                              }
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: Container(
                                  color: index % 2 == 0 ? Colors.white70 : Colors.white10,
                                  child: ListTile(

                                    title:Row(
                                        children: [
                                          Flexible(
                                              flex:3,
                                              child: Text(idleAlarmName)
                                          ),
                                          Spacer(),
                                          Flexible(flex:3,child: Text(idleAlarmDateTime))
                                        ],
                                    ),
                                    onTap: (){
                                      _showAlarm(_idleAlarmItems[index]);

                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Spacer(flex: 1,),
                      Flexible(
                        flex:2,
                          child: Text("هشدار سرعت")),
                      Flexible(
                        flex:20,
                        child: Card(
                          child: ListView.builder(
                            controller: speedAlarmListController,
                            itemCount: _speedAlarmItems.length,
                            itemBuilder: (context, index) {
                              Marker marker = _speedAlarmItems[index];
                              String alarmText="";
                              String speedAlarmName ="";
                              String speedAlarmSpeed ="";
                              String speedAlarmDateTime ="";
                              if(marker is CarMarkerLive){
                                /*Duration? diff =  dateTimeDiffFromNow(marker);
                                if(diff! > Duration(hours: 24)){
                                  alarmText = " ${marker.car.name}  ${marker.car.dateTime}";
                                }else*/
                                speedAlarmName = marker.car.name;
                                speedAlarmSpeed = marker.car.speed;
                                speedAlarmDateTime = marker.car.dateTime;
                              }
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: Container(
                                  color: index % 2 == 0 ? Colors.white70 : Colors.white10,
                                  child: ListTile(
                                    title:Row(
                                        children: [
                                          Flexible(
                                              flex:3,
                                              child: Text(speedAlarmName)
                                          ),
                                          Spacer(),
                                          Flexible(
                                            flex: 1,
                                              child: Text(
                                                  speedAlarmSpeed,
                                                  style: TextStyle(color: Colors.red),

                                              )
                                          ),
                                          Spacer(),
                                          Flexible(
                                              flex: 3,
                                              child: Text(speedAlarmDateTime)
                                          )
                                        ],
                                    ),
                                    onTap: (){
                                      _showAlarm(_speedAlarmItems[index]);
                                      /*LatLng newCenter =LatLng(_alarmItems[index].point.latitude, _alarmItems[index].point.longitude);
                                      double newZoom =12.0; // New zoom level
                                      _mapController.move(newCenter, newZoom);*/
                                    },
                                  ),
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
            ),
          ),
        ),
        Positioned(
          left: 0,
          bottom: 0,
          right: _rightBarWidth,
          child: BottomAppBar(
            //color: Colors.blue,
            child:Directionality(
              textDirection: TextDirection.rtl,
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Flexible(
                        flex: 2,
                        child: Text(clickedDeviceName
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(clickedDeviceSpeed
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(clickedDeviceDate
                        ),
                      ),
                      Flexible(
                        flex: 2,
                        child: Text(clickedDeviceTime
                        ),
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
                        urlTemplate: "${Config.mapAddress}",
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

    }


  }
}
