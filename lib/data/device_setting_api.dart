import 'dart:convert';
import 'package:dideban/utilities/util.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/device.dart';
import '../models/driver.dart';
import '../models/group.dart';


class DeviceSettingApi{

  static Future<List<Device>?> fetchAllDevices() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('${Config.serverAddressTraccar}/api/devices'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<Device> devices = jsonResponse.map<Device>( (json) =>  Device.fromMap(json) ).toList();
        return devices;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<int> updateDevice(int id, String newDeviceName, String newUniqueId, int newGroupId, String newPhone,String newModel,String newContact,String newCategory) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('PUT', Uri.parse('${Config.serverAddressTraccar}/api/devices/$id'));
      request.body = json.encode({
        "id": id,
        "name": newDeviceName,
        "uniqueId": newUniqueId,
        "status": null,
        "disabled": null,
        "lastUpdate": null,
        "positionId": 0,
        "groupId": newGroupId,
        "phone": newPhone,
        "model": newModel,
        "contact": newContact,
        "category": newCategory,
        "attributes": { }
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

  static Future<int> linkDeviceDriver(int deviceId, int driverId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('${Config.serverAddressTraccar}/api/permissions'));
      request.body = json.encode({
        "deviceId": deviceId,
        "driverId": driverId,

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

  static Future<int> unlinkDeviceDriver(int deviceId, int driverId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('${Config.serverAddressTraccar}/api/permissions'));
      request.body = json.encode({
        "deviceId": deviceId,
        "driverId": driverId,

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


  static Future<int> deleteDevice(int id) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('${Config.serverAddressTraccar}/api/devices/$id'));
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

  static Future<int> createDevice(String deviceName, String uniqueId, int groupId, String phone, String model, String contact, String category) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('${Config.serverAddressTraccar}/api/devices'));
      request.body = json.encode({
        "id": null,
        "name": deviceName,
        "uniqueId": uniqueId,
        "status": null,
        "disabled": null,
        "lastUpdate": null,
        "positionId": 0,
        "groupId": groupId,
        "phone": phone,
        "model": model,
        "contact": contact,
        "category": category,
        "attributes": { }
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

  static Future<List<Group>?> fetchAllGroups() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('${Config.serverAddressTraccar}/api/groups'));

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

  static Future<List<Driver>?> fetchAllDrivers() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('${Config.serverAddressTraccar}/api/drivers'));

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

  static Future<List<Driver>?> fetchDeviceDriver(int deviceId) async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('${Config.serverAddressTraccar}/api/drivers?deviceId=$deviceId'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<Driver> driver = jsonResponse.map<Driver>( (json) =>  Driver.fromMap(json) ).toList();
        return driver;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }


}