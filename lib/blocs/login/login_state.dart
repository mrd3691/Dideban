part of 'login_bloc.dart';

@immutable
sealed class LoginState {}

final class LoginInitial extends LoginState {}

final class LoginInProgress extends LoginState {}

final class LoginSuccess extends LoginState {
  LoginSuccess();
}

final class LoginFailure extends LoginState {
  final String? message;
  LoginFailure(this.message);
}

