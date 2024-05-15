import 'package:bloc/bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:meta/meta.dart';

part 'tracking_event.dart';
part 'tracking_state.dart';

class TrackingBloc extends Bloc<TrackingEvent, TrackingState> {
  TrackingBloc() : super(TrackingInitial()) {
    on<FetchPoints>((event, emit) {
      emit(TrackingInProgress());
    });
  }
}
