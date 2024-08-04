import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:dideban/data/api.dart';
import 'package:dideban/models/group.dart';
part 'groups_event.dart';
part 'groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  GroupsBloc() : super(GroupsInitial()) {
    on<FetchAllGroups>((event, emit) async {
      emit(GroupsLoadingInProgress());
      List<Group>? groups  = await API.fetchAllGroups();

      emit(GroupsLoadSuccess(groups: groups));
    });
  }
}
