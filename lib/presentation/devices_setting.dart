import 'dart:io';

import 'package:dideban/blocs/devices_setting/devices_setting_bloc.dart';
import 'package:dideban/models/driver.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../data/device_setting_api.dart';
import '../models/device.dart';
import '../models/group.dart';
import 'dart:html' as html;

class DevicesSetting extends StatefulWidget {
  const DevicesSetting({ super.key});
  @override
  State<DevicesSetting> createState() => _DevicesSettingState();
}

class _DevicesSettingState extends State<DevicesSetting> {
  final _createDeviceNameController = TextEditingController();
  final _createUniqueIdController = TextEditingController();
  final _createPhoneController = TextEditingController();
  final _createModelController = TextEditingController();
  final _createContactController = TextEditingController();

  final _updateDeviceNameController = TextEditingController();
  final _updateUniqueIdController = TextEditingController();
  final _updatePhoneController = TextEditingController();
  final _updateModelController = TextEditingController();
  final _updateContactController = TextEditingController();



  //only use for search and initial when other state is success
  List<Device>? devices = [];
  List<Group>? groups = [];
  List<Driver>? drivers = [];


  @override
  void dispose() {
    _createDeviceNameController.dispose();
    _createUniqueIdController.dispose();
    _createPhoneController.dispose();
    _createModelController.dispose();
    _createContactController.dispose();
    super.dispose();
  }



  Future<List<int>> createExcelFile() async {
    final excel = Excel.createExcel();
    final sheetName = "Sheet1";
    var sheet = excel[sheetName];
    sheet.isRTL = true;

    sheet.merge(CellIndex.indexByString('A1'), CellIndex.indexByString('I1'), customValue: TextCellValue('Devices'));
    sheet.cell(CellIndex.indexByString("A1")).cellStyle =CellStyle(bold: true,fontSize: 15,horizontalAlign: HorizontalAlign.Center);

    sheet.cell(CellIndex.indexByString("A2")).value = TextCellValue("device");
    sheet.cell(CellIndex.indexByString("A2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("B2")).value = TextCellValue("IMEI");
    sheet.cell(CellIndex.indexByString("B2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("C2")).value = TextCellValue("phone");
    sheet.cell(CellIndex.indexByString("C2")).cellStyle =CellStyle(bold: true,fontSize: 10,);
    sheet.cell(CellIndex.indexByString("D2")).value = TextCellValue("model");
    sheet.cell(CellIndex.indexByString("D2")).cellStyle =CellStyle(bold: true,fontSize: 10,);

    for(int i=0; i<devices!.length;i++){
      sheet.cell(CellIndex.indexByString("A${i+3}")).value = TextCellValue(devices![i].name);
      sheet.cell(CellIndex.indexByString("A${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("B${i+3}")).value = TextCellValue(devices![i].uniqueId);
      sheet.cell(CellIndex.indexByString("B${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("C${i+3}")).value = TextCellValue(devices![i].phone!);
      sheet.cell(CellIndex.indexByString("C${i+3}")).cellStyle =CellStyle(bold: true,fontSize: 10,horizontalAlign: HorizontalAlign.Center);
      sheet.cell(CellIndex.indexByString("D${i+3}")).value = TextCellValue(devices![i].model!);
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
        downloadExcelWeb(fileBytes, fileName: 'devices.xlsx');
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
      body:homeBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
           _createDeviceNameController.text = "";
           _createUniqueIdController.text ="";
           _createPhoneController.text = "";
           _createModelController.text = "";
           _createContactController.text = "";
          _showCreateDialog();
        },
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget homeBody(BuildContext context) {

    return BlocBuilder<DevicesSettingBloc, DevicesSettingState>(
      builder: (context, state) {
        if (state is DevicesSettingLoadSuccess) {
          devices = state.devices;
          groups = state.groups;
          drivers = state.drivers;
          EasyLoading.dismiss();
          return Column(
            children: [
              Row(
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
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                      child: Container(
                        color: Colors.white12,
                        child: Directionality(
                          textDirection: TextDirection.rtl,
                          child: TextField(
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search),
                                border: OutlineInputBorder()
                            ),
                            onChanged: (value) {
                              context.read<DevicesSettingBloc>().add(
                                SearchDeviceSetting(state.devices, value),);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.deepPurple,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.20,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("Phone",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
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
                    itemCount: state.devices!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.20,
                                child: Center(
                                    child: Text(state.devices![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].uniqueId))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].phone!))
                            ),


                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () async {
                                  final  drivers  = await DeviceSettingApi.fetchDeviceDriver(state.devices![index].id,);
                                  _showUpdateDialog(
                                      state.devices![index].id,
                                      state.devices![index].name,
                                      state.devices![index].uniqueId,
                                      state.devices![index].groupId ,
                                      (state.devices![index].phone) ?? "",
                                      (state.devices![index].model) ?? "",
                                      (state.devices![index].contact) ?? "",
                                      (state.devices![index].category) ?? "",
                                    drivers
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.devices![index].id,
                                      state.devices![index].name);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                ),
              ),
            ],

          );
        }
        if (state is DevicesSettingLoadFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while loading devices"),
          );
        }
        if (state is DeleteDeviceSettingSuccess) {
          devices = state.devices;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Device deleted successfully');
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder()
                      ),
                      onChanged: (value) {
                        context.read<DevicesSettingBloc>().add(
                          SearchDeviceSetting(state.devices, value),);
                      },
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.deepPurple,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.20,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("Phone",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
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
                    itemCount: state.devices!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.20,
                                child: Center(
                                    child: Text(state.devices![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].uniqueId))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].phone!))
                            ),

                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () async {
                                  final  drivers  = await DeviceSettingApi.fetchDeviceDriver(state.devices![index].id,);
                                  _showUpdateDialog(
                                      state.devices![index].id,
                                      state.devices![index].name,
                                      state.devices![index].uniqueId,
                                      state.devices![index].groupId ,
                                      (state.devices![index].phone) ?? "",
                                      (state.devices![index].model) ?? "",
                                      (state.devices![index].contact) ?? "",
                                      (state.devices![index].category) ?? "",
                                      drivers
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.devices![index].id,
                                      state.devices![index].name);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                ),
              ),
            ],
          );
        }
        if (state is DeleteDeviceSettingFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while deleting device"),
          );
        }
        if (state is CreateDeviceSettingSuccess) {
          devices = state.devices;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Device created successfully');
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder()
                      ),
                      onChanged: (value) {
                        context.read<DevicesSettingBloc>().add(
                          SearchDeviceSetting(state.devices, value),);
                      },
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.deepPurple,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.20,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("Phone",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
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
                    itemCount: state.devices!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.20,
                                child: Center(
                                    child: Text(state.devices![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].uniqueId))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].phone!))
                            ),

                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () async {
                                  final  drivers  = await DeviceSettingApi.fetchDeviceDriver(state.devices![index].id,);
                                  _showUpdateDialog(
                                      state.devices![index].id,
                                      state.devices![index].name,
                                      state.devices![index].uniqueId,
                                      state.devices![index].groupId ,
                                      (state.devices![index].phone) ?? "",
                                      (state.devices![index].model) ?? "",
                                      (state.devices![index].contact) ?? "",
                                      (state.devices![index].category) ?? "",
                                      drivers
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.devices![index].id,
                                      state.devices![index].name);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                ),
              ),
            ],
          );
        }
        if (state is CreateDeviceSettingFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while creating device"),
          );
        }
        if (state is SearchDeviceSettingSuccess) {
          EasyLoading.dismiss();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder()
                      ),
                      onChanged: (value) {
                        context.read<DevicesSettingBloc>().add(
                          SearchDeviceSetting(devices, value),);
                      },
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.deepPurple,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.20,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("Phone",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
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
                    itemCount: state.devices!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.20,
                                child: Center(
                                    child: Text(state.devices![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].uniqueId))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].phone!))
                            ),

                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () async {
                                  final  drivers  = await DeviceSettingApi.fetchDeviceDriver(state.devices![index].id,);
                                  _showUpdateDialog(
                                      state.devices![index].id,
                                      state.devices![index].name,
                                      state.devices![index].uniqueId,
                                      state.devices![index].groupId ,
                                      (state.devices![index].phone) ?? "",
                                      (state.devices![index].model) ?? "",
                                      (state.devices![index].contact) ?? "",
                                      (state.devices![index].category) ?? "",
                                      drivers
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.devices![index].id,
                                      state.devices![index].name);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                ),
              ),
            ],

          );
        }
        if (state is SearchDeviceSettingFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while loading devices"),
          );
        }
        if (state is UpdateDeviceSettingSuccess) {
          devices = state.devices;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Driver updated successfully');
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: TextField(
                      decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder()
                      ),
                      onChanged: (value) {
                        context.read<DevicesSettingBloc>().add(
                          SearchDeviceSetting(state.devices, value),);
                      },
                    ),
                  ),
                ),
              ),
              Container(
                color: Colors.deepPurple,
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.20,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("Phone",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.15,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
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
                    itemCount: state.devices!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.20,
                                child: Center(
                                    child: Text(state.devices![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].uniqueId))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.devices![index].phone!))
                            ),

                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () async {
                                  final  drivers  = await DeviceSettingApi.fetchDeviceDriver(state.devices![index].id,);
                                  _showUpdateDialog(
                                      state.devices![index].id,
                                      state.devices![index].name,
                                      state.devices![index].uniqueId,
                                      state.devices![index].groupId ,
                                      (state.devices![index].phone) ?? "",
                                      (state.devices![index].model) ?? "",
                                      (state.devices![index].contact) ?? "",
                                      (state.devices![index].category) ?? "",
                                      drivers
                                  );
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.15,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.devices![index].id,
                                      state.devices![index].name);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      );
                    }

                ),
              ),
            ],
          );
        }
        if (state is UpdateDeviceSettingFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while updating device"),
          );
        }
        return Container();
      },
    );
  }



  void _showUpdateDialog(int id, String deviceName, String uniqueId, int groupId, String phone, String model, String contact, String category,List<Driver?>? selectedDrivers) {
    _updateDeviceNameController.text = deviceName;
    _updateUniqueIdController.text = uniqueId;
    _updatePhoneController.text = phone;
    _updateContactController.text = contact;
    _updateModelController.text = model;

    showDialog(
        context: context,
        builder: (BuildContext context1) {
          final List<String> categoryItems = ['default','truck', 'car', 'person'];
          String? selectedCategory = (category == "")? "default" : category;

          Group? selectedGroup;
          Group? group1;
          if(groupId ==0){
            selectedGroup = group1;
          }else{
            selectedGroup = groups!.firstWhere(
                  (group) => group.id == groupId,
            );
          }
          Driver? selectedDriver;
          Driver? driver1;
          if(selectedDrivers!.isEmpty){
            selectedDriver =driver1;
          }else{
            selectedDriver = drivers!.firstWhere(
                (driver) => driver.id == selectedDrivers[selectedDrivers.length-1]!.id,
            );
          }


          return BlocProvider.value(
            value: context.read<DevicesSettingBloc>(),
            child: AlertDialog(
              title: const Text("Update device"),
              content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState){
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _updateDeviceNameController,
                        decoration: const InputDecoration(
                          hintText: 'Enter new device name',
                          prefix: Text("device name:          "),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _updateUniqueIdController,
                        decoration: const InputDecoration(
                            hintText: 'Enter new uniqueId',
                            prefix: Text("UniqueId:          ")
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _updatePhoneController,
                        decoration: const InputDecoration(
                            hintText: 'Enter new phone',
                            prefix: Text("Phone:          ")
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: DropdownButton(

                          isExpanded: true,
                          hint: const Text('Select a group'),
                          value: selectedGroup,
                          items: groups?.map((Group group) {
                            return DropdownMenuItem<Group>(
                              value: group,
                              child: Text(group.name),
                            );
                          }).toList(),
                          onChanged: (Group? newValue) {
                            setState(() {
                              selectedGroup = newValue;
                            });
                          },
                        )
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text('Select a category'),
                          value: selectedCategory,
                          items: categoryItems.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedCategory = newValue;
                            });
                          },
                        )
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _updateModelController,
                        decoration: const InputDecoration(
                            hintText: 'Enter new model',
                            prefix: Text("Model:          ")
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topLeft,
                      child: TextField(
                        controller: _updateContactController,
                        decoration: const InputDecoration(
                            hintText: 'Enter new contact',
                            prefix: Text("Contact:          ")
                        ),
                      ),
                    ),
                    Align(
                        alignment: Alignment.topLeft,
                        child: DropdownButton(
                          isExpanded: true,
                          hint: const Text('Select a driver'),
                          value: selectedDriver,
                          items: drivers?.map((Driver? driver) {
                            return DropdownMenuItem<Driver>(
                              value: driver,
                              child: Text(driver!.name),
                            );
                          }).toList(),
                          onChanged: (Driver? newValue) {
                            setState(() {
                              selectedDriver = newValue;
                            });
                          },
                        )
                    ),
                  ],
                );
              }


              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context1).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if(selectedGroup == null){

                    }else{
                      String newDeviceName = _updateDeviceNameController.text;
                      String newUniqueId = _updateUniqueIdController.text;
                      int groupId = selectedGroup!.id;
                      String model = _updateModelController.text;
                      String phone = _updatePhoneController.text;
                      String contact = _updateContactController.text;
                      String category = selectedCategory!;
                      int newDriverId= (selectedDriver == null) ? 0 : selectedDriver!.id;
                      int oldDriverId =(selectedDrivers.isEmpty) ? 0 : selectedDrivers[0]!.id;
                      Navigator.of(context1).pop();
                      EasyLoading.show(status: 'Please wait');
                      context.read<DevicesSettingBloc>().add(
                        UpdateDeviceSetting(id, newDeviceName, newUniqueId,groupId,phone,model,contact,category,oldDriverId,newDriverId),);
                    }

                  },
                  child: const Text('Update'),
                )
              ],
            ),
          );
        }
    );
  }

  void _showDeleteDialog(int id, String deviceName) {
    showDialog(
        context: context,
        builder: (BuildContext context2) {
          return BlocProvider.value(
            value: context.read<DevicesSettingBloc>(),
            child: AlertDialog(
              title: const Text("Delete device"),
              content: Text(deviceName),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context2).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context2).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<DevicesSettingBloc>().add(DeleteDeviceSetting(id),);
                  },
                  child: const Text('Delete'),
                )
              ],
            ),
          );
        }
    );
  }

  void _showCreateDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context3) {
          final List<String> categoryItems = ['default','truck', 'car', 'person'];
          String? selectedCategory ="default";
          Group? selectedGroup = groups![0];
          return BlocProvider.value(
            value: context.read<DevicesSettingBloc>(),
            child: AlertDialog(
              title: const Text("Create device"),
              content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState){
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                          controller: _createDeviceNameController,
                          decoration: const InputDecoration(
                            labelText: 'Enter device name',
                            prefix: Text("device name:          "),
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                          controller: _createUniqueIdController,
                          decoration: const InputDecoration(
                              labelText: 'Enter uniqueId',
                              prefix: Text("UniqueId:          ")
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                          controller: _createPhoneController,
                          decoration: const InputDecoration(
                              labelText: 'Enter phone',
                              prefix: Text("Phone:          ")
                          ),
                        ),
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: DropdownButton(
                            isExpanded: true,
                            hint: const Text('Select a group'),
                            value: selectedGroup,
                            items: groups?.map((Group group) {
                              return DropdownMenuItem<Group>(
                                value: group,
                                child: Text(group.name),
                              );
                            }).toList(),
                            onChanged: (Group? newValue) {
                              setState(() {
                                selectedGroup = newValue;
                              });
                            },
                          )
                      ),
                      Align(
                          alignment: Alignment.topLeft,
                          child: DropdownButton(
                            isExpanded: true,
                            hint: const Text('Select a category'),
                            value: selectedCategory,
                            items: categoryItems.map((String item) {
                              return DropdownMenuItem<String>(
                                value: item,
                                child: Text(item),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedCategory = newValue;
                              });
                            },
                          )
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                          controller: _createModelController,
                          decoration: const InputDecoration(
                              labelText: 'Enter model',
                              prefix: Text("Model:          ")
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.topLeft,
                        child: TextField(
                          controller: _createContactController,
                          decoration: const InputDecoration(
                              labelText: 'Enter contact',
                              prefix: Text("Contact:          ")
                          ),
                        ),
                      ),

                    ],
                  );
                }

              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context3).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    String deviceName = _createDeviceNameController.text;
                    String uniqueID = _createUniqueIdController.text;
                    int groupId = selectedGroup!.id;
                    String phone = _createPhoneController.text;
                    String model = _createModelController.text;
                    String contact = _createContactController.text;
                    String category = selectedCategory!;
                    Navigator.of(context3).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<DevicesSettingBloc>().add(
                      CreateDeviceSetting(deviceName, uniqueID,groupId,phone,category,contact,model),);
                  },
                  child: const Text('Create'),
                )
              ],
            ),
          );
        }
    );
  }


}