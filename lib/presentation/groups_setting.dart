import 'package:dideban/blocs/groups/groups_bloc.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import '../models/group.dart';

class GroupsSetting extends StatefulWidget {
  const GroupsSetting({ super.key});
  @override
  State<GroupsSetting> createState() => _GroupsSettingState();
}

class _GroupsSettingState extends State<GroupsSetting> {
  final _updateGroupNameController = TextEditingController();
  final _createGroupNameController = TextEditingController();

  List<Group>? groups = [];

  @override
  void dispose() {
    _updateGroupNameController.dispose();
    _createGroupNameController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body:homeBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createGroupNameController.text="";
          _showCreateDialog();
        },
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget homeBody(BuildContext context){
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if (state is GroupsLoadSuccess) {
          groups = state.groups;
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
                        context.read<GroupsBloc>().add(
                          SearchGroup(state.groups, value),);
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
                              .width * 0.50,
                          child: const Center(child: Text("Name",
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
                    itemCount: state.groups!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.50,
                                child: Center(
                                    child: Text(state.groups![index].name))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.groups![index].id,
                                      state.groups![index].name,);
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
                                  _showDeleteDialog(state.groups![index].id,
                                      state.groups![index].name);
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
        if (state is GroupsLoadFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while loading groups"),
          );
        }
        if (state is UpdateGroupSuccess) {
          groups = state.groups;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Group updated successfully');
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
                          context.read<GroupsBloc>().add(
                            SearchGroup(state.groups, value),);
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
                                .width * 0.50,
                            child: const Center(child: Text("Name",
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
                    itemCount: state.groups!.length,
                    itemBuilder: (context, index) =>
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Row(
                            children: [
                              SizedBox(
                                  width: MediaQuery
                                      .of(context)
                                      .size
                                      .width * 0.50,
                                  child: Center(
                                      child: Text(state.groups![index].name))
                              ),
                              SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.2,
                                child: IconButton(
                                  onPressed: () {
                                    _showUpdateDialog(state.groups![index].id,
                                        state.groups![index].name,);
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
                                    _showDeleteDialog(state.groups![index].id,
                                        state.groups![index].name);
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
        if (state is UpdateGroupFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while updating group"),
          );
        }
        if (state is DeleteGroupSuccess) {
          groups = state.groups;
          EasyLoading.dismiss();
          EasyLoading.showInfo('group deleted successfully');
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
                        context.read<GroupsBloc>().add(
                          SearchGroup(state.groups, value),);
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
                              .width * 0.50,
                          child: const Center(child: Text("Name",
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
                  itemCount: state.groups!.length,
                  itemBuilder: (context, index) =>
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.50,
                                child: Center(
                                    child: Text(state.groups![index].name))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.groups![index].id,
                                      state.groups![index].name,);
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
                                  _showDeleteDialog(state.groups![index].id,
                                      state.groups![index].name);
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
        if (state is DeleteGroupFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while deleting group"),
          );
        }
        if (state is CreateGroupSuccess) {
          groups = state.groups;
          EasyLoading.dismiss();
          EasyLoading.showInfo('Group created successfully');
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
                        context.read<GroupsBloc>().add(
                          SearchGroup(state.groups, value),);
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
                              .width * 0.50,
                          child: const Center(child: Text("Name",
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
                    itemCount: state.groups!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.50,
                                child: Center(
                                    child: Text(state.groups![index].name))
                            ),

                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.groups![index].id,
                                      state.groups![index].name,);
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
                                  _showDeleteDialog(state.groups![index].id,
                                      state.groups![index].name);
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
        if (state is CreateGroupFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while creating group"),
          );
        }
        if (state is SearchGroupSuccess) {
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
                        context.read<GroupsBloc>().add(
                          SearchGroup(groups, value),);
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
                              .width * 0.50,
                          child: const Center(child: Text("Name",
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
                    itemCount: state.groups!.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Row(
                          children: [
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.50,
                                child: Center(
                                    child: Text(state.groups![index].name))
                            ),

                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () {
                                  _showUpdateDialog(state.groups![index].id,
                                      state.groups![index].name,);
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
                                  _showDeleteDialog(state.groups![index].id,
                                      state.groups![index].name);
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
        if (state is SearchGroupFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while loading groups"),
          );
        }
        return Container();
      },
    );
  }


  void _showUpdateDialog(int id,String groupName) {
    _updateGroupNameController.text = groupName;
    showDialog(
        context: context,
        builder: (BuildContext context1) {
          return BlocProvider.value(
            value: context.read<GroupsBloc>(),
            child: AlertDialog(
              title: const Text("Update group"),
              content: TextField(
                controller: _updateGroupNameController,
                decoration: const InputDecoration(hintText: 'Enter new value'),
              ),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context1).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: (){
                    String newGroupName = _updateGroupNameController.text;
                    Navigator.of(context1).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<GroupsBloc>().add(UpdateGroup(id, newGroupName),);
                  },
                  child: const Text('Update'),
                )
              ],
            ),
          );
        }
    );
  }

  void _showDeleteDialog(int id, String groupName) {
    showDialog(
        context: context,
        builder: (BuildContext context2) {
          return BlocProvider.value(
            value: context.read<GroupsBloc>(),
            child: AlertDialog(
              title: const Text("Delete group"),
              content: Text(groupName),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context2).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: (){
                    Navigator.of(context2).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<GroupsBloc>().add(DeleteGroup(id),);
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
            value: context.read<GroupsBloc>(),
            child: AlertDialog(
              title: const Text("Create group"),
              content: TextField(
                controller: _createGroupNameController,
                decoration: const InputDecoration(hintText: 'Enter group name'),
              ),
              actions: [
                TextButton(
                  onPressed: (){
                    Navigator.of(context3).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: (){
                    String groupName = _createGroupNameController.text;
                    Navigator.of(context3).pop();
                    EasyLoading.show(status: 'Please wait');
                    context.read<GroupsBloc>().add(CreateGroup(groupName),);
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





