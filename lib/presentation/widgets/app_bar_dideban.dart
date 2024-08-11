import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/devices/devices_bloc.dart';
import '../../blocs/groups/groups_bloc.dart';
import '../../blocs/tracking/tracking_bloc.dart';
import '../groups_setting.dart';
import '../home_page.dart';
import '../login.dart';
import '../tracking.dart';

class AppBarDideban extends StatelessWidget implements  PreferredSizeWidget {
  const AppBarDideban(this.username,this.userId,{super.key});
  final String username;
  final String userId;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text("user:$username"),
      actions: [
        IconButton(
          tooltip: "Home",
          icon: const Icon(
            Icons.home,
          ),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    BlocProvider(
                      create: (context) => DevicesBloc()
                        ..add(FetchAllDevices(userId),),
                      child: Home(username,userId),
                    ),
              ),
            );
          },
        ),
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

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    MultiBlocProvider(providers: [
                      BlocProvider(create: (context) => DevicesBloc()..add(FetchAllDevices(userId))),
                      BlocProvider(create: (context) => TrackingBloc())
                    ], child: Tracking(username,userId)),
              ),
            );

          },
        ),
        (username == "admin")?MenuAnchor(
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
              tooltip: 'Management',
            );
          },
          menuChildren: List<MenuItemButton>.generate(3,
                (int index) => MenuItemButton(
              onPressed: () {
                try{
                  if(index == 0){
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) =>
                            BlocProvider(
                              create: (context) => GroupsBloc()
                                ..add(FetchAllGroups(),),
                              child: GroupsSetting(username,userId),
                            ),
                      ),
                    );
                  }
                }
                catch(e){
                  //print(e);
                }


              },
              child: getSettingButton(index),
            ),
          ),
        ):Container(),
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
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
          },
        ),
      ],
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
}
