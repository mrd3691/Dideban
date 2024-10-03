
part of 'groups_bloc.dart';

@immutable
sealed class GroupsState {}

final class GroupsInitial extends GroupsState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class GroupsLoadSuccess extends GroupsState {
  final List<Group>? groups;
  GroupsLoadSuccess({
    required this.groups,
  });
}

final class GroupsLoadingInProgress extends GroupsState {}

final class GroupsLoadFailed extends GroupsState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class UpdateGroupLoadingInProgress extends GroupsState {}

final class UpdateGroupSuccess extends GroupsState {
  final int statusCode;
  final List<Group>? groups;
  UpdateGroupSuccess({required this.statusCode, required this.groups});
}

final class UpdateGroupFailed extends GroupsState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeleteGroupLoadingInProgress extends GroupsState {}

final class DeleteGroupSuccess extends GroupsState {
  final int statusCode;
  final List<Group>? groups;
  DeleteGroupSuccess({required this.statusCode, required this.groups});
}

final class DeleteGroupFailed extends GroupsState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class CreateGroupLoadingInProgress extends GroupsState {}

final class CreateGroupSuccess extends GroupsState {
  final int statusCode;
  final List<Group>? groups;
  CreateGroupSuccess({required this.statusCode, required this.groups});
}

final class CreateGroupFailed extends GroupsState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class SearchGroupLoadingInProgress extends GroupsState {}

final class SearchGroupSuccess extends GroupsState {
  final List<Group>? groups;
  SearchGroupSuccess({required this.groups});
}

final class SearchGroupFailed extends GroupsState {}