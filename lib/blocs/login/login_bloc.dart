import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../data/api.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial()) {
    on<UserAuthenticate>(userAuth);
  }

  FutureOr<void> userAuth(
      UserAuthenticate event,
      Emitter<LoginState> emit,) async {

    emit(LoginInProgress());

    final authResult = await API.userAuthenticate(event.userName,event.password);
    if(authResult != null){
      if(authResult.error == false){
        emit(LoginSuccess());
      }else{
        emit(LoginFailure(authResult.message));
      }
    }
  }
}
