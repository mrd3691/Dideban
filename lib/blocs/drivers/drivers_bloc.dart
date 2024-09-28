import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:dideban/models/driver.dart';
import 'package:meta/meta.dart';
import '../../data/api.dart';
part 'drivers_event.dart';
part 'drivers_state.dart';

class DriversBloc extends Bloc<DriversEvent, DriversState> {
  DriversBloc() : super(DriversInitial()) {
    on<DriversEvent>((event, emit) {
      // TODO: implement event handler
    });
    on<FetchAllDrivers>(fetchAllDrivers);
    on<UpdateDriver>(updateDriver);
    on<DeleteDriver>(deleteDriver);
    on<CreateDriver>(createDriver);
    on<SearchDriver>(searchDriver);
  }
  FutureOr<void> searchDriver(SearchDriver event, Emitter<DriversState> emit,) async {
    try{
      emit(SearchDriverLoadingInProgress());
      List<Driver>? searchedDrivers =[];
      searchedDrivers = event.drivers?.where((driver) {
        return driver.name.toLowerCase().contains(event.searchedString.toLowerCase()) || driver.uniqueId.toLowerCase().contains(event.searchedString.toLowerCase());
      }).toList();
      emit(SearchDriverSuccess(drivers: searchedDrivers));
    }catch(e){
      emit(SearchDriverFailed());
    }
  }

  FutureOr<void> fetchAllDrivers(FetchAllDrivers event, Emitter<DriversState> emit,) async {
    try{
      emit(DriversLoadingInProgress());
      final drivers  = await API.fetchAllDrivers();
      if(drivers == null){
        emit(DriversLoadFailed());
      }
      emit(DriversLoadSuccess(drivers: drivers));
    }catch(e){
      emit(DriversLoadFailed());
    }
  }

  FutureOr<void> updateDriver(UpdateDriver event, Emitter<DriversState> emit,) async {
    try{
      emit(UpdateDriverLoadingInProgress());
      int id = event.id;
      String newDriverName = event.newDriverName;
      String newUniqueId = event.newUniqueId;
      int statusCode = await API.updateDriver(id, newDriverName, newUniqueId );
      List<Driver>? drivers  = await API.fetchAllDrivers();
      if(statusCode != 200){
        emit(UpdateDriverFailed());
      }else{
        emit(UpdateDriverSuccess(statusCode: statusCode, drivers: drivers));
      }
    }catch(e){
      emit(UpdateDriverFailed());
    }
  }

  FutureOr<void> deleteDriver(DeleteDriver event, Emitter<DriversState> emit,) async {
    try{
      emit(DeleteDriverLoadingInProgress());
      int id = event.id;
      int statusCode = await API.deleteDriver(id);
      List<Driver>? drivers  = await API.fetchAllDrivers();
      if(statusCode != 204){
        emit(DeleteDriverFailed());
      }else{
        emit(DeleteDriverSuccess(statusCode: statusCode, drivers: drivers));
      }
    }catch(e){
      emit(DeleteDriverFailed());
    }
  }

  FutureOr<void> createDriver(CreateDriver event, Emitter<DriversState> emit,) async {
    try{
      emit(CreateDriverLoadingInProgress());
      String driverName = event.driverName;
      String uniqueId = event.uniqueId;
      int statusCode = await API.createDriver(driverName,uniqueId);
      List<Driver>? drivers  = await API.fetchAllDrivers();
      if(statusCode != 200){
        emit(CreateDriverFailed());
      }else{
        emit(CreateDriverSuccess(statusCode: statusCode, drivers: drivers));
      }
    }catch(e){
      emit(CreateDriverFailed());
    }
  }
}
