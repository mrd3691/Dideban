part of 'groups_bloc.dart';

@immutable
sealed class GroupsEvent {}

final class FetchAllGroups extends GroupsEvent{
  FetchAllGroups();
}

final class UpdateGroup extends GroupsEvent{
  final int id;
  final String newGroupName;
  UpdateGroup(this.id, this.newGroupName);
}

final class DeleteGroup extends GroupsEvent{
  final int id;
  DeleteGroup(this.id);
}

final class CreateGroup extends GroupsEvent{
  final String groupName;
  CreateGroup( this.groupName);
}


