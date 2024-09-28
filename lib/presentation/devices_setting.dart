import 'package:dideban/blocs/devices_setting/devices_setting_bloc.dart';
import 'package:dideban/models/driver.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../data/device_setting_api.dart';
import '../models/device.dart';
import '../models/group.dart';

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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body:
      BlocListener<DevicesSettingBloc, DevicesSettingState>(
          listener: (context, state) {
            if (state is DeviceSettingGroupsLoadSuccess){
              groups = state.groups;
            }
            if (state is DeviceSettingDriversLoadSuccess){
              drivers = state.drivers;
            }
          },
          child: homeBody(context),
      ),
      //homeBody(context),
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
                                      state.devices![index].groupId ?? 0,
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
          //EasyLoading.showError("An error occurred while loading groups");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while loading devices"),
            ),
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
                                      state.devices![index].groupId ?? 0,
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
          //EasyLoading.showError("An error occurred while deleting group");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while deleting device"),
            ),
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
                                      state.devices![index].groupId ?? 0,
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
          //EasyLoading.showError("An error occurred while creating group");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while creating device"),
            ),
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
                                      state.devices![index].groupId ?? 0,
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
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while loading devices"),
            ),
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
                                      state.devices![index].groupId ?? 0,
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
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while updating device"),
            ),
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