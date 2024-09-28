import 'dart:convert';
import 'package:dideban/utilities/util.dart';
import 'package:flutter/foundation.dart';
import 'package:dideban/models/deviceLocation.dart';
import 'package:dideban/models/deviceShow.dart';
import 'package:dideban/models/group.dart';
import 'package:dideban/models/authStatus.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/driver.dart';

class API{

  static final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  static Future<List<Group>?> fetchAllGroups11111() async{
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

  static Future<List<Group>?> fetchAllGroups() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('http://80.210.21.35:8082/api/groups'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<Group> groups = jsonResponse.map<Group>( (json) =>  Group.fromMap(json) ).toList();
        return groups;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

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
      var basicAuth = base64.encode(utf8.encode( "$userName:$password"));
      var headers = {
        'Content-Type': 'application/x-www-form-urlencoded',
        'Authorization': 'Basic $basicAuth',
        'Cookie': 'JSESSIONID=node016fa0smer30xe178wumbnfnwgy89.node0'
      };

      var req = <String , dynamic>{};
      req["email"] = userName;
      req["password"] = password;


      final response = await http.post(
          Uri.parse('http://80.210.21.35:8082/api/session'),
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

  static Future<int> updateGroup(int id, String newGroupName) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('PUT', Uri.parse('http://80.210.21.35:8082/api/groups/$id'));
      request.body = json.encode({
        "id": id,
        "name": newGroupName,
        "groupId": 0,
        "attributes": {}
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }

  static Future<int> deleteGroup(int id) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('http://80.210.21.35:8082/api/groups/$id'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }

  static Future<int> createGroup(String groupName) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('http://80.210.21.35:8082/api/groups'));
      request.body = json.encode({
        "id": null,
        "attributes": {},
        "groupId": 0,
        "name": groupName
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }





  static Future<List<Driver>?> fetchAllDrivers() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('http://80.210.21.35:8082/api/drivers'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<Driver> drivers = jsonResponse.map<Driver>( (json) =>  Driver.fromMap(json) ).toList();
        return drivers;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<int> updateDriver(int id, String newDriverName, String newUniqueId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('PUT', Uri.parse('http://80.210.21.35:8082/api/drivers/$id'));
      request.body = json.encode({
        "id": id,
        "name": newDriverName,
        "uniqueId": newUniqueId,
        "attributes": {}
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }

  static Future<int> deleteDriver(int id) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('http://80.210.21.35:8082/api/drivers/$id'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }

  static Future<int> createDriver(String driverName, String uniqueId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.readFromSecureStorage("password");
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('http://80.210.21.35:8082/api/drivers'));
      request.body = json.encode({
        "id": null,
        "attributes": {},
        "uniqueId": uniqueId,
        "name": driverName
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return -1;
    }
  }



}