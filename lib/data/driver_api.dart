import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/driver.dart';
import '../utilities/util.dart';

class DriverAPI{

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

  static Future<int> updateDriver(int id, String newDriverName, String newUniqueId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('PUT', Uri.parse('${Config.serverAddressTraccar}/api/drivers/$id'));
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
      return -1;
    }
  }

  static Future<int> deleteDriver(int id) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('${Config.serverAddressTraccar}/api/drivers/$id'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  static Future<int> createDriver(String driverName, String uniqueId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('${Config.serverAddressTraccar}/api/drivers'));
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
      return -1;
    }
  }
}