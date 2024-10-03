
class User{

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.readonly,
    required this.administrator,
    required this.map,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.password,
    required this.coordinateFormat,
    required this.disabled,
    required this.expirationTime,
    required this.deviceLimit,
    required this.userLimit,
    required this.deviceReadonly,
    required this.limitCommands,
    required this.fixedEmail,
    required this.poiLayer,
    required this.attributes,

  });

  int id;
  String name;
  String email;
  String? phone;
  bool? readonly;
  bool? administrator;
  String? map;
  double? latitude;
  double? longitude;
  int? zoom;
  String? password;
  String? coordinateFormat;
  bool? disabled;
  String? expirationTime;
  int? deviceLimit;
  int? userLimit;
  bool? deviceReadonly;
  bool? limitCommands;
  bool? fixedEmail;
  String? poiLayer;
  final attributes;

  factory User.fromMap( Map<String , dynamic> json) {
    return User(
      id: json["id"],
      name: json["name"],
      email: (json["email"]),
      phone: (json["phone"]),
      readonly: json["readonly"],
      administrator: json["administrator"],
      map: (json["map"]),
      latitude: (json["latitude"]),
      longitude: json["longitude"],
      zoom: json["zoom"],
      password: (json["password"]),
      coordinateFormat: (json["coordinateFormat"]),
      disabled: json["disabled"],
      expirationTime: json["expirationTime"],
      deviceLimit: (json["deviceLimit"]),
      userLimit: (json["userLimit"]),
      deviceReadonly: json["deviceReadonly"],
      limitCommands: json["limitCommands"],
      fixedEmail: (json["fixedEmail"]),
      poiLayer: (json["poiLayer"]),
      attributes: (json["attributes"]),
    );
  }

  Map<String , dynamic> toMap() => {
    "id":id,
    "name":name,
    "email":email,
    "phone":phone,
    "readonly":readonly,
    "administrator":administrator,
    "map":map,
    "latitude":latitude,
    "longitude":longitude,
    "zoom":zoom,
    "password":email,
    "coordinateFormat":coordinateFormat,
    "disabled":disabled,
    "expirationTime":expirationTime,
    "deviceLimit":deviceLimit,
    "userLimit":userLimit,
    "deviceReadonly":deviceReadonly,
    "limitCommands":limitCommands,
    "fixedEmail":fixedEmail,
    "poiLayer":poiLayer,
    "attributes":attributes,

  };
}