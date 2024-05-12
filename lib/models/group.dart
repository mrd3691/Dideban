import 'dart:convert';

class Group{

  Group({
    required this.id,
    required this.name,
    required this.groupid,
    required this.attributes,
  });

  String id;
  String name;
  String groupid;
  String attributes;

  factory Group.fromMap( Map<String , dynamic> json) {
    return Group(
      id: json["id"],
      name: json["name"],
      groupid: (json["groupid"] ?? ""),
      attributes: json["attributes"],
    );
  }




  Map<String , dynamic> toMap() => {
    "id":id,
    "name":name,
    "groupid":groupid,
    "attributes":attributes,

  };
}