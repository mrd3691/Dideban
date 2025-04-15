import 'dart:convert';
import 'package:dideban/models/position.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/device.dart';
import '../models/driver.dart';
import '../models/group.dart';
import '../utilities/util.dart';
import 'package:encrypt_shared_preferences/provider.dart';

class HomeAPI{

  static Future<List<Device>?> getAllDevices() async{
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

  static Future<List<Group>?> getAllGroups() async{
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

  static Future<Position?> getPosition(int deviceId) async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('${Config.serverAddressTraccar}/api/positions?deviceId=$deviceId'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {


        final jsonResponse = json.decode(response.body);

        Position position = Position.fromJson(jsonResponse[0]); // Assuming the response is a list and you want the first item


        return position;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<List<Driver>?> getDeviceDriver(int deviceId) async{
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
        List<Driver> drivers = jsonResponse.map<Driver>( (json) =>  Driver.fromMap(json) ).toList();
        return drivers;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<List<Position>?> getLastPositions() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      //var request = http.Request('GET', Uri.parse('${Config.serverAddressTraccar}/api/positions'));


      String address ='${Config.serverAddressTraccar}/api/positions';

      /*String address ="";
      if(userName == "admin"){
        address = 'http://192.168.101.20:8082/api/positions';
      }else{
        address = '${Config.serverAddressTraccar}/api/positions';
      }*/
      var request = http.Request('GET', Uri.parse(address));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {

        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<Position> positions = jsonResponse.map<Position>( (json) =>  Position.fromJson(json) ).toList();


        return positions;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }


}