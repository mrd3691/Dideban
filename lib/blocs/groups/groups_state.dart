
part of 'groups_bloc.dart';

@immutable
sealed class GroupsState {}

final class GroupsInitial extends GroupsState {}

final class GroupsLoadSuccess extends GroupsState {
  final List<Group>? groups;
  GroupsLoadSuccess({
    required this.groups,
  });
}

final class GroupsLoadingInProgress extends GroupsState {}