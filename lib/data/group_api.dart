import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group.dart';
import '../utilities/util.dart';

class GroupAPI{

  static Future<List<Group>?> fetchAllGroups() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
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

  static Future<int> updateGroup(int id, String newGroupName) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
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
      return -1;
    }
  }

  static Future<int> deleteGroup(int id) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('http://80.210.21.35:8082/api/groups/$id'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  static Future<int> createGroup(String groupName) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
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
      return -1;
    }
  }
}