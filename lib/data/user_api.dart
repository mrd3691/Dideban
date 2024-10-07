import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/group.dart';
import '../models/user.dart';
import '../utilities/util.dart';

class UserAPI{

  static Future<List<User>?> fetchAllUsers() async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('http://80.210.21.35:8082/api/users'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<User> users = jsonResponse.map<User>( (json) =>  User.fromMap(json) ).toList();
        return users;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<int> updateUser(int id, String newName, String newUserName, String newPassword) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('PUT', Uri.parse('http://80.210.21.35:8082/api/users/$id'));
      request.body = json.encode({
        "id": id,
        "name": newName,
        "email": newUserName,
        "phone": null,
        "readonly": true,
        "administrator": false,
        "map": null,
        "latitude": 0,
        "longitude": 0,
        "zoom": 0,
        "password": newPassword,
        "coordinateFormat": null,
        "disabled": false,
        "expirationTime": null,
        "deviceLimit": -1,
        "userLimit": 0,
        "deviceReadonly": false,
        "limitCommands": false,
        "fixedEmail": false,
        "poiLayer": null,
        "attributes": { }
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  static Future<int> deleteUser(int id) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('http://80.210.21.35:8082/api/users/$id'));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  static Future<int> createUser(String name,String username, String userPassword) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('http://80.210.21.35:8082/api/users'));
      request.body = json.encode({
        "id": null,
        "name": name,
        "email": username,
        "phone": null,
        "readonly": true,
        "administrator": false,
        "map": null,
        "latitude": 0,
        "longitude": 0,
        "zoom": 0,
        "password": userPassword,
        "coordinateFormat": null,
        "disabled": false,
        "expirationTime": null,
        "deviceLimit": -1,
        "userLimit": 0,
        "deviceReadonly": false,
        "limitCommands": false,
        "fixedEmail": false,
        "poiLayer": null,
        "attributes": { }

      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
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

  static Future<List<Group>?> fetchUserGroup(int userId) async{
    try{
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('GET', Uri.parse('http://80.210.21.35:8082/api/groups?userId=$userId'));

      request.headers.addAll(headers);
      http.StreamedResponse streamedResponse = await request.send();
      http.Response response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(utf8.decode(response.bodyBytes));
        List<Group> group = jsonResponse.map<Group>( (json) =>  Group.fromMap(json) ).toList();
        return group;
      } else {
        return null;
      }
    }catch(e){
      return null;
    }
  }

  static Future<int> linkUserGroup(int userId, int groupId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('POST', Uri.parse('http://80.210.21.35:8082/api/permissions'));
      request.body = json.encode({
        "userId": userId,
        "groupId": groupId,
      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }

  static Future<int> unlinkUserGroup(int userId, int groupId) async{
    try {
      String userName =await Util.getUserName();
      String password =await Util.getPassword();
      String auth = base64Encode(utf8.encode("$userName:$password"));
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': auth
      };
      var request = http.Request('DELETE', Uri.parse('http://80.210.21.35:8082/api/permissions'));
      request.body = json.encode({
        "userId": userId,
        "groupId": groupId,

      });
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      return response.statusCode;
    } catch (e) {
      return -1;
    }
  }
}