import 'dart:convert';

class AuthStatus{

  AuthStatus({
    required this.id,
    required this.name,
    /*required this.attributes,
    required this.login,
    required this.email,
    required this.phone,
    required this.readonly,
    required this.administrator,
    required this.map,
    required this.latitude,
    required this.longitude,
    required this.zoom,
    required this.twelveHourFormat,
    required this.coordinateFormat,
    required this.disabled,
    required this.expirationTime,
    required this.deviceLimit,
    required this.userLimit,
    required this.deviceReadonly,
    required this.limitCommands,
    required this.disableReports,
    required this.fixedEmail,
    required this.poiLayer,
    required this.password,*/

  });

  int id;
  String name;
  /*Attributes attributes;
  String? login;
  String email;
  String? phone;
  bool readonly;
  bool administrator;
  String? map;
  double latitude;
  double longitude;
  int zoom;
  bool twelveHourFormat;
  String? coordinateFormat;
  bool disabled;
  DateTime? expirationTime;
  int deviceLimit;
  int userLimit;
  bool deviceReadonly;
  bool limitCommands;
  bool disableReports;
  bool fixedEmail;
  String? poiLayer;
  String? password;*/


  factory AuthStatus.fromMap( Map<String , dynamic> json) {
    return AuthStatus(
      id: (json["id"] ?? ""),
      name: (json["name"] ?? ""),
      /*attributes: Attributes.fromMap(json["attributes"]),
      login: (json["login"]?? ""),
      email: json["email"],
      phone: (json["phone"] ?? ""),
      readonly: json["readonly"],
      administrator: json["administrator"],
      map: json["map"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      zoom: json["zoom"],
      twelveHourFormat: json["twelveHourFormat"],
      coordinateFormat: json["coordinateFormat"],
      disabled: json["disabled"],
      expirationTime: json["expirationTime"],
      deviceLimit: json["deviceLimit"],
      userLimit: json["userLimit"],
      deviceReadonly: json["deviceReadonly"],
      limitCommands: json["limitCommands"],
      disableReports: json["disableReports"],
      fixedEmail: json["fixedEmail"],
      poiLayer: json["poiLayer"],
      password: json["password"],*/
    );
  }
}

class Attributes{
  Attributes({
    required this.speedUnit,
    required this.mapTilerKey,
    required this.openWeatherKey,
    required this.activeMapStyles,
    required this.deviceSecondary,
    required this.positionItems,
    required this.distanceUnit
  });

  String speedUnit;
  String mapTilerKey;
  String openWeatherKey;
  String activeMapStyles;
  String deviceSecondary;
  String positionItems;
  String distanceUnit;

  factory Attributes.fromMap( Map<String , dynamic> json) {
    return Attributes(
      speedUnit: (json["speedUnit"] ?? ""),
      mapTilerKey: (json["mapTilerKey"] ?? ""),
      openWeatherKey: (json["openWeatherKey"] ?? ""),
      activeMapStyles: (json["activeMapStyles"]?? ""),
      deviceSecondary: json["deviceSecondary"],
      positionItems: json["positionItems"],
      distanceUnit: json["distanceUnit"],
    );
  }
}