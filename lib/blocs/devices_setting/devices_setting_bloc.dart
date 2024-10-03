import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:dideban/models/driver.dart';
import 'package:meta/meta.dart';

import '../../data/device_setting_api.dart';
import '../../models/device.dart';
import '../../models/group.dart';

part 'devices_setting_event.dart';
part 'devices_setting_state.dart';

class DevicesSettingBloc extends Bloc<DevicesSettingEvent, DevicesSettingState> {
  DevicesSettingBloc() : super(DevicesSettingInitial()) {
    on<DevicesSettingEvent>((event, emit) {
      // TODO: implement event handler
    });

    on<FetchAllDevicesSetting>(fetchAllDevices);
    on<UpdateDeviceSetting>(updateDevice);
    on<DeleteDeviceSetting>(deleteDevice);
    on<CreateDeviceSetting>(createDevice);
    on<SearchDeviceSetting>(searchDevice);

  }



  FutureOr<void> searchDevice(SearchDeviceSetting event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(SearchDeviceSettingLoadingInProgress());
      List<Device>? searchedDevices =[];
      searchedDevices = event.devices?.where((device) {
        return device.name.toLowerCase().contains(event.searchedString.toLowerCase())
            || device.uniqueId.toLowerCase().contains(event.searchedString.toLowerCase())
            || device.phone!.toLowerCase().contains(event.searchedString.toLowerCase());
      }).toList();
      emit(SearchDeviceSettingSuccess(devices: searchedDevices));
    }catch(e){
      emit(SearchDeviceSettingFailed());
    }
  }

  FutureOr<void> fetchAllDevices(FetchAllDevicesSetting event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(DevicesSettingLoadingInProgress());
      final devices  = await DeviceSettingApi.fetchAllDevices();
      final groups  = await DeviceSettingApi.fetchAllGroups();
      final drivers  = await DeviceSettingApi.fetchAllDrivers();
      if(devices == null){
        emit(DevicesSettingLoadFailed());
      }
      emit(DevicesSettingLoadSuccess(devices: devices,groups: groups,drivers: drivers));
    }catch(e){
      emit(DevicesSettingLoadFailed());
    }
  }

  FutureOr<void> updateDevice(UpdateDeviceSetting event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(UpdateDeviceSettingLoadingInProgress());
      int id = event.id;
      String newDeviceName = event.newDeviceName;
      String newUniqueId = event.newUniqueId;
      int newGroupId = event.newGroupId;
      String newPhone = event.newPhone;
      String newModel = event.newModel;
      String newContact = event.newContact;
      String newCategory = event.newCategory;
      int newDriverId = event.newDriverId;
      int oldDriverId =event.oldDriverId;
      int statusCode0 = await DeviceSettingApi.updateDevice(id, newDeviceName, newUniqueId,newGroupId,newPhone,newModel,newContact,newCategory );
      List<Device>? devices  = await DeviceSettingApi.fetchAllDevices();
      final groups  = await DeviceSettingApi.fetchAllGroups();
      final drivers  = await DeviceSettingApi.fetchAllDrivers();
      if(statusCode0 != 200){
        emit(UpdateDeviceSettingFailed());
      }else{
        if(newDriverId == 0){
          emit(UpdateDeviceSettingSuccess(statusCode: statusCode0, devices: devices,groups: groups,drivers: drivers));
          return;
        }
        if(oldDriverId == 0){
          int statusCode1 = await DeviceSettingApi.linkDeviceDriver(id, newDriverId);
          if(statusCode1 != 204){
            emit(UpdateDeviceSettingFailed());
          }else{
            emit(UpdateDeviceSettingSuccess(statusCode: statusCode1, devices: devices,groups: groups,drivers: drivers));
          }
          return;
        }
        int statusCode2 = await DeviceSettingApi.unlinkDeviceDriver(id, oldDriverId);
        if(statusCode2 != 204){
          emit(UpdateDeviceSettingFailed());
        }else{
          int statusCode3 = await DeviceSettingApi.linkDeviceDriver(id, newDriverId);
          if(statusCode3 != 204){
            emit(UpdateDeviceSettingFailed());
          }else{
            emit(UpdateDeviceSettingSuccess(statusCode: statusCode3, devices: devices,groups: groups,drivers: drivers));
          }
        }
      }
    }catch(e){
      emit(UpdateDeviceSettingFailed());
    }
  }

  FutureOr<void> deleteDevice(DeleteDeviceSetting event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(DeleteDeviceSettingLoadingInProgress());
      int id = event.id;
      int statusCode = await DeviceSettingApi.deleteDevice(id);
      List<Device>? devices  = await DeviceSettingApi.fetchAllDevices();
      final groups  = await DeviceSettingApi.fetchAllGroups();
      final drivers  = await DeviceSettingApi.fetchAllDrivers();
      if(statusCode != 204){
        emit(DeleteDeviceSettingFailed());
      }else{
        emit(DeleteDeviceSettingSuccess(statusCode: statusCode, devices: devices,groups: groups,drivers: drivers));
      }
    }catch(e){
      emit(DeleteDeviceSettingFailed());
    }
  }

  FutureOr<void> createDevice(CreateDeviceSetting event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(CreateDeviceSettingLoadingInProgress());
      String deviceName = event.deviceName;
      String uniqueId = event.uniqueId;
      int groupId = event.groupId;
      String phone = event.phone;
      String model = event.model;
      String contact =event.contact;
      String category = event.category;
      int statusCode = await DeviceSettingApi.createDevice(deviceName,uniqueId,groupId,phone,model,contact,category);
      List<Device>? devices  = await DeviceSettingApi.fetchAllDevices();
      final groups  = await DeviceSettingApi.fetchAllGroups();
      final drivers  = await DeviceSettingApi.fetchAllDrivers();
      if(statusCode != 200){
        emit(CreateDeviceSettingFailed());
      }else{
        emit(CreateDeviceSettingSuccess(statusCode: statusCode, devices: devices,groups: groups,drivers: drivers));
      }
    }catch(e){
      emit(CreateDeviceSettingFailed());
    }
  }
  
}
