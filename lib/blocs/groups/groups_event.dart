part of 'groups_bloc.dart';

@immutable
sealed class GroupsEvent {}

final class FetchAllGroups extends GroupsEvent{

  FetchAllGroups();
}
