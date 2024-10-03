part of 'users_bloc.dart';

@immutable
sealed class UsersState {}

final class UsersInitial extends UsersState {}

//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class UsersLoadSuccess extends UsersState {
  final List<User>? users;
  final List<Group>? groups;
  UsersLoadSuccess({
    required this.users,required this.groups
  });
}

final class UsersLoadingInProgress extends UsersState {}

final class UsersLoadFailed extends UsersState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class UpdateUserLoadingInProgress extends UsersState {}

final class UpdateUserSuccess extends UsersState {
  final int statusCode;
  final List<User>? users;
  final List<Group>? groups;
  UpdateUserSuccess({required this.statusCode, required this.users,required this.groups});
}

final class UpdateUserFailed extends UsersState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeleteUserLoadingInProgress extends UsersState {}

final class DeleteUserSuccess extends UsersState {
  final int statusCode;
  final List<User>? users;
  final List<Group>? groups;
  DeleteUserSuccess({required this.statusCode, required this.users,required this.groups});
}

final class DeleteUserFailed extends UsersState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class CreateUserLoadingInProgress extends UsersState {}

final class CreateUserSuccess extends UsersState {
  final int statusCode;
  final List<User>? users;
  final List<Group>? groups;
  CreateUserSuccess({required this.statusCode, required this.users,required this.groups});
}

final class CreateUserFailed extends UsersState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class SearchUserLoadingInProgress extends UsersState {}

final class SearchUserSuccess extends UsersState {
  final List<User>? users;
  SearchUserSuccess({required this.users});
}

final class SearchUserFailed extends UsersState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
