import 'dart:convert';

class AuthStatus{

  AuthStatus({
    required this.id,
    required this.username,
    required this.name,
    required this.disabled,
    required this.error,
    required this.message,
  });

  String id;
  String username;
  String name;
  String disabled;
  bool error;
  String message;


  factory AuthStatus.fromMap( Map<String , dynamic> json) {
    return AuthStatus(
      id: (json["id"] ?? ""),
      username: (json["username"] ?? ""),
      name: (json["name"] ?? ""),
      disabled: (json["disabled"]?? ""),
      error: json["error"],
      message: json["message"],
    );
  }

  Map<String , dynamic> toMap() => {
    "id":id,
    "username":username,
    "name":name,
    "disabled":disabled,
    "error":error,
    "message":message
  };


}