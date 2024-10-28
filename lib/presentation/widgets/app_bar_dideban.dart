import 'package:dideban/blocs/devices_setting/devices_setting_bloc.dart';
import 'package:dideban/blocs/drivers/drivers_bloc.dart';
import 'package:dideban/blocs/home/home_bloc.dart';
import 'package:dideban/blocs/users/users_bloc.dart';
import 'package:dideban/presentation/devices_setting.dart';
import 'package:dideban/presentation/drivers_setting.dart';
import 'package:dideban/presentation/home.dart';
import 'package:dideban/presentation/user_setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocs/devices/devices_bloc.dart';
import '../../blocs/groups/groups_bloc.dart';
import '../../blocs/tracking/tracking_bloc.dart';
import '../groups_setting.dart';
import '../home_page.dart';
import '../login.dart';
import '../tracking.dart';

class AppBarDideban extends StatefulWidget implements  PreferredSizeWidget {
  const AppBarDideban({super.key});

  @override
  State<AppBarDideban> createState() => _AppBarDidebanState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

}

class _AppBarDidebanState extends State<AppBarDideban> {
  String userId = "";

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  Future<void>  getUserId()async{
    try{
      final SharedPreferences prefs = await _prefs;
      userId = prefs.getString('userId') ?? "";
    }catch(e){
      userId = "";
    }
  }

  Future<String>  getUserName()async{
    try{
      final SharedPreferences prefs = await _prefs;
      String userName =  prefs.getString('userName') ?? "";
      return userName;
    }catch(e){
      return "";
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getUserId();
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return AppBar(
      //title: Text("user:$userName"),
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
                      create: (context) => HomeBloc()
                        ..add(LoadDrawer(),),
                      child: const Home(),
                    ),
              ),
            );
          },
        ),
        /*IconButton(
          tooltip: "report",
          icon: const Icon(
            Icons.report_gmailerrorred_rounded,
          ),
          onPressed: () {},
        ),*/
        IconButton(
          tooltip: "tracking",
          icon: const Icon(
            Icons.track_changes,
          ),
          onPressed: () {

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) =>
                    BlocProvider(
                      create: (context) => TrackingBloc()
                        ..add(LoadDrawerTracking(),),
                      child: const Tracking(),
                    ),
              ),
            );

          },
        ),

        FutureBuilder<String>(
            future: getUserName(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if(snapshot.hasData){
                if(snapshot.data == "admin"){
                  return MenuAnchor(
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
                    menuChildren: List<MenuItemButton>.generate(5,
                          (int index) => MenuItemButton(
                        onPressed: () {
                          if(index == 0){
                            EasyLoading.show(status: 'Please wait');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocProvider(
                                      create: (context) => GroupsBloc()
                                        ..add(FetchAllGroups(),),
                                      child: const GroupsSetting(),
                                    ),
                              ),
                            );
                          }
                          if(index == 1){
                            EasyLoading.show(status: 'Please wait');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocProvider(
                                      create: (context) => DevicesSettingBloc()
                                        ..add(FetchAllDevicesSetting(),),
                                      child: const DevicesSetting(),
                                    ),
                              ),
                            );
                          }
                          if(index == 2){
                            EasyLoading.show(status: 'Please wait');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocProvider(
                                      create: (context) => DriversBloc()
                                        ..add(FetchAllDrivers(),),
                                      child: const DriversSetting(),
                                    ),
                              ),
                            );
                          }
                          if(index == 3){
                            EasyLoading.show(status: 'Please wait');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocProvider(
                                      create: (context) => UsersBloc()
                                        ..add(FetchAllUsers(),),
                                      child: const UsersSetting(),
                                    ),
                              ),
                            );
                          }
                          if(index == 4){
                            //EasyLoading.show(status: 'Please wait');
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (context) =>
                                    BlocProvider(
                                      create: (context) => HomeBloc()
                                        ..add(LoadDrawer(),),
                                      child: const Home1(),
                                    ),
                              ),
                            );
                          }
                        },
                        child: getSettingButton(index),
                      ),
                    ),
                  );
                }else {
                  return Container();
                }
              }else{
                return const CircularProgressIndicator();
              }
            }
        ),


        /*IconButton(
          tooltip: "account",
          icon: const Icon(
            Icons.account_circle,
          ),
          onPressed: () {},
        ),*/
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
    }else if( index == 3){
      return const Text("Users");
    } else if( index == 4){
      return const Text("Test");
    }
    return const Text("");
  }
}
