import 'dart:convert';
import 'package:dideban/models/total_speed_report.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import '../models/detail_speed_report.dart';
import '../models/device.dart';
import '../models/group.dart';
import '../utilities/util.dart';

class DetailSpeedReportApi{
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

  static Future<DetailSpeedReport?> fetchDetailSpeedReport(String deviceName, String startDateTime,String endDateTime, int speedLimit) async{
    try {

      var req = Map<String , dynamic>();
      req["deviceName"] = deviceName;
      req["startDateTime"] = startDateTime;
      req["endDateTime"] = endDateTime;
      req["speedLimit"] = speedLimit.toString();

      final response = await http.post(
          Uri.parse('${Config.serverAddress}/API/reports/detailSpeedReport.php'),
          body: req
      );
      if (response.statusCode == 200) {
        final parsed = json.decode(response.body);
        DetailSpeedReport detailSpeedReport = DetailSpeedReport.fromMap(parsed);
        return detailSpeedReport;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

}