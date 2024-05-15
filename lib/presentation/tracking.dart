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
import '../utilities/util.dart';
import 'login.dart';


class Tracking extends StatelessWidget {
  Tracking(this.username,this.id ,{ super.key});
  String username = "";
  String id = "";
  List<TreeNode> treeNode = [];
  List<Marker> markers = [];
  final PopupController _popupLayerController = PopupController();
  TextEditingController searchedValueController = TextEditingController();

  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();



  void getInitDateTime(){
    DateTime dt = DateTime.now();
    String currentDateJalali = Util.georgianToJalali("${dt.year}-${dt.month}-${dt.day}");
    _startDateController.text = currentDateJalali;

    String yesterdayDateJalali = Util.georgianToJalali("${dt.year}-${dt.month}-${dt.day-1}");
    _endDateController.text = yesterdayDateJalali;
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
            ],

          ),
        ),

        Flexible(
          flex: 5,
            child: TextButton(
              onPressed: (){}, child: Text("Track"),
              style: TextButton.styleFrom(
                  foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
                  fixedSize: Size(MediaQuery.of(context).size.width * 0.4,
                      MediaQuery.of(context).size.height * 0.075),
                  backgroundColor: Colors.deepPurple,
                  //textStyle: buttonTextStyle,
                  elevation: 5),)),
        Spacer(flex: 1,)
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
        PolylineLayer(
          polylines: [
            Polyline(
              points: [LatLng(30, 40), LatLng(20, 50), LatLng(25, 45)],
              color: Colors.blue,
            ),
          ],
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
