part of 'devices_setting_bloc.dart';

@immutable
sealed class DevicesSettingState {}

final class DevicesSettingInitial extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DevicesSettingLoadSuccess extends DevicesSettingState {
  final List<Device>? devices;
  final List<Group>? groups;
  final List<Driver>? drivers;
  DevicesSettingLoadSuccess({
    required this.devices,
    required this.groups,
    required this.drivers
  });
}

final class DevicesSettingLoadingInProgress extends DevicesSettingState {}

final class DevicesSettingLoadFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class UpdateDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class UpdateDeviceSettingSuccess extends DevicesSettingState {
  final int statusCode;
  final List<Device>? devices;
  final List<Group>? groups;
  final List<Driver>? drivers;
  UpdateDeviceSettingSuccess({required this.statusCode, required this.devices,required this.groups, required this.drivers});
}

final class UpdateDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class DeleteDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class DeleteDeviceSettingSuccess extends DevicesSettingState {
  final int statusCode;
  final List<Device>? devices;
  final List<Group>? groups;
  final List<Driver>? drivers;
  DeleteDeviceSettingSuccess({required this.statusCode, required this.devices,required this.groups, required this.drivers});
}

final class DeleteDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class CreateDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class CreateDeviceSettingSuccess extends DevicesSettingState {
  final int statusCode;
  final List<Device>? devices;
  final List<Group>? groups;
  final List<Driver>? drivers;
  CreateDeviceSettingSuccess({required this.statusCode, required this.devices,required this.groups, required this.drivers});
}

final class CreateDeviceSettingFailed extends DevicesSettingState {}
//////////////////////////////////////////////////////////////////////////////////////////////////////////
final class SearchDeviceSettingLoadingInProgress extends DevicesSettingState {}

final class SearchDeviceSettingSuccess extends DevicesSettingState {
  final List<Device>? devices;

  SearchDeviceSettingSuccess({required this.devices,});
}

final class SearchDeviceSettingFailed extends DevicesSettingState {}

