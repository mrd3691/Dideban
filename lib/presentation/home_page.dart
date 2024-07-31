import 'package:dideban/presentation/tracking.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
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
  final MapController _mapController = MapController();
  TextEditingController searchedValueController = TextEditingController();

  void easyLoadingInit(){
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance
        .addPostFrameCallback((_)=>easyLoadingInit());

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "Dideban",
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        builder: EasyLoading.init(),
        home: Scaffold(
          appBar: AppBar(
            title: Text("user:$username"),
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
                    ),
                  );





                },
              ),
              MenuAnchor(
                builder:
                    (BuildContext context, MenuController controller, Widget? child) {
                  return IconButton(
                    onPressed: () {
                      if (controller.isOpen) {
                        controller.close();
                      } else {
                        controller.open();
                      }
                    },
                    icon: const Icon(Icons.settings),
                    tooltip: 'Show menu',
                  );
                },
                menuChildren: List<MenuItemButton>.generate(3,
                      (int index) => MenuItemButton(
                    onPressed: () {
                      //  setState(() => selectedMenu = SampleItem.values[index]),
                    },

                    child: Text('Item ${index + 1}'),
                  ),
                ),
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
              return Center(
                child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.2,
                    ),
                    const CircularProgressIndicator(
                      color: Colors.red,
                    ),
                    const Text("Loading..."),
                  ],
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
            }
            if(state is SearchDevicesLoadSuccess){
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
                urlTemplate:
                'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
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
              urlTemplate:
              'https://{s}-tiles.locationiq.com/v3/streets/r/{z}/{x}/{y}.png?key=pk.ae156969fe4398a400434f77e91ce44a',
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
