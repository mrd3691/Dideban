import 'package:dideban/blocs/groups/groups_bloc.dart';
import 'package:dideban/presentation/tracking.dart';
import 'package:dideban/presentation/widgets/dideban_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:dideban/blocs/devices/devices_bloc.dart';
import 'package:dideban/blocs/tracking/tracking_bloc.dart';
import 'home_page.dart';
import 'login.dart';

class GroupsSetting extends StatelessWidget {
  const GroupsSetting(this.username,this.userId ,{ super.key});
  final String username ;
  final String userId;

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dideban",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      builder: EasyLoading.init(),
      home: Scaffold(
          appBar: DidebanAppBar.call(username, userId, context),
          body:homeBody(context),
      ),
    );
  }

  Text getSettingButton(int index){
    if(index == 0){
      return const Text("Groups");
    }else if( index == 1){
      return const Text("Devices");
    }else if( index == 2){
      return const Text("Drivers");
    }
    return const Text("");
  }


  Widget homeBody(BuildContext context){
    return BlocBuilder<GroupsBloc, GroupsState>(
      builder: (context, state) {
        if(state is GroupsLoadSuccess){
          EasyLoading.dismiss();
          return ListView.separated(
            separatorBuilder: (context, index) => Divider(
              color: Colors.black,
            ),
            itemCount: state.groups!.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.all(8.0),
              child: Center(child: Text(state.groups![index].name)),
            ),
          );
        }
        return Container();
      },
    );
  }
}
