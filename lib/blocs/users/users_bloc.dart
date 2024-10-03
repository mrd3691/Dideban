import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/user_api.dart';
import '../../models/group.dart';
import '../../models/user.dart';

part 'users_event.dart';
part 'users_state.dart';

class UsersBloc extends Bloc<UsersEvent, UsersState> {
  UsersBloc() : super(UsersInitial()) {
    on<UsersEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<FetchAllUsers>(fetchAllUsers);
    on<CreateUser>(createUser);
    on<DeleteUser>(deleteUser);
    on<UpdateUser>(updateUser);
    on<SearchUser>(searchUser);

  }


  FutureOr<void> searchUser(SearchUser event, Emitter<UsersState> emit,) async {
    try{
      emit(SearchUserLoadingInProgress());
      List<User>? searchedUsers =[];
      searchedUsers = event.users?.where((user) {
        return user.name.toLowerCase().contains(event.searchedString.toLowerCase())
            || user.email.toLowerCase().contains(event.searchedString.toLowerCase());
      }).toList();
      emit(SearchUserSuccess(users: searchedUsers));
    }catch(e){
      emit(SearchUserFailed());
    }
  }

  FutureOr<void> updateUser(UpdateUser event, Emitter<UsersState> emit,) async {
    try{
      emit(UpdateUserLoadingInProgress());
      int id = event.id;
      String newName = event.newName;
      String newUserName = event.newUserName;
      String newPassword =event.newPassword;
      List<Group> oldSelectedGroups = event.oldSelectedGroups;
      List<Group> newSelectedGroups = event.newSelectedGroups;
      int statusCode = await UserAPI.updateUser(id, newName, newUserName, newPassword);
      if(statusCode != 200){
        emit(UpdateUserFailed());
      }else{
        for(int i=0;i<oldSelectedGroups.length;i++) {
          if(newSelectedGroups.contains(oldSelectedGroups[i])){
            continue;
          }else{
            int statusCode = await UserAPI.unlinkUserGroup(id, oldSelectedGroups[i].id);
            if(statusCode != 204){
              emit(UpdateUserFailed());
              break;
            }
          }
        }

        for(int i=0;i<newSelectedGroups.length;i++) {
          if(oldSelectedGroups.contains(newSelectedGroups[i])){
            continue;
          }else{
            int statusCode = await UserAPI.linkUserGroup(id, newSelectedGroups[i].id);
            if(statusCode != 204){
              emit(UpdateUserFailed());
              break;
            }
          }
        }
        List<User>? users  = await UserAPI.fetchAllUsers();
        final groups  = await UserAPI.fetchAllGroups();
        emit(UpdateUserSuccess(statusCode: statusCode, users: users,groups: groups));
      }
    }catch(e){
      emit(UpdateUserFailed());
    }
  }

  FutureOr<void> deleteUser(DeleteUser event, Emitter<UsersState> emit,) async {
    try{
      emit(DeleteUserLoadingInProgress());
      int id = event.id;
      int statusCode = await UserAPI.deleteUser(id);
      List<User>? users  = await UserAPI.fetchAllUsers();
      final groups  = await UserAPI.fetchAllGroups();
      if(statusCode != 204){
        emit(DeleteUserFailed());
      }else{
        emit(DeleteUserSuccess(statusCode: statusCode, users: users,groups: groups));
      }
    }catch(e){
      emit(DeleteUserFailed());
    }
  }

  FutureOr<void> fetchAllUsers(FetchAllUsers event, Emitter<UsersState> emit,) async {
    try{
      emit(UsersLoadingInProgress());
      final users  = await UserAPI.fetchAllUsers();
      final groups  = await UserAPI.fetchAllGroups();
      if(users == null){
        emit(UsersLoadFailed());
      }
      emit(UsersLoadSuccess(users: users,groups: groups));
    }catch(e){
      emit(UsersLoadFailed());
    }
  }

  FutureOr<void> createUser(CreateUser event, Emitter<UsersState> emit,) async {
    try{
      emit(CreateUserLoadingInProgress());
      String name = event.name;
      String username = event.username;
      String password =event.password;
      int statusCode = await UserAPI.createUser(name,username,password);
      List<User>? users  = await UserAPI.fetchAllUsers();
      final groups  = await UserAPI.fetchAllGroups();
      if(statusCode != 200){
        emit(CreateUserFailed());
      }else{
        emit(CreateUserSuccess(statusCode: statusCode, users: users,groups: groups));
      }
    }catch(e){
      emit(CreateUserFailed());
    }
  }
}
