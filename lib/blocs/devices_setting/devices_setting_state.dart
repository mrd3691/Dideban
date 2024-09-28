part of 'devices_setting_bloc.dart';

@immutable
sealed class DevicesSettingState {}

final class DevicesSettingInitial extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DevicesSettingLoadSuccess extends DevicesSettingState {
  final List<Device>? devices;
  DevicesSettingLoadSuccess({
    required this.devices,
  });
}

final class DevicesSettingLoadingInProgress extends DevicesSettingState {}

final class DevicesSettingLoadFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class UpdateDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class UpdateDeviceSettingSuccess extends DevicesSettingState {
  final int statusCode;
  final List<Device>? devices;
  UpdateDeviceSettingSuccess({required this.statusCode, required this.devices});
}

final class UpdateDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeleteDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class DeleteDeviceSettingSuccess extends DevicesSettingState {
  final int statusCode;
  final List<Device>? devices;
  DeleteDeviceSettingSuccess({required this.statusCode, required this.devices});
}

final class DeleteDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class CreateDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class CreateDeviceSettingSuccess extends DevicesSettingState {
  final int statusCode;
  final List<Device>? devices;
  CreateDeviceSettingSuccess({required this.statusCode, required this.devices});
}

final class CreateDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class SearchDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class SearchDeviceSettingSuccess extends DevicesSettingState {
  final List<Device>? devices;
  SearchDeviceSettingSuccess({required this.devices});
}

final class SearchDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeviceSettingGroupsLoadSuccess extends DevicesSettingState {
  final List<Group>? groups;
  DeviceSettingGroupsLoadSuccess({
    required this.groups,
  });
}

final class DeviceSettingGroupsLoadingInProgress extends DevicesSettingState {}

final class DeviceSettingGroupsLoadFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeviceSettingDriversLoadSuccess extends DevicesSettingState {
  final List<Driver>? drivers;
  DeviceSettingDriversLoadSuccess({
    required this.drivers,
  });
}

final class DeviceSettingDriversLoadingInProgress extends DevicesSettingState {}

final class DeviceSettingDriversLoadFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class ShowUpdateDialogueDeviceSettingSuccess extends DevicesSettingState {
  final Device device;
  final List<Driver>?  driver;
  ShowUpdateDialogueDeviceSettingSuccess({
    required this.device,
    required this.driver
  });
}

final class ShowUpdateDialogueDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class ShowUpdateDialogueDeviceSettingFailed extends DevicesSettingState {}