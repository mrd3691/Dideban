import 'dart:convert';
//import 'dart:html' as html;
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:flutter/foundation.dart'; // For kIsWeb
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dideban/presentation/widgets/treeview_checkbox.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../blocs/last_status_report/last_status_report_bloc.dart';
import '../config.dart';
import '../models/last_status_report.dart';
import '../utilities/util.dart';
import 'package:latlong2/latlong.dart';
import 'dart:html';

class LastStatusReportUi extends StatefulWidget {
  const LastStatusReportUi({super.key});
  @override
  State<LastStatusReportUi> createState() => _LastStatusReportUiState();
}
class _LastStatusReportUiState extends State<LastStatusReportUi> {

  List<TreeNode> originalTreeNode = [];
  List<TreeNode> currentTreeNode = [];
  List<String> selectedDevices =[];
  bool rebuildDrawer=true;
  TextEditingController searchedValueController = TextEditingController();

  LastStatusReport originalLastStatusReport =LastStatusReport(isSuccess: false, message: "",  devices: []);

  @override
  void dispose() {
    super.dispose();
    searchedValueController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void downloadCSV() {
    List<List<dynamic>> data = [];

    for(int i=0; i<originalLastStatusReport.devices.length;i++){

      try{
        data.add([originalLastStatusReport.devices[i].deviceName.substring(0,6),originalLastStatusReport.devices[i].odometer]);
      }catch(e){

      }

    }

    // Convert to CSV format
    String csvData = const ListToCsvConverter().convert(data);

    // Convert string to bytes
    Uint8List bytes = Uint8List.fromList(utf8.encode(csvData));

    // Create Blob and Object URL
    final blob = Blob([bytes]);
    final url = Url.createObjectUrlFromBlob(blob);

    // Create Anchor Element
    final anchor = AnchorElement(href: url)
      ..setAttribute('download', 'last_status.csv')
      ..click();

    // Cleanup
    Url.revokeObjectUrl(url);
  }

  /*Future<List<int>> createExcelFile() async {
    final excel = Excel.createExcel();
    final sheetName = "Sheet1";
    var sheet = excel[sheetName];
    sheet.isRTL = true;

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('D1'), customValue: TextCellValue('${originalDetailSpeedReport.device}${originalDetailSpeedReport.driver}${originalDetailSpeedReport.group}'));
    sheet.cell(CellIndex.indexByString("A1")).cellStyle =CellStyle(bold: true,fontSize: 15,horizontalAlign: HorizontalAlign.Center);

    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue("تاریخ");
    sheet.cell(CellIndex.indexByString("A2")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
    sheet.cell(CellIndex.indexByString("B2")).value = TextCellValue("سرعت");
    sheet.cell(CellIndex.indexByString("B2")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
    sheet.cell(CellIndex.indexByString("C2")).value = TextCellValue("طول جغرافیایی");
    sheet.cell(CellIndex.indexByString("C2")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
    sheet.cell(CellIndex.indexByString("D2")).value = TextCellValue("عرض جغرافیایی");
    sheet.cell(CellIndex.indexByString("D2")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
    for(int i=0; i<originalDetailSpeedReport.overSpeedPoints.length;i++){
      sheet.cell(CellIndex.indexByString("A${i+3}")).value = TextCellValue(originalDetailSpeedReport.overSpeedPoints[i].fixTime);
      sheet.cell(CellIndex.indexByString("A${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("B${i+3}")).value = TextCellValue(originalDetailSpeedReport.overSpeedPoints[i].speed.toString());
      sheet.cell(CellIndex.indexByString("B${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("C${i+3}")).value = TextCellValue(originalDetailSpeedReport.overSpeedPoints[i].latitude);
      sheet.cell(CellIndex.indexByString("C${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("D${i+3}")).value = TextCellValue(originalDetailSpeedReport.overSpeedPoints[i].longitude);
      sheet.cell(CellIndex.indexByString("D${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
    }

    // Convert the entire Excel document to a List of bytes.
    final List<int>? fileBytes = excel.encode();

    if (fileBytes == null) {
      throw Exception("Failed to encode Excel file.");
    }
    return fileBytes;
  }

  void downloadExcelWeb(List<int> bytes, {String fileName = 'example.xlsx'}) {
    // Convert bytes to a blob
    final blob = html.Blob([bytes], 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
    // Generate a download link
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.document.createElement('a') as html.AnchorElement
      ..href = url
      ..style.display = 'none'
      ..download = fileName;
    html.document.body?.children.add(anchor);

    // Programmatically click the anchor to trigger download
    anchor.click();

    // Cleanup
    html.document.body?.children.remove(anchor);
    html.Url.revokeObjectUrl(url);
  }

  Future<void> createAndDownloadExcel() async {
    try {
      // 1. Generate the Excel bytes.
      final fileBytes = await createExcelFile();

      // 2. Check the platform.
      if (kIsWeb) {
        // Running in a Web environment.
        downloadExcelWeb(fileBytes, fileName: 'Detail_Speed_Report.xlsx');
      } else {
        // Likely running on mobile or desktop.
        if (Platform.isAndroid || Platform.isIOS) {
          // Save to mobile device storage
          /////await saveExcelFileMobile(fileBytes);
          // Optionally open it
          // final directory = await getApplicationDocumentsDirectory();
          // final filePath = '${directory.path}/example.xlsx';
          // await openExcelFile(filePath);
        } else {
          // For desktop, you can use a similar approach to mobile,
          // but with different directory logic (e.g., using path_provider for desktop).
        }
      }
    } catch (e) {
      print("Error: $e");
    }
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body: lastStatusReportBody(context),
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
                //enableInteractiveSelection: false,
                decoration: const InputDecoration(
                  suffixIcon: Icon(Icons.search),
                ),
                controller: searchedValueController,
                onChanged: (value) {
                  rebuildDrawer =true;

                  context.read<LastStatusReportBloc>().add(SearchDrawerDevicesLastStatusReport(originalTreeNode, value),);


                },
              ),
            ),
          ),
          BlocBuilder<LastStatusReportBloc, LastStatusReportState>(
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
                        onTap:(val){},
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
                        onTap:(val){},
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
                if(state is LastStatusReportSuccess){
                  //originalTreeNode =state.treeNode;
                  return Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TreeView(
                        onTap:(val){},
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
                if(state is SearchLastStatusReportSuccess){
                  //originalTreeNode =state.treeNode;
                  return Column(children: [
                    Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      child: TreeView(
                        onTap:(val){},
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

                return Container();

              }),
        ],
      ),
    );
  }




  Widget bottomBar(BuildContext context){
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            const Spacer(flex: 20,),
            Flexible(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: (){
                        //EasyLoading.show(status: 'Please wait');
                        context.read<LastStatusReportBloc>().add(FetchLastStatusReport(currentTreeNode),);
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                          fixedSize: Size(MediaQuery.of(context).size.width * 0.4,
                              MediaQuery.of(context).size.height * 0.06),
                          backgroundColor: Colors.deepPurple,
                          elevation: 5),
                      child: const Text("Search"),
                    ),
                    SizedBox(height: 5,)
                  ],
                )
            ),
            const Spacer(flex: 1,)
          ],
        ),
      ],
    );
  }

  Widget lastStatusReportBody(BuildContext context){
    return BlocBuilder<LastStatusReportBloc, LastStatusReportState>(
      builder: (context, state) {
        LastStatusReport lastStatusReport =LastStatusReport(isSuccess: false, message: "", devices: []);;
        if(state is LastStatusReportInProgress){
          return Center(
              child: CircularProgressIndicator()
          );
        }
        if(state is LastStatusReportFailure){
          return Center(
            child:  Text(state.message!),
          );
        }
        if(state is LastStatusReportSuccess){
          lastStatusReport = state.lastStatusReport;
          originalLastStatusReport = state.lastStatusReport;
        }
        if(state is SearchLastStatusReportSuccess){
          lastStatusReport = state.lastStatusReport;
        }
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
              child: Container(
                color: Colors.white12,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(flex: 1,
                        child: IconButton(
                            onPressed: (){

                              downloadCSV();
                              //createAndDownloadExcel();
                            },
                            icon: Icon(Icons.download)
                        )
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          inputFormatters: <TextInputFormatter>[
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder()
                          ),
                          onChanged: (value) {
                            if(searchedValueController.text.isEmpty){
                              context.read<LastStatusReportBloc>().add(SearchLastStatusReport(originalLastStatusReport, value,currentTreeNode),);
                            }else{
                              context.read<LastStatusReportBloc>().add(SearchLastStatusReport(lastStatusReport, value,currentTreeNode),);
                            }

                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.deepPurple,
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Row(
                  children: [
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("خودرو",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("شعبه",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("تاریخ آخرین ارسال",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("موقعیت",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),

                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                  separatorBuilder: (context, index) =>
                  const Divider(
                    color: Colors.black,
                  ),
                  itemCount: lastStatusReport.devices.length,
                  itemBuilder: (context, index) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(lastStatusReport.devices[index].deviceName))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(lastStatusReport.devices[index].groupName))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(lastStatusReport.devices[index].fixTime))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: IconButton(
                                    onPressed: (){
                                      _showLastPosition(
                                          double.parse(lastStatusReport.devices[index].latitude),
                                          double.parse(lastStatusReport.devices[index].longitude),
                                          lastStatusReport.devices[index].deviceName,
                                          lastStatusReport.devices[index].fixTime);
                                    },
                                    icon:Icon(Icons.location_on),
                                  )
                              )
                          ),

                        ],
                      ),
                    );
                  }

              ),
            ),
          ],

        );
      },
    );
  }

  void _showLastPosition(double lat, double long, String device, String dateTime)  {
    LatLng point =LatLng(lat, long);
    Marker marker = Marker(point: point, child: Icon(Icons.location_on,color: Colors.red,));
    List<Marker> alarmMarkers = [marker];
    TextEditingController alarmDetailsController =TextEditingController();
    try{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            double initialZoom =  5.0;
            late LatLng initialCenter;

            alarmDetailsController.text = device + "    " + dateTime;
            initialCenter=  LatLng(marker.point.latitude, marker.point.longitude);
            return AlertDialog(
              title: const Text("Speed position"),
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








