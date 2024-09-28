part of 'devices_setting_bloc.dart';

@immutable
sealed class DevicesSettingEvent {}

final class FetchAllDevicesSetting extends DevicesSettingEvent{
  FetchAllDevicesSetting();
}

final class UpdateDeviceSetting extends DevicesSettingEvent{
  final int id;
  final String newDeviceName;
  final String newUniqueId;
  final int newGroupId;
  final String newPhone;
  final String newModel;
  final String newContact;
  final String newCategory;
  final int newDriverId;
  final int oldDriverId;
  UpdateDeviceSetting(this.id, this.newDeviceName, this.newUniqueId, this.newGroupId,this.newPhone,this.newModel,this.newContact,this.newCategory,this.oldDriverId,this.newDriverId);
}

final class DeleteDeviceSetting extends DevicesSettingEvent{
  final int id;
  DeleteDeviceSetting(this.id);
}

final class CreateDeviceSetting extends DevicesSettingEvent{
  final String deviceName;
  final String uniqueId;
  final int groupId;
  final String phone;
  final String model;
  final String contact;
  final String category;
  CreateDeviceSetting( this.deviceName, this.uniqueId,this.groupId,this.phone,this.category,this.contact,this.model);
}

final class SearchDeviceSetting extends DevicesSettingEvent{
  final List<Device>? devices;
  final String searchedString;
  SearchDeviceSetting(this.devices,this.searchedString);
}

final class FetchAllDevicesSettingGroups extends DevicesSettingEvent{
  FetchAllDevicesSettingGroups();
}

final class FetchAllDevicesSettingDrivers extends DevicesSettingEvent{
  FetchAllDevicesSettingDrivers();
}

final class ShowUpdateDialogueDeviceSetting extends DevicesSettingEvent{
  final Device device;
  ShowUpdateDialogueDeviceSetting(this.device);
}
