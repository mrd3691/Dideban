import 'package:flutter/material.dart';
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
      home: LoginScreen(),
      /*routes:{
        "/":(context) => LoginScreen(),
      } ,*/
    );
  }
}





