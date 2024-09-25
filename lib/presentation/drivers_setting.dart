import 'package:dideban/blocs/drivers/drivers_bloc.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/driver.dart';

class DriversSetting extends StatefulWidget {
  const DriversSetting({ super.key});
  @override
  State<DriversSetting> createState() => _DriversSettingState();
}

class _DriversSettingState extends State<DriversSetting> {
  final _updateDriverNameController = TextEditingController();
  final _updateUniqueIdController = TextEditingController();
  final _createDriverNameController = TextEditingController();
  final _createUniqueIdController = TextEditingController();

  //only use for search and initial when other state is success
  List<Driver>? drivers = [];



  @override
  void dispose() {
    // TODO: implement dispose
    _updateDriverNameController.dispose();
    _updateUniqueIdController.dispose();
    _createDriverNameController.dispose();
    _createUniqueIdController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body: homeBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createDriverNameController.text = "";
          _createUniqueIdController.text = "";
          _showCreateDialog();
        },
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget homeBody(BuildContext context) {
    return BlocBuilder<DriversBloc, DriversState>(
      builder: (context, state) {
        if (state is DriversLoadSuccess) {
          drivers = state.drivers;
          EasyLoading.dismiss();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, top: 4, right: 4),
                            child: TextField(
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder()
                              ),
                              onChanged: (value) {
                                context.read<DriversBloc>().add(
                                  SearchDriver(state.drivers, value),);
                              },
                            ),
                          ),
                        ),
                      ],
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
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
                    itemCount: state.drivers!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].uniqueId))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.drivers![index].id,
                                      state.drivers![index].name,
                                      state.drivers![index].uniqueId);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.drivers![index].id,
                                      state.drivers![index].name);
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
        if (state is DriversLoadFailed) {
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while loading groups");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while loading drivers"),
            ),
          );
        }
        if (state is UpdateDriverSuccess) {
          drivers = state.drivers;
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
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 4, top: 4, right: 4),
                              child: TextField(
                                decoration: const InputDecoration(
                                    prefixIcon: Icon(Icons.search),
                                    border: OutlineInputBorder()
                                ),
                                onChanged: (value) {
                                  context.read<DriversBloc>().add(
                                    SearchDriver(state.drivers, value),);
                                },
                              ),
                            ),
                          ),
                        ],
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
                                .width * 0.25,
                            child: const Center(child: Text("Name",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),))
                        ),
                        SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.25,
                            child: const Center(child: Text("UniqueId",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),))
                        ),
                        SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.2,
                            child: const Center(child: Text("Update",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),))
                        ),
                        SizedBox(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.2,
                            child: const Center(child: Text("Remove",
                              style: TextStyle(
                                  color: Colors.white, fontSize: 20),))
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
                    itemCount: state.drivers!.length,
                    itemBuilder: (context, index) =>
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            children: [
                              SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.25,
                                  child: Center(
                                      child: Text(state.drivers![index].name))
                              ),
                              SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.25,
                                  child: Center(child: Text(
                                      state.drivers![index].uniqueId))
                              ),
                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.2,
                                child: IconButton(
                                  onPressed: () {
                                    _showUpdateDialog(state.drivers![index].id,
                                        state.drivers![index].name,
                                        state.drivers![index].uniqueId);
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.2,
                                child: IconButton(
                                  onPressed: () {
                                    _showDeleteDialog(state.drivers![index].id,
                                        state.drivers![index].name);
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              )
                            ],
                          ),
                        ),
                  ),
                ),
              ]

          );
        }
        if (state is UpdateDriverFailed) {
          EasyLoading.dismiss();
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while updating driver"),
            ),
          );
        }
        if (state is DeleteDriverSuccess) {
          drivers = state.drivers;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Driver deleted successfully');
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, top: 4, right: 4),
                            child: TextField(
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder()
                              ),
                              onChanged: (value) {
                                context.read<DriversBloc>().add(
                                  SearchDriver(state.drivers, value),);
                              },
                            ),
                          ),
                        ),
                      ],
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
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
                  itemCount: state.drivers!.length,
                  itemBuilder: (context, index) =>
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].uniqueId))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.drivers![index].id,
                                      state.drivers![index].name,
                                      state.drivers![index].uniqueId);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.drivers![index].id,
                                      state.drivers![index].name);
                                },
                                icon: const Icon(Icons.delete),
                              ),
                            )
                          ],
                        ),
                      ),
                ),
              ),
            ],
          );
        }
        if (state is DeleteDriverFailed) {
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while deleting group");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while deleting group"),
            ),
          );
        }
        if (state is CreateDriverSuccess) {
          drivers = state.drivers;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Driver created successfully');
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, top: 4, right: 4),
                            child: TextField(
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder()
                              ),
                              onChanged: (value) {
                                context.read<DriversBloc>().add(
                                  SearchDriver(state.drivers, value),);
                              },
                            ),
                          ),
                        ),
                      ],
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
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
                    itemCount: state.drivers!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(child: Text(state.drivers![index]
                                    .uniqueId))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.drivers![index].id,
                                      state.drivers![index].name,
                                      state.drivers![index].uniqueId);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.drivers![index].id,
                                      state.drivers![index].name);
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
        if (state is CreateDriverFailed) {
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while creating group");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while creating driver"),
            ),
          );
        }
        if (state is SearchDriverSuccess) {
          EasyLoading.dismiss();
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 5, bottom: 5, left: 5),
                child: Container(
                  color: Colors.white12,
                  child: Directionality(
                    textDirection: TextDirection.rtl,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                bottom: 4, top: 4, right: 4),
                            child: TextField(
                              decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.search),
                                  border: OutlineInputBorder()
                              ),
                              onChanged: (value) {
                                context.read<DriversBloc>().add(
                                  SearchDriver(drivers, value),);
                              },
                            ),
                          ),
                        ),
                      ],
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UniqueId",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Remove",
                            style: TextStyle(
                                color: Colors.white, fontSize: 20),))
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
                    itemCount: state.drivers!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.drivers![index].uniqueId))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.drivers![index].id,
                                      state.drivers![index].name,
                                      state.drivers![index].uniqueId);
                                },
                                icon: const Icon(Icons.edit),
                              ),
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showDeleteDialog(state.drivers![index].id,
                                      state.drivers![index].name);
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
        if (state is SearchDriverFailed) {
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while loading groups");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while loading drivers"),
            ),
          );
        }

        return Container();
      },
    );
  }


  void _showUpdateDialog(int id, String driverName, String uniqueId) {
    _updateDriverNameController.text = driverName;
    _updateUniqueIdController.text = uniqueId;
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return BlocProvider.value(
            value: context.read<DriversBloc>(),
            child: AlertDialog(
              title: const Text("Update driver"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: _updateDriverNameController,
                      decoration: const InputDecoration(
                          hintText: 'Enter new driver name',
                          prefix: Text("Driver name:          ")
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
                ],
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
                    String newDriverName = _updateDriverNameController.text;
                    String newUniqueId = _updateUniqueIdController.text;
                    Navigator.of(context1).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<DriversBloc>().add(
                      UpdateDriver(id, newDriverName, newUniqueId),);
                  },
                  child: const Text('Update'),
                )
              ],
            ),
          );
        }
    );
  }

  void _showDeleteDialog(int id, String driverName) {
    showDialog(
        context: context,
        builder: (BuildContext context2) {
          return BlocProvider.value(
            value: context.read<DriversBloc>(),
            child: AlertDialog(
              title: const Text("Delete driver"),
              content: Text(driverName),
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
                    context.read<DriversBloc>().add(DeleteDriver(id),);
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
          return BlocProvider.value(
            value: context.read<DriversBloc>(),
            child: AlertDialog(
              title: const Text("Create driver"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: _createDriverNameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter driver name',
                        prefix: Text("Driver name:          "),
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
                ],
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
                    String driverName = _createDriverNameController.text;
                    String uniqueID = _createUniqueIdController.text;
                    Navigator.of(context3).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<DriversBloc>().add(
                      CreateDriver(driverName, uniqueID),);
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