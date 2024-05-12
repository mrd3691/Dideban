part of 'login_bloc.dart';

@immutable
sealed class LoginEvent {}

final class UserAuthenticate extends LoginEvent {
  final String userName;
  final String password;
  UserAuthenticate(this.userName, this.password);
}