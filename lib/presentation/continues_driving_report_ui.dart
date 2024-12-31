import 'dart:html' as html;
import 'dart:io';
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
import '../blocs/continues_driving_report/continues_driving_report_bloc.dart';
import '../config.dart';
import '../models/continues_driving_report.dart';
import '../utilities/util.dart';
import 'package:latlong2/latlong.dart';

class ContinuesDrivingReportUi extends StatefulWidget {
  const ContinuesDrivingReportUi({super.key});
  @override
  State<ContinuesDrivingReportUi> createState() => _ContinuesDrivingReportUiState();
}

class _ContinuesDrivingReportUiState extends State<ContinuesDrivingReportUi> {

  List<TreeNode> originalTreeNode = [];
  List<TreeNode> currentTreeNode = [];
  List<String> selectedDevices =[];
  bool rebuildDrawer=true;
  TextEditingController searchedValueController = TextEditingController();

  List<ContinuesDrivingReport> originalContinuesDrivingReport =[];

  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  final _stopTresholdController = TextEditingController();


  @override
  void dispose() {
    super.dispose();
    searchedValueController.dispose();
    _startDateController.dispose();
    _startTimeController.dispose();
    _endDateController.dispose();
    _endTimeController.dispose();
    _stopTresholdController.dispose();


  }

  void getInitDateTime(){
    DateTime dt = DateTime.now();
    String currentDateJalali = Util.georgianToJalali("${dt.year}-${dt.month}-${dt.day}");
    _endDateController.text = currentDateJalali;

    String yesterdayDateJalali = Util.georgianToJalali("${dt.year}-${dt.month}-${dt.day-1}");
    _startDateController.text = yesterdayDateJalali;
    String currentTimeJalali = "${dt.hour}:${dt.minute}";
    _startTimeController.text = currentTimeJalali;
    _endTimeController.text = currentTimeJalali;
    _stopTresholdController.text ="10";
  }
  @override
  void initState() {
    super.initState();
    getInitDateTime();
  }


  Future<List<int>> createExcelFile() async {
    final excel = Excel.createExcel();
    final sheetName = "Sheet1";
    var sheet = excel[sheetName];
    sheet.isRTL = true;

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('E1'), customValue: TextCellValue('گزارش زمان رانندگی مداوم'));
    sheet.cell(CellIndex.indexByString("A1")).cellStyle =CellStyle(bold: true,fontSize: 15,horizontalAlign: HorizontalAlign.Center);

    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue("خودرو");
    sheet.cell(CellIndex.indexByString("A2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("B2")).value = TextCellValue("شعبه");
    sheet.cell(CellIndex.indexByString("B2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("C2")).value = TextCellValue("تاریخ شروع سفر");
    sheet.cell(CellIndex.indexByString("C2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("D2")).value = TextCellValue("تاریخ پایان سفر");
    sheet.cell(CellIndex.indexByString("D2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("E2")).value = TextCellValue("زمان");
    sheet.cell(CellIndex.indexByString("E2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    for(int i=0; i<originalContinuesDrivingReport.length;i++){
      sheet.cell(CellIndex.indexByString("A${i+3}")).value = TextCellValue(originalContinuesDrivingReport[i].device);
      sheet.cell(CellIndex.indexByString("A${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("B${i+3}")).value = TextCellValue(originalContinuesDrivingReport[i].group);
      sheet.cell(CellIndex.indexByString("B${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("C${i+3}")).value = TextCellValue(originalContinuesDrivingReport[i].start_date_max_driving);
      sheet.cell(CellIndex.indexByString("C${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("D${i+3}")).value = TextCellValue(originalContinuesDrivingReport[i].end_date_max_driving);
      sheet.cell(CellIndex.indexByString("D${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("E${i+3}")).value = IntCellValue(((originalContinuesDrivingReport[i].max_driving_time)/60).round());
      sheet.cell(CellIndex.indexByString("E${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);

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
        downloadExcelWeb(fileBytes, fileName: 'Continues_Driving_Report.xlsx');
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
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body: ContinuesDrivingReportBody(context),
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

                  context.read<ContinuesDrivingReportBloc>().add(SearchDrawerDevicesContinuesDrivingReport(originalTreeNode, value),);


                },
              ),
            ),
          ),
          BlocBuilder<ContinuesDrivingReportBloc, ContinuesDrivingReportState>(
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
                if(state is ContinuesDrivingReportSuccess){
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
                if(state is SearchContinuesDrivingReportSuccess){
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
                          inputFormatters: [DateInputFormatter()],
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
                          inputFormatters: [TimeInputFormatter()],
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
                          inputFormatters: [DateInputFormatter()],
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
                          inputFormatters: [TimeInputFormatter()],
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      flex: 1,
                      child: TextField(
                        inputFormatters: <TextInputFormatter>[
                          FilteringTextInputFormatter.digitsOnly
                        ],
                        controller: _stopTresholdController,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                            prefixIcon: Icon(Icons.timelapse),
                            labelText: "stop treshold"
                        ),
                      ),
                    ),
                    SizedBox(height: 5,),
                    Flexible(
                      flex: 1,
                      child: TextButton(
                        onPressed: (){

                          if(selectedDevices.isEmpty){
                            EasyLoading.showError("No device selected");
                          }else{
                            //EasyLoading.show(status: 'Please wait');
                            context.read<ContinuesDrivingReportBloc>().add(FetchContinuesDrivingReport(
                                selectedDevices,
                                _startDateController.text,
                                _startTimeController.text,
                                _endDateController.text,
                                _endTimeController.text,
                                int.parse(_stopTresholdController.text),
                                currentTreeNode
                            ),);
                          }
                        },
                        style: TextButton.styleFrom(
                            foregroundColor: Colors.white, shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                            fixedSize: Size(MediaQuery.of(context).size.width * 0.4,
                                MediaQuery.of(context).size.height * 0.06),
                            backgroundColor: Colors.deepPurple,
                            elevation: 5),
                        child: const Text("Search"),),
                    ),

                  ],
                )
            ),
            const Spacer(flex: 1,)
          ],
        ),

      ],
    );
  }

  Widget ContinuesDrivingReportBody(BuildContext context){
    return BlocBuilder<ContinuesDrivingReportBloc, ContinuesDrivingReportState>(
      builder: (context, state) {
        List<ContinuesDrivingReport> continuesDrivingReport =[];
        if(state is ContinuesDrivingReportInProgress){
          return Center(
              child: CircularProgressIndicator()
          );
        }
        if(state is ContinuesDrivingReportFailure){
          return Center(
            child:  Text(state.message!),
          );
        }
        if(state is ContinuesDrivingReportSuccess){
          continuesDrivingReport = state.continuesDrivingReport;
          originalContinuesDrivingReport = state.continuesDrivingReport;
        }
        if(state is SearchContinuesDrivingReportSuccess){
          continuesDrivingReport = state.continuesDrivingReport;
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
                              createAndDownloadExcel();
                            },
                            icon: Icon(Icons.download)
                        )
                    ),
                    Expanded(
                      child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: TextField(
                          decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder()
                          ),
                          onChanged: (value) {
                            if(searchedValueController.text.isEmpty){
                              context.read<ContinuesDrivingReportBloc>().add(SearchContinuesDrivingReport(originalContinuesDrivingReport, value,currentTreeNode),);
                            }else{
                              context.read<ContinuesDrivingReportBloc>().add(SearchContinuesDrivingReport(continuesDrivingReport, value,currentTreeNode),);
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
                      flex:1,
                      child: const Center(child: Text("خودرو",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex:1,
                      child: const Center(child: Text("شعبه",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("تاریخ شروع سفر",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("تاریخ پایان سفر",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("زمان",
                        style: TextStyle(
                            color: Colors.white, fontSize: 15),)),
                    ),
                    Flexible(
                      flex: 1,
                      child: const Center(child: Text("مسیر",
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
                  itemCount: continuesDrivingReport.length,
                  itemBuilder: (context, index) {
                    return Directionality(
                      textDirection: TextDirection.rtl,
                      child: Row(
                        children: [
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(continuesDrivingReport[index].device))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(continuesDrivingReport[index].group))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(continuesDrivingReport[index].start_date_max_driving))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(continuesDrivingReport[index].end_date_max_driving))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: Text(((continuesDrivingReport[index].max_driving_time)/60).round().toString()))
                          ),
                          Flexible(
                              flex:1,
                              child: Center(
                                  child: IconButton(
                                    onPressed: (){
                                      _showRootContinuesDriving(
                                          double.parse(continuesDrivingReport[index].start_lat_max_driving),
                                          double.parse(continuesDrivingReport[index].start_long_max_driving),
                                          double.parse(continuesDrivingReport[index].end_lat_max_driving),
                                          double.parse(continuesDrivingReport[index].end_long_max_driving),
                                          continuesDrivingReport[index].device,
                                          ((continuesDrivingReport[index].max_driving_time)/60).round(),
                                          continuesDrivingReport[index].start_date_max_driving,
                                          continuesDrivingReport[index].end_date_max_driving
                                      );
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

  void _showRootContinuesDriving(double startLat, double startLong,double endLat, double endLong, String device, int time, String startTime, String endTime )  {
    LatLng startPoint =LatLng(startLat, startLong);
    LatLng endPoint =LatLng(endLat, endLong);
    Marker startMarker = Marker(point: startPoint, child: Icon(Icons.location_on,color: Colors.greenAccent,));
    Marker endMarker = Marker(point: endPoint, child: Icon(Icons.location_on,color: Colors.red,));
    List<Marker> alarmMarkers = [startMarker,endMarker];
    TextEditingController alarmDetailsController =TextEditingController();
    try{
      showDialog(
          context: context,
          builder: (BuildContext context) {
            double initialZoom =  5.0;
            late LatLng initialCenter;

            alarmDetailsController.text = device + "     زمان:" + time.toString() +"ساعت"+ "   "+ startTime+  "  ------->  " + endTime;
            initialCenter=  LatLng(startMarker.point.latitude, startMarker.point.longitude);
            return AlertDialog(
              title: const Text("Continues driving route"),
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
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: [
                              startPoint,
                              endPoint,
                            ],
                            strokeWidth: 4.0,
                            color: Colors.blue,
                          ),
                        ],
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

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 10) {
      return oldValue;
    }

    final newText = newValue.text.replaceAll(RegExp(r'[^0-9/]'), '');
    if (newText.length > 4 && newText[4] != '/') {
      return TextEditingValue(
        text: '${newText.substring(0, 4)}/${newText.substring(4)}',
        selection: TextSelection.collapsed(offset: newText.length + 1),
      );
    }
    if (newText.length > 7 && newText[7] != '/') {
      return TextEditingValue(
        text: '${newText.substring(0, 7)}/${newText.substring(7)}',
        selection: TextSelection.collapsed(offset: newText.length + 1),
      );
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 5) {
      return oldValue;
    }

    final newText = newValue.text.replaceAll(RegExp(r'[^0-9:]'), '');
    if (newText.length > 2 && newText[2] != ':') {
      return TextEditingValue(
        text: '${newText.substring(0, 2)}:${newText.substring(2)}',
        selection: TextSelection.collapsed(offset: newText.length + 1),
      );
    }

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}






