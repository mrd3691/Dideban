part of 'users_bloc.dart';

@immutable
sealed class UsersEvent {}

final class FetchAllUsers extends UsersEvent{
  FetchAllUsers();
}

final class UpdateUser extends UsersEvent{
  final int id;
  final String newName;
  final String newUserName;
  final String newPassword;
  final List<Group> oldSelectedGroups;
  final List<Group> newSelectedGroups;
  UpdateUser(this.id, this.newName, this.newUserName, this.newPassword, this.oldSelectedGroups,this.newSelectedGroups);
}

final class DeleteUser extends UsersEvent{
  final int id;
  DeleteUser(this.id);
}

final class CreateUser extends UsersEvent{
  final String name;
  final String username;
  final String password;
  CreateUser( this.name, this.username , this.password);
}

final class SearchUser extends UsersEvent{
  final List<User>? users;
  final String searchedString;
  SearchUser(this.users,this.searchedString);
}

