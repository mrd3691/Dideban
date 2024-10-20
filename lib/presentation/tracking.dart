import 'dart:async';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_map_marker_popup/flutter_map_marker_popup.dart';
import 'package:dideban/blocs/devices/devices_bloc.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:latlong2/latlong.dart';
import 'package:dideban/presentation/widgets/car_position.dart';
import 'package:shimmer/shimmer.dart';
import '../blocs/tracking/tracking_bloc.dart';
import '../utilities/util.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class Tracking extends StatefulWidget {
  const Tracking({super.key});


  @override
  State<Tracking> createState() => _TrackingState();
}

class _TrackingState extends State<Tracking> {
  List<TreeNode> originalTreeNode = [];
  List<TreeNode> currentTreeNode = [];
  List<Marker> markers = [];
  List<String> selectedDevices =[];
  double sliderValue=0;
  double currentSliderValue=0;
  int sliderLength=0;
  Timer? timerTracking;
  bool rebuildDrawer=true;

  final PopupController _popupLayerController = PopupController();
  final MapController _mapController = MapController();
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
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _popupLayerController.dispose();
    _mapController.dispose();
    searchedValueController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    if(timerTracking != null){
      timerTracking!.cancel();
    }


  }

  @override
  void initState() {
    super.initState();
    getInitDateTime();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body: trackingBody(context),
      drawer: drawer(context),
      bottomNavigationBar: bottomBar(context),
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

                  context.read<TrackingBloc>().add(SearchDrawerDevicesTracking(originalTreeNode, value),);


                },
              ),
            ),
          ),
          BlocBuilder<TrackingBloc, TrackingState>(
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
                  currentTreeNode =state.treeNode;
                  return Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TreeView(
                        onChanged: (newNodes) {
                          //_popupLayerController.hideAllPopups();
                          rebuildDrawer =false;


                          selectedDevices.clear();
                          if(searchedValueController.text.isEmpty){
                            for (var element in newNodes) {
                              for (var element1 in element.children) {
                                for(var element2 in element1.children){
                                  if(element2.isSelected){
                                    selectedDevices.add(element2.title);
                                  }
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
                  currentTreeNode =state.treeNode;
                  return Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TreeView(
                        onChanged: (newNodes) {
                          rebuildDrawer =false;
                          selectedDevices.clear();
                          if(searchedValueController.text.isEmpty){
                            for (var element in newNodes) {
                              for (var element1 in element.children) {
                                for(var element2 in element1.children){
                                  if(element2.isSelected){
                                    selectedDevices.add(element2.title);
                                  }
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
                if(state is TrackingSuccess){
                  originalTreeNode =state.treeNode;
                  return Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TreeView(
                        onChanged: (newNodes) {
                          //_popupLayerController.hideAllPopups();
                          rebuildDrawer =false;


                          selectedDevices.clear();
                          if(searchedValueController.text.isEmpty){
                            for (var element in newNodes) {
                              for (var element1 in element.children) {
                                for(var element2 in element1.children){
                                  if(element2.isSelected){
                                    selectedDevices.add(element2.title);
                                  }
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
                        nodes: state.treeNode,
                      ),
                    ),
                  ]);
                }
                if(state is SliderNewState){
                  originalTreeNode =state.treeNode;
                  return Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TreeView(
                        onChanged: (newNodes) {
                          //_popupLayerController.hideAllPopups();
                          rebuildDrawer =false;


                          selectedDevices.clear();
                          if(searchedValueController.text.isEmpty){
                            for (var element in newNodes) {
                              for (var element1 in element.children) {
                                for(var element2 in element1.children){
                                  if(element2.isSelected){
                                    selectedDevices.add(element2.title);
                                  }
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

  Widget bottomBar(BuildContext context){
    bool isPause = true;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
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
                      const Spacer(),
                      Flexible(
                        flex: 14,
                        child: TextField(
                          controller: _startDateController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              prefixIcon: Icon(Icons.date_range),
                              labelText: "Start Date"
                          ),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        flex: 9,
                        child: TextField(
                          controller: _startTimeController,
                          style: const TextStyle(fontSize: 15, fontFamily: 'irs',),
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.timer),
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              labelText: "Start Time"
                          ),
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const Spacer(),
                      Flexible( //End date field
                        flex: 14,
                        child: TextField(
                          controller: _endDateController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              prefixIcon: Icon(Icons.date_range),
                              labelText: "End Date"
                          ),
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        flex: 9,
                        child: TextField(
                          controller: _endTimeController,
                          decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                              prefixIcon: Icon(Icons.timer),
                              labelText: "End Time"
                          ),
                        ),
                      ),
                      const Spacer()
                    ],
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.02,),

                ],
              ),
            ),
            Flexible(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton(
                      onPressed: (){
                        if(timerTracking !=null){
                          timerTracking!.cancel();
                        }
                        _popupLayerController.hideAllPopups();
                        if(selectedDevices.isEmpty){
                          EasyLoading.showError("No device selected");
                        }else if(selectedDevices.length > 1){
                          EasyLoading.showError("More than one device is selected");
                        }else{
                          EasyLoading.show(status: 'Please wait');
                          context.read<TrackingBloc>().add(FetchTrackingPoints(
                              selectedDevices[0],
                              _startDateController.text,
                              _startTimeController.text,
                              _endDateController.text,
                              _endTimeController.text,
                            currentTreeNode
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
                      child: const Text("Track"),),

                  ],
                )),
            const Spacer(flex: 1,)
          ],
        ),
        BlocBuilder<TrackingBloc, TrackingState>(
          builder: (context, state) {
            if(state is TrackingSuccess){
              if(state.markers.isEmpty){
                return Container();
              }
              sliderValue = 1;
              currentSliderValue = 1;
              sliderLength =state.markers.length;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex:20,
                    child: Slider(
                      value: sliderValue,
                      max: state.markers.length.toDouble(),
                      divisions: state.markers.length,
                      label: "",
                      onChanged:(val){
                        currentSliderValue = val;
                        _popupLayerController.hideAllPopups();
                        context.read<TrackingBloc>().add(SliderChanged(markers, val,currentTreeNode),);
                      },
                    ),
                  ),
                  Flexible(
                    flex: 8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex:2,
                          child: IconButton(
                            onPressed: (){
                              if(currentSliderValue.roundToDouble()>0){
                                _popupLayerController.hideAllPopups();
                                context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()-1,currentTreeNode),);
                              }
                            },
                            icon: const Icon(Icons.skip_previous),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: IconButton(
                            onPressed: (){

                              isPause =false;
                              try{
                                if(timerTracking == null){
                                  timerTracking = Timer.periodic(const Duration(microseconds: 500),(Timer t){
                                    if(currentSliderValue.roundToDouble() < sliderLength-1){
                                      _popupLayerController.hideAllPopups();
                                      context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()+1,currentTreeNode),);
                                    }
                                  } );
                                }else{
                                  if(timerTracking!.isActive){
                                    timerTracking!.cancel();
                                  }else{
                                    timerTracking = Timer.periodic(const Duration(microseconds: 500),(Timer t){
                                      if(currentSliderValue.roundToDouble() < sliderLength-1){
                                        _popupLayerController.hideAllPopups();
                                        context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()+1,currentTreeNode),);
                                      }
                                    } );
                                  }
                                }
                              }catch(e){
                                //print(e);
                              }
                            },
                              icon: (timerTracking==null)?Icon(Icons.play_circle): (timerTracking!.isActive)? Icon(Icons.pause_circle): Icon(Icons.play_circle),
                            //icon: SizedBox(width: 40,height: 40, child: Image.asset("images/playpause.png")),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: IconButton(
                            onPressed: (){
                              if(currentSliderValue.roundToDouble()< sliderLength-1){
                                _popupLayerController.hideAllPopups();
                                context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()+1,currentTreeNode),);
                              }
                            },
                            icon: const Icon(Icons.skip_next),
                          ),
                        ),
                        Spacer()
                      ],
                    ),
                  )

                ],
              );
            }
            if(state is SliderNewState){
              Marker cm =  state.markers[state.value.toInt()];
              String dateTime="";
              String speed ="";

              String name = "";

              currentSliderValue = state.value;
              sliderLength =state.markers.length;
              if(cm is CarMarker){
                dateTime = cm.car.dateTime;
                speed = cm.car.speed;

                name = cm.car.name;
              }
              if(state.value >= markers.length){
              }
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    flex: 20,
                    child: Column(
                      children: [
                        Slider(
                          value: state.value,
                          max: (state.markers.length-1).toDouble(),
                          divisions: state.markers.length,
                          label: dateTime,

                          onChanged:(val){
                            currentSliderValue = val;
                            _popupLayerController.hideAllPopups();
                            context.read<TrackingBloc>().add(SliderChanged(markers, val.roundToDouble(),currentTreeNode),);
                          },
                        ),
                        Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text(name +"  "+dateTime+"  "+"سرعت: "+speed)),
                        SizedBox(width: 2,)
                      ],
                    ),
                  ),
                  Flexible(
                    flex:8,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Flexible(
                          flex:2,
                          child: IconButton(
                            onPressed: (){
                              if(currentSliderValue.roundToDouble()>0){
                                _popupLayerController.hideAllPopups();
                                context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()-1,currentTreeNode),);
                              }
                            },
                            icon: const Icon(Icons.skip_previous),
                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: StatefulBuilder(
                            builder: (BuildContext context, StateSetter setState){

                              return IconButton(
                                onPressed: (){

                                  try{
                                    if(timerTracking == null){
                                      timerTracking = Timer.periodic(const Duration(microseconds: 500),(Timer t){
                                        if(currentSliderValue.roundToDouble() < sliderLength-1){
                                          _popupLayerController.hideAllPopups();
                                          context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()+1,currentTreeNode),);
                                        }
                                      } );
                                    }else{
                                      if(timerTracking!.isActive){
                                        timerTracking!.cancel();
                                      }else{
                                        timerTracking = Timer.periodic(const Duration(microseconds: 500),(Timer t){
                                          if(currentSliderValue.roundToDouble() < sliderLength-1){
                                            _popupLayerController.hideAllPopups();
                                            context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()+1,currentTreeNode),);
                                          }
                                        } );
                                      }
                                    }
                                    setState((){
                                      if(isPause){
                                        isPause =false;
                                      }else{
                                        isPause = true;
                                      }

                                    });
                                  }catch(e){
                                    //print(e);
                                  }
                                },

                                icon: (isPause)?Icon(Icons.play_circle):Icon(Icons.pause_circle),
                                //icon: (timer==null)?Icon(Icons.play_circle): (timer!.isActive)? Icon(Icons.pause_circle): Icon(Icons.play_circle),
                                //icon: SizedBox(width: 40,height: 40, child: Image.asset("images/playpause.png")),

                              );
                            }

                          ),
                        ),
                        Flexible(
                          flex: 2,
                          child: IconButton(
                            onPressed: (){
                              if(currentSliderValue.roundToDouble()< sliderLength-1){
                                _popupLayerController.hideAllPopups();
                                context.read<TrackingBloc>().add(SliderChanged(markers, currentSliderValue.roundToDouble()+1,currentTreeNode),);
                              }
                            },
                            icon: const Icon(Icons.skip_next),
                          ),
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),


                ],
              );
            }
            return Container();
          },
        )
      ],
    );
  }

  Widget trackingBody(BuildContext context){
    return BlocBuilder<TrackingBloc, TrackingState>(
      builder: (context, state) {
        List<Marker> currentMarker=[];
        List<LatLng> position=[];
        double newZoom = 12.0;
        if(state is TrackingSuccess){
          EasyLoading.dismiss();
          markers = state.markers;
          if(markers.isEmpty){
            EasyLoading.showError("No data available",duration: const Duration(seconds: 3));
          }else{
            EasyLoading.showInfo("${markers.length} points found");
            markers.forEach((element) {
              position.add(LatLng(element.point.latitude, element.point.longitude));
            });

            LatLng newCenter = LatLng(position[0].latitude, position[0].longitude); // New center (e.g., Paris)
            double newZoom = 12.0; // New zoom level
            _mapController.move(newCenter, newZoom);

            currentMarker.add(state.markers[0]);
          }
        }
        if(state is TrackingFailure){
          EasyLoading.showError(state.message!);
        }
        if(state is SliderNewState){
          EasyLoading.dismiss();
          markers = state.markers;
          if(markers.isEmpty){
            EasyLoading.showError("No data available",duration: const Duration(seconds: 3));
          }else{
            markers.forEach((element) {
              position.add(LatLng(element.point.latitude, element.point.longitude));
            });

            int index = state.value.toInt();

            LatLng newCenter = LatLng(position[index].latitude, position[index].longitude); // New center (e.g., Paris)

            if(_mapController.camera.zoom != newZoom ){
              newZoom = _mapController.camera.zoom;
            }
            _mapController.move(newCenter, newZoom);

            if(index == markers.length){
              currentMarker.add(state.markers[index-1]);
            }else{
              currentMarker.add(state.markers[index]);
            }
          }

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
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                //urlTemplate: 'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
                tileProvider: CancellableNetworkTileProvider()
            ),
            PolylineLayer(
              polylines: [
                Polyline(
                    points: position,
                    color: Colors.blue,
                    strokeWidth: 5
                ),
              ],
            ),
            PopupMarkerLayer(
              options: PopupMarkerLayerOptions(
                markers: currentMarker,
                popupController: _popupLayerController,
                popupDisplayOptions: PopupDisplayOptions(
                  builder: (_, Marker marker) {
                    return Container();
                    /*if(marker is CarMarker) {
                      return CarMarkerPopup(car: marker.car);
                    }
                    return const Card(child: Text('No data available'));*/
                    //return  Card(child: marker.child);
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}






