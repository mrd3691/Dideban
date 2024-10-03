import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dideban/data/group_api.dart';
import 'package:meta/meta.dart';
import 'package:dideban/models/group.dart';
part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc() : super(GroupsInitial()) {

    on<FetchAllGroups>(fetchAllGroups);
    on<UpdateGroup>(updateGroup);
    on<DeleteGroup>(deleteGroup);
    on<CreateGroup>(createGroup);
    on<SearchGroup>(searchGroup);
  }

  FutureOr<void> searchGroup(SearchGroup event, Emitter<GroupsState> emit,) async {
    try{
      emit(SearchGroupLoadingInProgress());
      List<Group>? searchedGroups =[];
      searchedGroups = event.groups?.where((group) {
        return group.name.toLowerCase().contains(event.searchedString.toLowerCase());
      }).toList();
      emit(SearchGroupSuccess(groups: searchedGroups));
    }catch(e){
      emit(SearchGroupFailed());
    }
  }

  FutureOr<void> fetchAllGroups(FetchAllGroups event, Emitter<GroupsState> emit,) async {
    try{
      emit(GroupsLoadingInProgress());
      final groups  = await GroupAPI.fetchAllGroups();
      if(groups == null){
        emit(GroupsLoadFailed());
      }
      emit(GroupsLoadSuccess(groups: groups));
    }catch(e){
      emit(GroupsLoadFailed());
    }
  }

  FutureOr<void> updateGroup(UpdateGroup event, Emitter<GroupsState> emit,) async {
    try{
      emit(UpdateGroupLoadingInProgress());
      int id = event.id;
      String newGroupName = event.newGroupName;
      int statusCode = await GroupAPI.updateGroup(id, newGroupName);
      List<Group>? groups  = await GroupAPI.fetchAllGroups();
      if(statusCode != 200){
        emit(UpdateGroupFailed());
      }else{
        emit(UpdateGroupSuccess(statusCode: statusCode, groups: groups));
      }
    }catch(e){
      emit(UpdateGroupFailed());
    }
  }

  FutureOr<void> deleteGroup(DeleteGroup event, Emitter<GroupsState> emit,) async {
    try{
      emit(DeleteGroupLoadingInProgress());
      int id = event.id;
      int statusCode = await GroupAPI.deleteGroup(id);
      List<Group>? groups  = await GroupAPI.fetchAllGroups();
      if(statusCode != 204){
        emit(DeleteGroupFailed());
      }else{
        emit(DeleteGroupSuccess(statusCode: statusCode, groups: groups));
      }
    }catch(e){
      emit(DeleteGroupFailed());
    }
  }

  FutureOr<void> createGroup(CreateGroup event, Emitter<GroupsState> emit,) async {
    try{
      emit(CreateGroupLoadingInProgress());
      String groupName = event.groupName;
      int statusCode = await GroupAPI.createGroup(groupName);
      List<Group>? groups  = await GroupAPI.fetchAllGroups();
      if(statusCode != 200){
        emit(CreateGroupFailed());
      }else{
        emit(CreateGroupSuccess(statusCode: statusCode, groups: groups));
      }
    }catch(e){
      emit(CreateGroupFailed());
    }
  }


}
