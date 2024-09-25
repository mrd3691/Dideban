import 'package:flutter/material.dart';
import 'package:dideban/presentation/login.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

void main() {
  runApp( DidebanApp());
}

class DidebanApp extends StatefulWidget {
   DidebanApp({super.key});

  @override
  State<DidebanApp> createState() => _DidebanAppState();
}

class _DidebanAppState extends State<DidebanApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    easyLoadingInit();
  }

  void easyLoadingInit(){
    EasyLoading.instance
      ..indicatorType = EasyLoadingIndicatorType.fadingCircle
      ..userInteractions = false
      ..dismissOnTap = false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dideban application",
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      builder: EasyLoading.init(),
    );
  }
}





