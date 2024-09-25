import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dideban/data/api.dart';
import 'package:dideban/models/group.dart';
part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc() : super(GroupsInitial()) {

    on<FetchAllGroups>(fetchAllGroups);
    on<UpdateGroup>(updateGroup);
    on<DeleteGroup>(deleteGroup);
    on<CreateGroup>(createGroup);
  }



  FutureOr<void> fetchAllGroups(FetchAllGroups event, Emitter<GroupsState> emit,) async {
    try{
      emit(GroupsLoadingInProgress());
      final groups  = await API.fetchAllGroups();
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
      int statusCode = await API.updateGroup(id, newGroupName);
      List<Group>? groups  = await API.fetchAllGroups();
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
      int statusCode = await API.deleteGroup(id);
      List<Group>? groups  = await API.fetchAllGroups();
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
      int statusCode = await API.createGroup(groupName);
      List<Group>? groups  = await API.fetchAllGroups();
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
