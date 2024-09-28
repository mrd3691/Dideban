import 'package:dideban/blocs/groups/groups_bloc.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class GroupsSetting extends StatefulWidget {
  const GroupsSetting({ super.key});
  @override
  State<GroupsSetting> createState() => _GroupsSettingState();
}

class _GroupsSettingState extends State<GroupsSetting> {
  final _updateGroupNameController = TextEditingController();
  final _createGroupNameController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
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
        if(state is GroupsLoadSuccess){
          EasyLoading.dismiss();
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: state.groups!.length,
            itemBuilder: (context, index) => Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Center(child: Text(state.groups![index].name))
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                        onPressed: (){
                          _showUpdateDialog(int.parse(state.groups![index].id.toString()),state.groups![index].name);
                        },
                        icon: const Icon(Icons.edit),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showDeleteDialog(int.parse(state.groups![index].id.toString()), state.groups![index].name);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        if(state is GroupsLoadFailed){
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while loading groups");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while loading groups"),
            ),
          );
        }
        if(state is UpdateGroupSuccess){
          EasyLoading.dismiss();
          EasyLoading.showInfo('Group updated successfully');
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: state.groups!.length,
            itemBuilder: (context, index) => Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Center(child: Text(state.groups![index].name))
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showUpdateDialog(int.parse(state.groups![index].id.toString()),state.groups![index].name);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showDeleteDialog(int.parse(state.groups![index].id.toString()), state.groups![index].name);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        if(state is UpdateGroupFailed){
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while updating group");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while updating group"),
            ),
          );
        }
        if(state is DeleteGroupSuccess){
          EasyLoading.dismiss();
          EasyLoading.showInfo('Group deleted successfully');
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: state.groups!.length,
            itemBuilder: (context, index) => Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Center(child: Text(state.groups![index].name))
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showUpdateDialog(int.parse(state.groups![index].id.toString()),state.groups![index].name);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showDeleteDialog(int.parse(state.groups![index].id.toString()), state.groups![index].name);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        if(state is DeleteGroupFailed){
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
        if(state is CreateGroupSuccess){
          EasyLoading.dismiss();
          EasyLoading.showInfo('Group created successfully');
          return ListView.separated(
            separatorBuilder: (context, index) => const Divider(
              color: Colors.black,
            ),
            itemCount: state.groups!.length,
            itemBuilder: (context, index) => Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  SizedBox(
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Center(child: Text(state.groups![index].name))
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showUpdateDialog(int.parse(state.groups![index].id.toString()),state.groups![index].name);
                      },
                      icon: const Icon(Icons.edit),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){
                        _showDeleteDialog(int.parse(state.groups![index].id.toString()), state.groups![index].name);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  )
                ],
              ),
            ),
          );
        }
        if(state is CreateGroupFailed){
          EasyLoading.dismiss();
          //EasyLoading.showError("An error occurred while creating group");
          return Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("An error occurred while creating group"),
            ),
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





