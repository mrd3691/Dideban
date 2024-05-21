import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dideban/models/deviceLocation.dart';
import 'package:dideban/models/deviceShow.dart';
import 'package:dideban/models/group.dart';
import 'package:dideban/models/authStatus.dart';
import 'package:http/http.dart' as http;

class API{
  static Future<List<Group>?> fetchAllGroups() async{
    try {
      final response = await http.post(Uri.parse('http://80.210.21.35/getAllGroups.php'));
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body).cast<Map<String , dynamic>>();
        List<Group> groups = parsed.map<Group>( (json) =>  Group.fromMap(json) ).toList();
        return groups;
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

  /*static Future<List<DeviceShow>?> fetchAllDevices() async{
    try {
      final response = await http.post(Uri.parse('http://80.210.21.35/getAllDevices.php'));
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
  }*/

  static Future<List<DeviceShow>?> fetchAllUserDevices(String userId) async{
    try {
      var req = Map<String , dynamic>();
      req["userId"] = userId;

      final response = await http.post(
          Uri.parse('http://80.210.21.35/getAllUserDevices.php'),
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
          Uri.parse('http://80.210.21.35/getDeviceLocation.php'),
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

      var req = Map<String , dynamic>();
      req["userName"] = userName;
      req["password"] = password;

      final response = await http.post(
          Uri.parse('http://80.210.21.35/userAuthenticate.php'),
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
          Uri.parse('http://80.210.21.35/getTrackingPoints.php'),
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