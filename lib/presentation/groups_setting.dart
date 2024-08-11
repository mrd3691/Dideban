import 'package:dideban/blocs/groups/groups_bloc.dart';
import 'package:dideban/presentation/tracking.dart';
import 'package:dideban/presentation/widgets/app_bar_dideban.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';


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
          appBar: AppBarDideban(username, userId),
          body:homeBody(context),
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
                  Container(
                      width: MediaQuery.of(context).size.width*0.5,
                      child: Center(child: Text(state.groups![index].name))
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                        onPressed: (){},
                        icon: const Icon(Icons.edit),
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width*0.2,
                    child: IconButton(
                      onPressed: (){},
                      icon: const Icon(Icons.delete),
                    ),
                  )
                ],
              
              ),
            ),
          );
        }
        return Container();
      },
    );
  }
}
