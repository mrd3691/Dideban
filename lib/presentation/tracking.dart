import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:dideban/blocs/devices/devices_bloc.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:latlong2/latlong.dart';
import 'package:dideban/presentation/widgets/car_position.dart';
import '../blocs/tracking/tracking_bloc.dart';
import '../utilities/util.dart';
import 'login.dart';

class Tracking extends StatefulWidget {
  Tracking(this.username,this.id,{super.key});
  String username = "";
  String id = "";
  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  List<TreeNode> treeNode = [];
  List<Marker> markers = [];
  List<String> selectedDevices =[];
  double sliderValue=0;
  int i=0;
  final PopupController _popupLayerController = PopupController();
  TextEditingController searchedValueController = TextEditingController();

  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();



  void getInitDateTime(){
    DateTime dt = DateTime.now();
    String currentDateJalali = Util.georgianToJalali("${dt.year}-${dt.month}-${dt.day}");
    _endDateController.text = currentDateJalali;

    String yesterdayDateJalali = Util.georgianToJalali("${dt.year}-${dt.month}-${dt.day-1}");
    _startDateController.text = yesterdayDateJalali;
    String currentTimeJalali = "${dt.hour}:${dt.minute}";
    _startTimeController.text = currentTimeJalali;
    _endTimeController.text = currentTimeJalali;



  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance
        .addPostFrameCallback((_)=>getInitDateTime());

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Dideban",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text("user:${widget.username}  id:${widget.id}"),
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
                onPressed: () {},
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
          body: trackingBody(context),
          drawer: drawer(context),
          bottomNavigationBar: bottomBar(context),

        )
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
                  height: MediaQuery.of(context).size.height * 0.9,
                  child: TreeView(
                    onChanged: (newNodes) {
                      if(searchedValueController.text.isEmpty){
                        for (var element in newNodes) {
                          for (var element1 in element.children) {
                            if(element1.isSelected){
                              selectedDevices.add(element1.title);
                            }
                          }
                        }
                      }
                      else{
                        for (var element in newNodes) {
                          if(element.isSelected){
                            selectedDevices.add(element.title);
                          }
                        }
                      }
                    },
                    nodes: state.searchedTreeNode,
                  ),
                ),
              ]);
            }
            return Column(children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.9,
                child: TreeView(
                  onChanged: (newNodes) {
                    if(searchedValueController.text.isEmpty){
                      for (var element in newNodes) {
                        for (var element1 in element.children) {
                          if(element1.isSelected){
                            selectedDevices.add(element1.title);
                          }
                        }
                      }
                    }
                    else{
                      for (var element in newNodes) {
                        if(element.isSelected){
                          selectedDevices.add(element.title);
                        }
                      }
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

  Widget bottomBar(BuildContext context){
    return Row(
      children: [
        Flexible(
          flex: 20,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Spacer(),
                  Flexible(
                    flex: 14,
                    child: TextField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          prefixIcon: Icon(Icons.date_range),
                          labelText: "Start Date"
                      ),
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    flex: 9,
                    child: TextField(
                      controller: _startTimeController,
                      style: TextStyle(fontSize: 15, fontFamily: 'irs',),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.timer),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          labelText: "Start Time"
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Spacer(),
                  Flexible(
                    flex: 14,
                    child: TextField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          prefixIcon: Icon(Icons.date_range),
                          labelText: "End Date"
                      ),
                    ),
                  ),
                  Spacer(),
                  Flexible(
                    flex: 9,
                    child: TextField(
                      controller: _endTimeController,
                      decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                          prefixIcon: Icon(Icons.timer),
                          labelText: "End Time"
                      ),
                    ),
                  ),
                  Spacer()
                ],
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
              BlocBuilder<TrackingBloc, TrackingState>(
                builder: (context, state) {
                  if(state is TrackingSuccess){
                    sliderValue = 1;
                    return Slider(
                      value: sliderValue,
                      //min: 0,
                      max: state.markers.length as double,
                      divisions: state.markers.length,
                      label: sliderValue.toString(),
                      //label: (markers is CarMarker)? markers[0].car : "",
                      onChanged:(val){
                        context.read<TrackingBloc>().add(SliderChanged(markers, val),);
                      },
                    );
                  }else if(state is SliderNewState){
                    return Slider(
                      value: state.value,
                      //min: 0,
                      max: state.markers.length as double,
                      divisions: state.markers.length,
                      label: state.value.toString(),
                      //label: (markers is CarMarker)? markers[0].car : "",
                      onChanged:(val){
                        context.read<TrackingBloc>().add(SliderChanged(markers, val.roundToDouble()),);
                      },
                    );
                  }
                  return Container();
                },
              )
            ],
          ),
        ),
        Flexible(
            flex: 5,
            child: TextButton(
              onPressed: (){
                if(selectedDevices.isEmpty){
                  print("no device selected");
                }else if(selectedDevices.length > 1){
                  print("more than one device is selected");
                }else{
                  context.read<TrackingBloc>().add(FetchTrackingPoints(
                      selectedDevices[0],
                      _startDateController.text,
                      _startTimeController.text,
                      _endDateController.text,
                      _endTimeController.text
                  ),);
                }
              },
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.4,
                      MediaQuery.of(context).size.height * 0.075),
                  backgroundColor: Colors.deepPurple,
                  elevation: 5),
              child: const Text("Track"),)),
        const Spacer(flex: 1,)
      ],
    );
  }

  Widget trackingBody(BuildContext context){
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
        BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            if(state is TrackingSuccess){
              markers = state.markers;
              List<LatLng> position=[];
              markers.forEach((element) {
                position.add(LatLng(element.point.latitude, element.point.longitude));
              });

              return PolylineLayer(
                polylines: [
                  Polyline(
                      points: position,
                      color: Colors.blue,
                      //borderStrokeWidth: 30,
                      strokeWidth: 15
                  ),
                ],
              );
            }
            return PolylineLayer(
              polylines: [
                Polyline(
                  points: [],
                  color: Colors.blue,
                ),
              ],
            );
          },
        ),
        BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            List<Marker> currentMarker=[];
            if(state is SliderNewState){
              int index = state.value as int;
              if(index == markers.length){
                currentMarker.add(state.markers[index-1]);
              }else{
                currentMarker.add(state.markers[index]);
              }

              //markers = state.markers;
            }
            return PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: currentMarker,

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




