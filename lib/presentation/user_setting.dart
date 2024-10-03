import 'package:dideban/blocs/users/users_bloc.dart';
import 'package:dideban/data/user_api.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../blocs/devices/devices_bloc.dart';
import '../models/group.dart';
import '../models/user.dart';


class UsersSetting extends StatefulWidget {
  const UsersSetting({ super.key});
  @override
  State<UsersSetting> createState() => _UsersSettingState();
}

class _UsersSettingState extends State<UsersSetting> {
  final _updateNameController = TextEditingController();
  final _updateUserNameController = TextEditingController();
  final _updatePasswordController = TextEditingController();
  final _createNameController = TextEditingController();
  final _createUserNameController = TextEditingController();
  final _createPasswordController = TextEditingController();

  //only use for search and initial when other state is success
  List<User>? users = [];
  List<Group>? groups = [];

  @override
  void dispose() {
    _updateNameController.dispose();
    _updateUserNameController.dispose();
    _updatePasswordController.dispose();
    _createNameController.dispose();
    _createUserNameController.dispose();
    _createPasswordController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarDideban(),
      body:homeBody(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _createNameController.text = "";
          _createUserNameController.text = "";
          _createPasswordController.text ="";
          _showCreateDialog();
        },
        tooltip: 'Create',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget homeBody(BuildContext context) {
    return BlocBuilder<UsersBloc, UsersState>(
      builder: (context, state) {
        if (state is UsersLoadSuccess ) {
          users = state.users;
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
                        context.read<UsersBloc>().add(
                          SearchUser(state.users, value),);
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UserName",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
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
                    itemCount: state.users!.length,
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
                                    child: Text(state.users![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.users![index].email))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () async {
                                  _updateNameController.text ="";
                                  _updateUserNameController.text ="";
                                  _updatePasswordController.text ="";
                                  final  selectedGroups  = await UserAPI.fetchUserGroup(state.users![index].id,);
                                  _showUpdateDialog(state.users![index].id,
                                      state.users![index].name,
                                      state.users![index].email,
                                      selectedGroups!);
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
                                  _showDeleteDialog(state.users![index].id,
                                      state.users![index].email);
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
        if (state is UsersLoadFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while loading users"),
          );
        }
        if (state is CreateUserSuccess) {
          users = state.users;
          groups = state.groups;
          EasyLoading.dismiss();
          EasyLoading.showInfo('User created successfully');
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
                        context.read<UsersBloc>().add(
                          SearchUser(state.users, value),);
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UserName",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
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
                    itemCount: state.users!.length,
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
                                    child: Text(state.users![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.users![index].email))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () async {
                                  _updateNameController.text ="";
                                  _updateUserNameController.text ="";
                                  _updatePasswordController.text ="";
                                  final  selectedGroups  = await UserAPI.fetchUserGroup(state.users![index].id,);
                                  _showUpdateDialog(state.users![index].id,
                                      state.users![index].name,
                                      state.users![index].email,
                                      selectedGroups!);
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
                                  _showDeleteDialog(state.users![index].id,
                                      state.users![index].email);
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
        if (state is CreateUserFailed) {
          EasyLoading.dismiss();
          return  const Center(
            child:  Text("An error occurred while creating users"),
          );
        }
        if (state is DeleteUserSuccess) {
          users = state.users;
          groups = state.groups;
          EasyLoading.dismiss();
          EasyLoading.showInfo('User deleted successfully');
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
                        context.read<UsersBloc>().add(
                          SearchUser(state.users, value),);
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UserName",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
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
                    itemCount: state.users!.length,
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
                                    child: Text(state.users![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.users![index].email))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () async {
                                  _updateNameController.text ="";
                                  _updateUserNameController.text ="";
                                  _updatePasswordController.text ="";
                                  final  selectedGroups  = await UserAPI.fetchUserGroup(state.users![index].id,);
                                  _showUpdateDialog(state.users![index].id,
                                      state.users![index].name,
                                      state.users![index].email,
                                      selectedGroups!);
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
                                  _showDeleteDialog(state.users![index].id,
                                      state.users![index].email);
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
        if (state is DeleteUserFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while deleting user"),
          );
        }
        if (state is UpdateUserSuccess) {
          users = state.users;
          groups = state.groups;
          EasyLoading.dismiss();
          EasyLoading.showInfo('User updated successfully');
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
                        context.read<UsersBloc>().add(
                          SearchUser(state.users, value),);
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UserName",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
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
                    itemCount: state.users!.length,
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
                                    child: Text(state.users![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.users![index].email))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () async {
                                  _updateNameController.text ="";
                                  _updateUserNameController.text ="";
                                  _updatePasswordController.text ="";
                                  final  selectedGroups  = await UserAPI.fetchUserGroup(state.users![index].id,);
                                  _showUpdateDialog(state.users![index].id,
                                      state.users![index].name,
                                      state.users![index].email,
                                      selectedGroups!);
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
                                  _showDeleteDialog(state.users![index].id,
                                      state.users![index].email);
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
        if (state is UpdateUserFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while updating users"),
          );
        }
        if (state is SearchUserSuccess) {
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
                        context.read<UsersBloc>().add(
                          SearchUser(users, value),);
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
                              .width * 0.25,
                          child: const Center(child: Text("Name",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.25,
                          child: const Center(child: Text("UserName",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
                          child: const Center(child: Text("Update",
                            style: TextStyle(
                                color: Colors.white, fontSize: 15),))
                      ),
                      SizedBox(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width * 0.2,
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
                    itemCount: state.users!.length,
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
                                    child: Text(state.users![index].name))
                            ),
                            SizedBox(
                                width: MediaQuery
                                    .of(context)
                                    .size
                                    .width * 0.25,
                                child: Center(
                                    child: Text(state.users![index].email))
                            ),
                            SizedBox(
                              width: MediaQuery
                                  .of(context)
                                  .size
                                  .width * 0.2,
                              child: IconButton(
                                onPressed: () async {
                                  _updateNameController.text ="";
                                  _updateUserNameController.text ="";
                                  _updatePasswordController.text ="";
                                  final  selectedGroups  = await UserAPI.fetchUserGroup(state.users![index].id,);
                                  _showUpdateDialog(state.users![index].id,
                                      state.users![index].name,
                                      state.users![index].email,
                                      selectedGroups!);
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
                                  _showDeleteDialog(state.users![index].id,
                                      state.users![index].email);
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
        if (state is SearchUserFailed) {
          EasyLoading.dismiss();
          return const Center(
            child: Text("An error occurred while searching users"),
          );
        }

        return Container();
      },
    );
  }



  void _showCreateDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context3) {
          return BlocProvider.value(
            value: context.read<UsersBloc>(),
            child: AlertDialog(
              title: const Text("Create user"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: _createNameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter name',
                        prefix: Text("name:          "),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: _createUserNameController,
                      decoration: const InputDecoration(
                        labelText: 'Enter username',
                        prefix: Text("username:          "),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: TextField(
                      controller: _createPasswordController,
                      decoration: const InputDecoration(
                          labelText: 'Enter password',
                          prefix: Text("password:          ")
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
                    if(_createPasswordController.text.isEmpty ||
                    _createUserNameController.text.isEmpty ||
                    _createNameController.text.isEmpty){
                    EasyLoading.showInfo('Please import required fields');
                    }else{
                      String name = _createNameController.text;
                      String username = _createUserNameController.text;
                      String password = _createPasswordController.text;
                      Navigator.of(context3).pop();
                      EasyLoading.show(status: 'Please wait');
                      context.read<UsersBloc>().add(
                        CreateUser(name,username, password),);
                    }
                  },
                  child: const Text('Create'),
                )
              ],
            ),
          );
        }
    );
  }

  void _showDeleteDialog(int id, String username) {
    showDialog(
        context: context,
        builder: (BuildContext context2) {
          return BlocProvider.value(
            value: context.read<UsersBloc>(),
            child: AlertDialog(
              title: const Text("Delete user"),
              content: Text(username),
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
                    context.read<UsersBloc>().add(DeleteUser(id),);
                  },
                  child: const Text('Delete'),
                )
              ],
            ),
          );
        }
    );
  }

  void _showUpdateDialog(int id, String name, String username, List<Group> selectedGroups) {
    _updateNameController.text = name;
    _updateUserNameController.text = username;

    final items = groups!.map((group) => MultiSelectItem<Group>(group, group.name)).toList();
    List<Group> oldSelectedGroups = selectedGroups;
    List<Group> newSelectedGroups = selectedGroups;
    showDialog(
        context: context,
        builder: (BuildContext context1) {

          return BlocProvider.value(
            value: context.read<UsersBloc>(),
            child: AlertDialog(
              title: const Text("Update user"),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState){
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextField(
                            controller: _updateNameController,
                            decoration: const InputDecoration(
                              hintText: 'Enter new name',
                              prefix: Text("name:          "),
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextField(
                            controller: _updateUserNameController,
                            decoration: const InputDecoration(
                                hintText: 'Enter new username',
                                prefix: Text("username:          ")
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.topLeft,
                          child: TextField(
                            controller: _updatePasswordController,
                            decoration: const InputDecoration(
                                hintText: 'Enter new password',
                                prefix: Text("password:          ")
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.2,
                          //width: MediaQuery.of(context).size.width * 0.3,
                          child: MultiSelectDialogField(
                              items: items,
                              initialValue: newSelectedGroups,

                            onConfirm: (List<Group> values) {

                              setState(() {
                                newSelectedGroups = values;
                              });
                            },
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.all(Radius.circular(5)),
                              border: Border.all(
                                color: Colors.grey,
                                width: 1,
                              ),
                            ),

                            ),
                        )
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
                    if(_updatePasswordController.text.isEmpty ||
                       _updateUserNameController.text.isEmpty ||
                       _updateNameController.text.isEmpty){
                      EasyLoading.showInfo('Please import required fields');
                    }else{
                      String newName = _updateNameController.text;
                      String newUserName = _updateUserNameController.text;
                      String password = _updatePasswordController.text;
                      Navigator.of(context1).pop();
                      EasyLoading.show(status: 'Please wait');
                      context.read<UsersBloc>().add(
                        UpdateUser(id, newName,newUserName,password,oldSelectedGroups,newSelectedGroups),);
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


}