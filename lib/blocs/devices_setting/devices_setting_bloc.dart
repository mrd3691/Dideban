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
    on<FetchAllDevicesSettingGroups>(fetchAllGroups);
    on<FetchAllDevicesSettingDrivers>(fetchAllDrivers);
    on<ShowUpdateDialogueDeviceSetting>(showUpdateDialogue);
  }

  FutureOr<void> showUpdateDialogue(ShowUpdateDialogueDeviceSetting event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(ShowUpdateDialogueDeviceSettingLoadingInProgress());
      Device device = event.device;
      final  drivers  = await DeviceSettingApi.fetchDeviceDriver(device.id);

      emit(ShowUpdateDialogueDeviceSettingSuccess(device:device, driver: drivers));
    }catch(e){
      emit(ShowUpdateDialogueDeviceSettingFailed());
    }
  }

  FutureOr<void> fetchAllDrivers(FetchAllDevicesSettingDrivers event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(DeviceSettingDriversLoadingInProgress());
      final drivers  = await DeviceSettingApi.fetchAllDrivers();
      if(drivers == null){
        emit(DeviceSettingDriversLoadFailed());
      }
      emit(DeviceSettingDriversLoadSuccess(drivers: drivers));
    }catch(e){
      emit(DeviceSettingDriversLoadFailed());
    }
  }

  FutureOr<void> fetchAllGroups(FetchAllDevicesSettingGroups event, Emitter<DevicesSettingState> emit,) async {
    try{
      emit(DeviceSettingGroupsLoadingInProgress());
      final groups  = await DeviceSettingApi.fetchAllGroups();
      if(groups == null){
        emit(DeviceSettingGroupsLoadFailed());
      }
      emit(DeviceSettingGroupsLoadSuccess(groups: groups));
    }catch(e){
      emit(DeviceSettingGroupsLoadFailed());
    }
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
      if(devices == null){
        emit(DevicesSettingLoadFailed());
      }
      emit(DevicesSettingLoadSuccess(devices: devices));
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
      int statusCode = await DeviceSettingApi.updateDevice(id, newDeviceName, newUniqueId,newGroupId,newPhone,newModel,newContact,newCategory );
      List<Device>? devices  = await DeviceSettingApi.fetchAllDevices();
      if(statusCode != 200){
        emit(UpdateDeviceSettingFailed());
      }else{
        if(oldDriverId != 0){
          int statusCode = await DeviceSettingApi.unlinkDeviceDriver(id, oldDriverId);
          if(statusCode != 204){
            emit(UpdateDeviceSettingFailed());
          }else{
            int statusCode = await DeviceSettingApi.linkDeviceDriver(id, newDriverId);
            if(statusCode != 204){
              emit(UpdateDeviceSettingFailed());
            }else{
              emit(UpdateDeviceSettingSuccess(statusCode: statusCode, devices: devices));
            }
          }
        }else{
          int statusCode = await DeviceSettingApi.linkDeviceDriver(id, newDriverId);
          if(statusCode != 204){
            emit(UpdateDeviceSettingFailed());
          }else{
            emit(UpdateDeviceSettingSuccess(statusCode: statusCode, devices: devices));
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
      if(statusCode != 204){
        emit(DeleteDeviceSettingFailed());
      }else{
        emit(DeleteDeviceSettingSuccess(statusCode: statusCode, devices: devices));
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
      if(statusCode != 200){
        emit(CreateDeviceSettingFailed());
      }else{
        emit(CreateDeviceSettingSuccess(statusCode: statusCode, devices: devices));
      }
    }catch(e){
      emit(CreateDeviceSettingFailed());
    }
  }
  
}
