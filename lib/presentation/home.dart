import 'package:dideban/blocs/home/home_bloc.dart';
import '../../utilities/util.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:latlong2/latlong.dart';
import 'package:dideban/presentation/widgets/car_position.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});
  static late Timer timer;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  double _bottomBarHeight = 120.0;
  List<TreeNode> originalTreeNode = [];
  List<TreeNode> treeNodeForUpdate = [];


  List<Marker> _alarmItems =[];
  TextEditingController searchedValueController = TextEditingController();
  List<Marker>? markers = [];
   PopupController _popupLayerController = PopupController();
  final MapController _mapController = MapController();
  bool rebuildDrawer=true;

  void update(){
    Home.timer = Timer.periodic(Duration(seconds: 60), (Timer timer) {
      rebuildDrawer =false;
      if(searchedValueController.text.isEmpty){
        //EasyLoading.show(status: "updating");
        context.read<HomeBloc>().add(Update(treeNodeForUpdate,true),);
      }else{
        //EasyLoading.show(status: "Please Wait");
        context.read<HomeBloc>().add(Update(treeNodeForUpdate,false),);
      }
    });

  }

  @override
  void initState() {
    super.initState();
    update();
  }

  @override
  void dispose() {
    super.dispose();
    _popupLayerController.dispose();
    _mapController.dispose();
    searchedValueController.dispose();
    Home.timer.cancel();

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
                enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                ),
                controller: searchedValueController,
                onChanged: (value) {
                  rebuildDrawer =true;

                  context.read<HomeBloc>().add(SearchDrawerDevices(originalTreeNode, value),);


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

              treeNodeForUpdate =state.treeNode;
              originalTreeNode =state.treeNode;
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      _popupLayerController.hideAllPopups();

                      rebuildDrawer =false;
                      if(searchedValueController.text.isEmpty){
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,true),);
                      }else{
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,false),);
                      }
                    },
                    nodes: state.treeNode,
                  ),
                ),
              ]);
            }
            if(state is DrawerLoadFailed){
              return Center(
                child: Text("Some Error Occured in loading Devices list"),
              );
            }
            if(state is SearchDrawerDevicesSuccess){
              treeNodeForUpdate =state.treeNode;
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(

                    onChanged: (newNodes) {
                      rebuildDrawer =false;
                      _popupLayerController.hideAllPopups();

                      if(searchedValueController.text.isEmpty){
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,true),);
                      }else{
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,false),);
                      }
                    },
                    nodes: state.treeNode,
                  ),
                ),
              ]);
            }
            if(state is SearchDrawerDevicesFailed){
              return Center(
                child: Text("Some Error occured in searching Devices list"),
              );
            }
            if(state is GetLocationOfSelectedDevicesSuccess){
              treeNodeForUpdate =state.treeNode;
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      _popupLayerController.hideAllPopups();

                      rebuildDrawer =false;
                      if(searchedValueController.text.isEmpty){
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,true),);
                      }else{
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,false),);
                      }
                    },
                    nodes: state.treeNode,
                  ),
                ),
              ]);
            }
            if(state is UpdateSuccess){
              treeNodeForUpdate =state.treeNode;
              return Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      _popupLayerController.hideAllPopups();

                      rebuildDrawer =false;
                      if(searchedValueController.text.isEmpty){
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,true),);
                      }else{
                        EasyLoading.show(status: "Please Wait");
                        context.read<HomeBloc>().add(GetLocationOfSelectedDevices(newNodes,false),);
                      }
                    },
                    nodes: state.treeNode,
                  ),
                ),
              ]);
            }

            return Container();

          }),
        ],
      ),
    );
  }

  bool checkAlarmExistence(Marker newAlarm){
    bool alarmAlreadyExist = false;
    try{
      for(int j=_alarmItems.length-1;j>=0;j--){ //check alarm exist
        Marker oldAlarm = _alarmItems[j];
        if(oldAlarm is CarMarker && newAlarm is CarMarker){
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
      if(newAlarm is CarMarker){
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
              if(state is GetLocationOfSelectedDevicesSuccess){
                EasyLoading.dismiss();
                markers = state.markers;

                LatLng newCenter =const LatLng(33.81275, 51.52094);
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
                }

              }
              if(state is UpdateSuccess){
                EasyLoading.dismiss();
                markers = state.markers;
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
                    _popupLayerController.hideAllPopups();

                  }
                ),
                children: <Widget>[
                  TileLayer(
                    urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                    //urlTemplate: 'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
                    tileProvider: CancellableNetworkTileProvider(),
                  ),

                  PopupMarkerLayer(
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
                  )
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
                    Expanded(
                      child: Card(
                        borderOnForeground: true,
                        child: BlocBuilder<HomeBloc, HomeState>(
                          builder: (context, state) {
                            if(state is GetLocationOfSelectedDevicesSuccess){
                              if(state.markers != null){
                                for(int i=0;i<state.markers!.length;i++){
                                  Marker newMarker = markers![i];
                                  if(newMarker is CarMarker) {
                                    Duration? diff=dateTimeDiffFromNow(newMarker);
                                    if(diff == null){
                                      continue;
                                    }
                                    if(diff>Duration(hours: 24)){
                                      bool alarmAlreadyExist = checkAlarmExistence(newMarker);
                                      if(!alarmAlreadyExist){
                                        _alarmItems.add(state.markers![i]);
                                      }
                                      continue;
                                    }
                                    if(diff>Duration(minutes: 10)){
                                      continue;
                                    }
                                    int speed = int.parse(newMarker.car.speed);
                                    if (speed > 100) {
                                      bool alarmAlreadyExist = checkAlarmExistence(newMarker);
                                      if(!alarmAlreadyExist){
                                        _alarmItems.add(state.markers![i]);
                                      }
                                      continue;
                                    }
                                  }
                                }
                              }
                            }
                            return ListView.builder(
                              itemCount: _alarmItems.length,
                              itemBuilder: (context, index) {
                                Marker marker = _alarmItems[index];
                                String alarmText="";
                                if(marker is CarMarker){
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
                                      /*LatLng newCenter =LatLng(_alarmItems[index].point.latitude, _alarmItems[index].point.longitude);
                                      double newZoom =12.0; // New zoom level
                                      _mapController.move(newCenter, newZoom);*/
                                    },
                                  ),
                                );
                              },
                            );
                          },
                        ),
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


}
