
class Group{

  Group({
    required this.id,
    required this.name,
    required this.groupId,
    required this.attributes,
  });

  int id;
  String name;
  int groupId;
  var attributes;

  factory Group.fromMap( Map<String , dynamic> json) {
    return Group(
      id: json["id"],
      name: json["name"],
      groupId: (json["groupid"] ?? 0),
      attributes: json["attributes"] ,
    );
  }




  Map<String , dynamic> toMap() => {
    "id":id,
    "name":name,
    "groupid":groupId,
    "attributes":attributes,

  };
}