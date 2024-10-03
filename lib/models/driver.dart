
class Driver{

  Driver({
    required this.id,
    required this.name,
    required this.uniqueId,
    required this.attributes,
  });

  int id;
  String name;
  String uniqueId;
  final attributes;

  factory Driver.fromMap( Map<String , dynamic> json) {
    return Driver(
      id: json["id"],
      name: json["name"],
      uniqueId: (json["uniqueId"]),
      attributes: (json["attributes"]),
    );
  }


  Map<String , dynamic> toMap() => {
    "id":id,
    "name":name,
    "uniqueId":uniqueId,
    "attributes":attributes,

  };
}