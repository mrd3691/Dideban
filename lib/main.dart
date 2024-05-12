import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dideban/blocs/login/login_bloc.dart';
import 'package:dideban/presentation/home_page.dart';

import 'package:dideban/presentation/login.dart';

void main() {
  runApp(const DidebanApp());
}

class DidebanApp extends StatelessWidget {
  const DidebanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dideban application",
      theme: ThemeData(
        //primaryColor: Colors.grey,
      ),
      home: BlocProvider (
        create: (context) => LoginBloc(),
        child: LoginScreen(),
      ),
      /*routes:{
        "/":(context) => LoginScreen(),
      } ,*/
    );
  }
}





