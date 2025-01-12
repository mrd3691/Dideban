import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart';
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

  static Future<int> updateGroup(int id, String newGroupName,int parentId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('PUT', Uri.parse('${Config.serverAddressTraccar}/api/groups/$id'));
      request.body = json.encode({
        "id": id,
        "name": newGroupName,
        "groupId": parentId,
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
      var request = http.Request('DELETE', Uri.parse('${Config.serverAddressTraccar}/api/groups/$id'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  static Future<int> createGroup(String groupName, int parentId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('${Config.serverAddressTraccar}/api/groups'));
      request.body = json.encode({
        "id": null,
        "attributes": {},
        "groupId": parentId,
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