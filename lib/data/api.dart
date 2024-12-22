import 'dart:convert';
import 'package:dideban/utilities/util.dart';
import 'package:flutter/foundation.dart';
import 'package:dideban/models/deviceLocation.dart';
import 'package:dideban/models/deviceShow.dart';
import 'package:dideban/models/group.dart';
import 'package:dideban/models/authStatus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config.dart';

class API{

  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<List<DeviceShow>?> fetchAllUserDevices(String userId) async{
    try {
      var req = Map<String , dynamic>();
      req["userId"] = userId;

      final response = await http.post(
          Uri.parse('${Config.serverAddress}/API/getAllUserDevices.php'),
          body: req
      );
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body).cast<Map<String , dynamic>>();
        List<DeviceShow> devices = parsed.map<DeviceShow>( (json) =>  DeviceShow.fromMap(json) ).toList();
        return devices;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<List<DeviceLocation>?> fetchDeviceLocation(String deviceName) async{
    try {

      var req = Map<String , dynamic>();
      req["deviceName"] = deviceName;

      final response = await http.post(
          Uri.parse('${Config.serverAddressTraccar}/API/getDeviceLocation.php'),
          body: req
      );
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body).cast<Map<String , dynamic>>();
        List<DeviceLocation> deviceLocation = parsed.map<DeviceLocation>( (json) =>  DeviceLocation.fromMap(json)).toList();
        return deviceLocation;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  static Future<AuthStatus?> userAuthenticate(String userName,String password) async{
    try {
      var basicAuth = base64.encode(utf8.encode( "$userName:$password"));
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        //'Authorization': 'Basic $basicAuth',
        //'Cookie': 'JSESSIONID=node016fa0smer30xe178wumbnfnwgy89.node0'
      };

      var req = <String , dynamic>{};
      req["email"] = userName;
      req["password"] = password;


      final response = await http.post(
          Uri.parse('${Config.serverAddressTraccar}/api/session'),
          headers: headers,
          body: req
      );

      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        AuthStatus as = AuthStatus.fromMap(parsed);
        return as;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<DeviceLocation>?> fetchTrackingPoints(String deviceName, String startDateTime,String endDateTime) async{
    try {

      var req = Map<String , dynamic>();
      req["deviceName"] = deviceName;
      req["startDateTime"] = startDateTime;
      req["endDateTime"] = endDateTime;

      final response = await http.post(
          Uri.parse('${Config.serverAddress}/API/getTrackingPoints.php'),
          body: req
      );
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body).cast<Map<String , dynamic>>();
        List<DeviceLocation> deviceLocation = parsed.map<DeviceLocation>( (json) =>  DeviceLocation.fromMap(json)).toList();
        return deviceLocation;
      } else {
        return null;
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

}