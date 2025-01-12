part of 'groups_bloc.dart';

@immutable
sealed class GroupsEvent {}

final class FetchAllGroups extends GroupsEvent{
  FetchAllGroups();
}

final class UpdateGroup extends GroupsEvent{
  final int id;
  final String newGroupName;
  final int parentId;
  UpdateGroup(this.id, this.newGroupName,this.parentId);
}

final class DeleteGroup extends GroupsEvent{
  final int id;
  DeleteGroup(this.id);
}

final class CreateGroup extends GroupsEvent{
  final String groupName;
  final int parentId;
  CreateGroup( this.groupName, this.parentId);
}

final class SearchGroup extends GroupsEvent{
  final List<Group>? groups;
  final String searchedString;
  SearchGroup(this.groups,this.searchedString);
}


